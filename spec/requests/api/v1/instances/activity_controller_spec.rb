# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::Instances::ActivityController do
  path '/api/v1/instance/activity' do
    get('show activity') do
      tags 'Api', 'V1', 'Instances', 'Activity'
      operationId 'v1InstancesActivityShowActivity'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
