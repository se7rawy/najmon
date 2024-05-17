# frozen_string_literal: true

class Api::V1::AppsController < Api::BaseController
  skip_before_action :require_authenticated_user!

  def create
    @app = Doorkeeper::Application.create!(application_options)
    render json: @app, serializer: REST::ApplicationSerializer
  end

  private

  def application_options
    {
      name: app_params[:client_name],
      redirect_uri: app_params[:redirect_uris],
      scopes: app_scopes_or_default,
      website: app_params[:website],
      confidential: app_confidential?,
    }
  end

  def app_confidential?
    !app_params[:token_endpoint_auth_method] || app_params[:token_endpoint_auth_method] != 'none'
  end

  def app_scopes_or_default
    app_params[:scopes] || Doorkeeper.configuration.default_scopes
  end

  def app_params
    params.permit(:client_name, :redirect_uris, :scopes, :token_endpoint_auth_method, :website)
  end
end
