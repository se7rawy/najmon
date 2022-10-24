# frozen_string_literal: true

class ActivityPub::RemoveSerializer < ActivityPub::Serializer
  class UriSerializer < ActiveModel::Serializer
    include RoutingHelper

    def serializable_hash(*_args)
      ActivityPub::TagManager.instance.uri_for(object)
    end
  end

  def self.serializer_for(model, options)
    case model.class.name
    when 'Status'
      UriSerializer
    when 'FeaturedTag'
      ActivityPub::HashtagSerializer
    else
      super
    end
  end

  include RoutingHelper

  attributes :type, :actor, :target
  has_one :proper_object, key: :object

  def type
    'Remove'
  end

  def actor
    instance_options[:actor].presence || ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def proper_object
    object
  end

  def target
    instance_options[:target].presence || account_collection_url(object.account, :featured)
  end
end
