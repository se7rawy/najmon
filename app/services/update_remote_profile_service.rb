# frozen_string_literal: true

class UpdateRemoteProfileService < BaseService
  attr_reader :account, :remote_profile

  def call(body, account, resubscribe = false)
    @account        = account
    @remote_profile = RemoteProfile.new(body)

    return if remote_profile.root.nil?

    update_account unless remote_profile.author.nil?

    old_hub_url     = account.hub_url
    account.hub_url = remote_profile.hub_link if remote_profile.hub_link.present? && remote_profile.hub_link != old_hub_url

    account.save_with_optional_media!

    Pubsubhubbub::SubscribeWorker.perform_async(account.id) if resubscribe && account.hub_url != old_hub_url
  end

  private

  def update_account
    account.display_name = remote_profile.display_name || ''
    account.note         = remote_profile.note         || ''
    account.locked       = remote_profile.locked?

    if !account.suspended? && !DomainBlock.find_by(domain: account.domain)&.reject_media?
      if remote_profile.avatar.present?
        account.avatar_remote_url = remote_profile.avatar
      else
        account.avatar_remote_url = ''
        account.avatar.destroy
      end

      if remote_profile.header.present?
        account.header_remote_url = remote_profile.header
      else
        account.header_remote_url = ''
        account.header.destroy
      end
    end
  end
end
