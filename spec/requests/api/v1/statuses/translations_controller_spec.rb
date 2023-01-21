# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::Statuses::TranslationsController do
  path '/api/v1/statuses/{status_id}/translate' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    post('create translation') do
      tags 'Api', 'V1', 'Statuses', 'Translations'
      operationId 'v1StatusesTranslationsCreateTranslation'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:status_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end
