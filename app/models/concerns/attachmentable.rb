# frozen_string_literal: true

require 'mime/types/columnar'

module Attachmentable
  extend ActiveSupport::Concern

  MAX_MATRIX_LIMIT = 16_777_216 # 4096x4096px or approx. 16MB
  GIF_MATRIX_LIMIT = 921_600    # 1280x720px

  # For some file extensions, there exist different content
  # type variants, and browsers often send the wrong one,
  # for example, sending an audio .ogg file as video/ogg,
  # likewise, MimeMagic also misreports them as such. For
  # those files, it is necessary to use the output of the
  # `file` utility instead
  INCORRECT_CONTENT_TYPES = %w(
    video/ogg
    video/webm
  ).freeze

  included do
    def self.has_attached_file(name, options = {}) # rubocop:disable Naming/PredicateName
      options = { validate_media_type: false }.merge(options)
      super(name, options)
      send(:"before_#{name}_post_process") do
        attachment = send(name)
        check_image_dimension(attachment)
        set_file_content_type(attachment)
        obfuscate_file_name(attachment)
        set_file_extension(attachment)
        Paperclip::Validators::MediaTypeSpoofDetectionValidator.new(attributes: [name]).validate(self)
      end
    end
  end

  private

  def set_file_content_type(attachment) # rubocop:disable Naming/AccessorMethodName
    return if attachment.blank? || attachment.queued_for_write[:original].blank? || !INCORRECT_CONTENT_TYPES.include?(attachment.instance_read(:content_type))

    attachment.instance_write :content_type, calculated_content_type(attachment)
  end

  def set_file_extension(attachment) # rubocop:disable Naming/AccessorMethodName
    return if attachment.blank?

    attachment.instance_write :file_name, [Paperclip::Interpolations.basename(attachment, :original), appropriate_extension(attachment)].delete_if(&:blank?).join('.')
  end

  def check_image_dimension(attachment)
    return if attachment.blank? || !/image.*/.match?(attachment.content_type) || attachment.queued_for_write[:original].blank?

    width, height = FastImage.size(attachment.queued_for_write[:original].path)
    matrix_limit  = attachment.content_type == 'image/gif' ? GIF_MATRIX_LIMIT : MAX_MATRIX_LIMIT

    raise Mastodon::DimensionsValidationError, "#{width}x#{height} images are not supported" if width.present? && height.present? && (width * height > matrix_limit)
  end

  def appropriate_extension(attachment)
    mime_type = MIME::Types[attachment.content_type]

    extensions_for_mime_type = mime_type.empty? ? [] : mime_type.first.extensions
    original_extension       = Paperclip::Interpolations.extension(attachment, :original)
    proper_extension         = extensions_for_mime_type.first.to_s
    extension                = extensions_for_mime_type.include?(original_extension) ? original_extension : proper_extension
    extension                = 'jpeg' if extension == 'jpe'

    extension
  end

  def calculated_content_type(attachment)
    Paperclip.run('file', '-b --mime :file', file: attachment.queued_for_write[:original].path).split(/[:;\s]+/).first.chomp
  rescue Terrapin::CommandLineError
    ''
  end

  def obfuscate_file_name(attachment)
    return if attachment.blank? || attachment.queued_for_write[:original].blank? || attachment.options[:preserve_files]

    attachment.instance_write :file_name, SecureRandom.hex(8) + File.extname(attachment.instance_read(:file_name))
  end
end
