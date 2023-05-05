# frozen_string_literal: true

module ApplicationExtension
  extend ActiveSupport::Concern

  included do
    has_many :created_users, class_name: 'User', foreign_key: 'created_by_application_id', inverse_of: :created_by_application

    validates :name, length: { maximum: 60 }
    validates :website, url: true, length: { maximum: 2_000 }, if: :website?
    validates :redirect_uri, length: { maximum: 2_000 }
  end

  def most_recently_used_access_token
    @most_recently_used_access_token ||= access_tokens.where.not(last_used_at: nil).order(last_used_at: :desc).first
  end

  def confirmation_redirect_uri
    redirect_uri.lines.first.strip
  end
end
