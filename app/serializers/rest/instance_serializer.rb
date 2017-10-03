
# frozen_string_literal: true

class REST::InstanceSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :uri, :title, :description, :email,
             :version, :urls, :stats, :thumbnail

  def uri
    Rails.configuration.x.local_domain
  end

  def title
    Setting.site_title
  end

  def description
    Setting.site_description
  end

  def email
    Setting.site_contact_email
  end

  def version
    Mastodon::Version.to_s
  end

  def thumbnail
    full_asset_url(instance_presenter.thumbnail.file.url) if instance_presenter.thumbnail
  end

  def stats
    {
      user_count: instance_presenter.user_count,
      status_count: instance_presenter.status_count,
      domain_count: instance_presenter.domain_count,
      active_user_count: {
        '30d': instance_presenter.active_user_count_30d,
        '14d': instance_presenter.active_user_count_14d,
        '7d': instance_presenter.active_user_count_7d,
        '1d': instance_presenter.active_user_count_1d,
        '1h': instance_presenter.active_user_count_1h,
      },
      first_user_created_at: instance_presenter.first_user_created_at,
    }
  end

  def urls
    { streaming_api: Rails.configuration.x.streaming_api_base_url }
  end

  private

  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end
end
