# frozen_string_literal: true

module LanguagesHelper
  ISO_639_1 = {
    ar: ['Arabic', 'اللغة العربية'].freeze,
    en: ['English', 'English'].freeze,
  }.freeze

  ISO_639_3 = {
    
  }.freeze

  # e.g. For Chinese, which is not a language,
  # but a language family in spite of sharing the main locale code
  # We need to be able to filter these
  ISO_639_1_REGIONAL = {

  }.freeze

  SUPPORTED_LOCALES = {}.merge(ISO_639_1).merge(ISO_639_1_REGIONAL).merge(ISO_639_3).freeze

  # For ISO-639-1 and ISO-639-3 language codes, we have their official
  # names, but for some translations, we need the names of the
  # regional variants specifically
  REGIONAL_LOCALE_NAMES = {
    'en-GB': 'English (British)',
    'es-AR': 'Español (Argentina)',
    'es-MX': 'Español (México)',
    'fr-QC': 'Français (Canadien)',
    'pt-BR': 'Português (Brasil)',
    'pt-PT': 'Português (Portugal)',
    'sr-Latn': 'Srpski (latinica)',
  }.freeze

  def native_locale_name(locale)
    if locale.blank? || locale == 'und'
      I18n.t('generic.none')
    elsif (supported_locale = SUPPORTED_LOCALES[locale.to_sym])
      supported_locale[1]
    elsif (regional_locale = REGIONAL_LOCALE_NAMES[locale.to_sym])
      regional_locale
    else
      locale
    end
  end

  def standard_locale_name(locale)
    if locale.blank?
      I18n.t('generic.none')
    elsif (supported_locale = SUPPORTED_LOCALES[locale.to_sym])
      supported_locale[0]
    else
      locale
    end
  end

  def valid_locale_or_nil(str)
    return if str.blank?
    return str if valid_locale?(str)

    code, = str.to_s.split(/[_-]/) # Strip out the region from e.g. en_US or ja-JP

    return unless valid_locale?(code)

    code
  end

  def valid_locale_cascade(*arr)
    arr.each do |str|
      locale = valid_locale_or_nil(str)
      return locale if locale.present?
    end

    nil
  end

  def valid_locale?(locale)
    locale.present? && SUPPORTED_LOCALES.key?(locale.to_sym)
  end

  def available_locale_or_nil(locale_name)
    locale_name.to_sym if locale_name.present? && I18n.available_locales.include?(locale_name.to_sym)
  end
end

# rubocop:enable Metrics/ModuleLength
