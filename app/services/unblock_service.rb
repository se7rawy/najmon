# frozen_string_literal: true

class UnblockService < BaseService
  include Payloadable

  def call(account, target_account)
    return unless account.blocking?(target_account)

    unblock = account.unblock!(target_account)
    create_notification(unblock) if !target_account.local? && target_account.activitypub?

    notify_streaming!

    unblock
  end

  private

  def create_notification(unblock)
    ActivityPub::DeliveryWorker.perform_async(build_json(unblock), unblock.account_id, unblock.target_account.inbox_url)
  end

  def build_json(unblock)
    Oj.dump(serialize_payload(unblock, ActivityPub::UndoBlockSerializer))
  end

  def notify_streaming!
    redis.publish("system:#{@account.id}", Oj.dump(event: :blocks_changed))
    redis.publish("system:#{@target_account.id}", Oj.dump(event: :blocks_changed)) if @target_account.local?
  end
end
