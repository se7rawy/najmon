# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_allows
#
#  id         :bigint(8)        not null, primary key
#  domain     :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DomainAllow < ApplicationRecord
  include Paginable
  include DomainNormalizable
  include DomainMaterializable

  validates :domain, presence: true, uniqueness: true, domain: true

  scope :matches_domain, ->(value) { where(arel_table[:domain].matches("%#{value}%")) }

  def to_log_human_identifier
    domain
  end

  alias to_log_route_param to_log_human_identifier

  class << self
    def allowed?(domain)
      !rule_for(domain).nil?
    end

    def allowed_domains
      select(:domain)
    end

    def rule_for(domain)
      return if domain.blank?

      uri = Addressable::URI.new.tap { |u| u.host = domain.delete('/') }

      find_by(domain: uri.normalized_host)
    end
  end
end
