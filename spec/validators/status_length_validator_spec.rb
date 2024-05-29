# frozen_string_literal: true

require 'rails_helper'

describe StatusLengthValidator do
  describe '#validate' do
    before { stub_const("#{described_class}::MAX_CHARS", 500) } # Example values below are relative to this baseline

    it 'does not add errors onto remote statuses' do
      status = instance_double(Status, local?: false)
      allow(status).to receive(:errors)

      subject.validate(status)

      expect(status).to_not have_received(:errors)
    end

    it 'does not add errors onto local reblogs' do
      status = instance_double(Status, local?: false, reblog?: true)
      allow(status).to receive(:errors)

      subject.validate(status)

      expect(status).to_not have_received(:errors)
    end

    it 'adds an error when content warning is over character limit' do
      status = status_double(spoiler_text: 'a' * 520)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'adds an error when text is over character limit' do
      status = status_double(text: 'a' * 520)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'adds an error when text and content warning are over character limit total' do
      status = status_double(spoiler_text: 'a' * 250, text: 'b' * 251)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'counts URLs as 23 characters flat' do
      text   = ('a' * 476) + " http://#{'b' * 30}.com/example"
      status = status_double(text: text)

      subject.validate(status)
      expect(status.errors).to_not have_received(:add)
    end

    it 'does not count non-autolinkable URLs as 23 characters flat' do
      text   = ('a' * 476) + "http://#{'b' * 30}.com/example"
      status = status_double(text: text)

      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'does not count overly long URLs as 23 characters flat' do
      text = "http://example.com/valid?#{'#foo?' * 1000}"
      status = status_double(text: text)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'counts only the front part of remote usernames' do
      text   = ('a' * 475) + " @alice@#{'b' * 30}.com"
      status = status_double(text: text)

      subject.validate(status)
      expect(status.errors).to_not have_received(:add)
    end

    it 'does count both parts of remote usernames for overly long domains' do
      text   = "@alice@#{'b' * 500}.com"
      status = status_double(text: text)

      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end
  end

  private

  def status_double(spoiler_text: '', text: '')
    instance_double(
      Status,
      spoiler_text: spoiler_text,
      text: text,
      errors: activemodel_errors,
      local?: true,
      reblog?: false
    )
  end

  def activemodel_errors
    instance_double(ActiveModel::Errors, add: nil)
  end
end
