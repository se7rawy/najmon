# frozen_string_literal: true

class ActivityPub::ProcessingWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: 8

  def perform(actor_id, body, delivered_to_account_id = nil, actor_type = 'Account', delivered_to_group_id = nil)
    case actor_type
    when 'Account'
      actor = Account.find_by(id: actor_id)
    when 'Group'
      actor = Group.find_by(id: actor_id)
    end

    return if actor.nil?

    ActivityPub::ProcessCollectionService.new.call(body, actor, override_timestamps: true, delivered_to_account_id: delivered_to_account_id, delivered_to_group_id: delivered_to_group_id, delivery: true)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug "Error processing incoming ActivityPub object: #{e}"
  end
end
