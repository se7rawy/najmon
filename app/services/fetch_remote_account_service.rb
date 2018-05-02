# frozen_string_literal: true

class FetchRemoteAccountService < BaseService
  include AuthorExtractor
  include XmlHelper

  def call(url, prefetched_body = nil, protocol = :ostatus)
    if prefetched_body.nil?
      resource_url, resource_options, protocol = FetchAtomService.new.call(url)
    else
      resource_url     = url
      resource_options = { prefetched_body: prefetched_body }
    end

    case protocol
    when :ostatus
      process_atom(resource_url, **resource_options)
    when :activitypub
      ActivityPub::FetchRemoteAccountService.new.call(resource_url, **resource_options)
    end
  end

  private

  def process_atom(url, prefetched_body:)
    xml     = Oga.parse_xml(prefetched_body)
    account = author_from_xml(xml.at_xpath(namespaced_xpath('/xmlns:feed', xmlns: OStatus::TagManager::XMLNS)), false)

    UpdateRemoteProfileService.new.call(prefetched_body, account) unless account.nil?

    account
  rescue TypeError
    Rails.logger.debug "Unparseable URL given: #{url}"
    nil
  rescue LL::ParserError
    Rails.logger.debug 'Invalid XML or missing namespace'
    nil
  end
end
