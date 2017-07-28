# frozen_string_literal: true

class DomainBlockWorker
  include Sidekiq::Worker

  sidekiq_options dead: false

  def perform(domain_block_id)
    BlockDomainService.new.call(DomainBlock.find(domain_block_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
