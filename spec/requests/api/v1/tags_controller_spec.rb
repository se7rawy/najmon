# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::TagsController do
  path '/api/v1/tags/{id}/follow' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('follow tag') do
      tags 'Api', 'V1', 'Tags'
      operationId 'v1TagsFollowTag'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/tags/{id}/unfollow' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unfollow tag') do
      tags 'Api', 'V1', 'Tags'
      operationId 'v1TagsUnfollowTag'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/tags/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show tag') do
      tags 'Api', 'V1', 'Tags'
      operationId 'v1TagsShowTag'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end
