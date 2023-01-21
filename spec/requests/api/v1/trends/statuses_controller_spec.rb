# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::Trends::StatusesController do
  path '/api/v1/trends/statuses' do
    get('list statuses') do
      tags 'Api', 'V1', 'Trends', 'Statuses'
      operationId 'v1TrendsStatusesListStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
