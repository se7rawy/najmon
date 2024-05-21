# frozen_string_literal: true

module EmailHelper
  def self.included(base)
    base.extend(self)
  end

  def email_to_canonical_email(str)
    return nil if str.nil?

    username, domain = str.downcase.split('@', 2)
    username, = username.delete('.').split('+', 2)

    "#{username}@#{domain}"
  end

  def email_to_canonical_email_hash(str)
    return nil if str.nil?

    Digest::SHA2.new(256).hexdigest(email_to_canonical_email(str))
  end
end
