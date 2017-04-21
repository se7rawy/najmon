# frozen_string_literal: true

module AccountHeader
  extend ActiveSupport::Concern
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

  class_methods do
    def header_styles(file)
      styles = { original: '700x335#' }
      styles[:static] = { format: 'png' } if file.content_type == 'image/gif'
      styles
    end
    private :header_styles
  end

  included do
    # Header upload
    has_attached_file :header, styles: ->(f) { header_styles(f) }, convert_options: { all: '-quality 80 -strip' }
    validates_attachment_content_type :header, content_type: IMAGE_MIME_TYPES
    validates_attachment_size :header, less_than: 2.megabytes
    attr_accessor :delete_header
    before_validation :destroy_header_if_requested

    def header_original_url
      header.url(:original)
    end

    def header_static_url
      header_content_type == 'image/gif' ? header.url(:static) : header_original_url
    end

    def header_remote_url=(url)
      parsed_url = Addressable::URI.parse(url).normalize

      return if !%w(http https).include?(parsed_url.scheme) || parsed_url.host.empty? || self[:header_remote_url] == url

      self.header              = URI.parse(parsed_url.to_s)
      self[:header_remote_url] = url
    rescue OpenURI::HTTPError => e
      Rails.logger.debug "Error fetching remote header: #{e}"
    end

    def destroy_header_if_requested
      header.destroy if delete_header == '1' && !header.dirty?
    end
  end
end
