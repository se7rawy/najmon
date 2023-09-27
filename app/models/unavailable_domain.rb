# frozen_string_literal: true

# == Schema Information
#
# Table name: unavailable_domains
#
#  id         :bigint(8)        not null, primary key
#  domain     :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UnavailableDomain < ApplicationRecord
  include DomainNormalizable

  validates :domain, presence: true, uniqueness: true

  after_commit :reset_cache!

  def to_log_human_identifier
    domain
  end

  alias to_log_route_param to_log_human_identifier

  private

  def reset_cache!
    Rails.cache.delete('unavailable_domains')
  end
end
