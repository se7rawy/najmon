# frozen_string_literal: true

require 'rails_helper'

describe LanguageDetector do
  describe 'to_iso_s' do
    it 'detects english language' do
      string = 'Hello and welcome to mastadon'
      result = described_class.new(string).to_iso_s

      expect(result).to eq :en
    end

    it 'detects spanish language' do
      string = 'Obtener un Hola y bienvenidos a Mastadon'
      result = described_class.new(string).to_iso_s

      expect(result).to eq :es
    end

    describe 'when language cant be detected' do
      describe 'with an `en` default locale' do
        it 'uses the default locale' do
          string = ''
          result = described_class.new(string).to_iso_s

          expect(result).to eq :en
        end
      end

      describe 'with a non-`en` default locale' do
        around(:each) do |example|
          before = I18n.default_locale
          I18n.default_locale = :ja
          example.run
          I18n.default_locale = before
        end

        it 'uses the default locale' do
          string = ''
          result = described_class.new(string).to_iso_s

          expect(result).to eq :ja
        end
      end
    end
  end
end
