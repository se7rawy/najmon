# frozen_string_literal: true

class REST::ApplicationSerializer < REST::BaseSerializer
  attributes :id, :name, :website, :scopes, :redirect_uri,
             :client_id, :client_secret

  # NOTE: Deprecated in 4.3.0, needs to be removed in 5.0.0
  attribute :vapid_key

  def id
    object.id.to_s
  end

  def client_id
    object.uid
  end

  def client_secret
    object.secret
  end

  def website
    object.website.presence
  end

  def vapid_key
    Rails.configuration.x.vapid_public_key
  end
end
