# frozen_string_literal: true

module WebAppControllerConcern
  extend ActiveSupport::Concern

  included do
    prepend_before_action :redirect_unauthenticated_to_permalinks!
    before_action :set_app_body_class

    vary_by 'Accept, Accept-Language, Cookie'

    content_security_policy do |p|
      include Rails.application.routes.url_helpers

      p.form_action -> { destroy_user_session_url(host: request.host) }
    end
  end

  def skip_csrf_meta_tags?
    !(ENV['OMNIAUTH_ONLY'] == 'true' && Devise.omniauth_providers.length == 1) && current_user.nil?
  end

  def set_app_body_class
    @body_classes = 'app-body'
  end

  def redirect_unauthenticated_to_permalinks!
    return if user_signed_in? && current_account.moved_to_account_id.nil?

    redirect_path = PermalinkRedirector.new(request.path).redirect_path

    redirect_to(redirect_path) if redirect_path.present?
  end
end
