# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::Admin::MeasuresController do
  path '/api/v1/admin/measures' do
    post('create measure') do
      tags 'Api', 'V1', 'Admin', 'Measures'
      operationId 'v1AdminMeasuresCreateMeasure'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
