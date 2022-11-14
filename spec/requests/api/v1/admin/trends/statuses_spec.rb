# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::Trends::StatusesController, type: :request do
  path '/api/v1/admin/trends/statuses' do
    get('list statuses') do
      tags 'Api', 'V1', 'Admin', 'Trends', 'Statuses'
      operationId 'v1AdminTrendsStatusesListStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
