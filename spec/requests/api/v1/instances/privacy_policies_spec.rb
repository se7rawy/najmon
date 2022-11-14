# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Instances::PrivacyPoliciesController, type: :request do
  path '/api/v1/instance/privacy_policy' do
    get('show privacy_policy') do
      tags 'Api', 'V1', 'Instances', 'PrivacyPolicies'
      operationId 'v1InstancesPrivacypoliciesShowPrivacyPolicy'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
