# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::PreferencesController do
  path '/api/v1/preferences' do
    get('list preferences') do
      tags 'Api', 'V1', 'Preferences'
      operationId 'v1PreferencesListPreference'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
