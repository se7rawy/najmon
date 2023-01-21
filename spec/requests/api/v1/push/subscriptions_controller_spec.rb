# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::Push::SubscriptionsController do
  path '/api/v1/push/subscription' do
    get('show subscription') do
      tags 'Api', 'V1', 'Push', 'Subscriptions'
      operationId 'v1PushSubscriptionsShowSubscription'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    patch('update subscription') do
      tags 'Api', 'V1', 'Push', 'Subscriptions'
      operationId 'v1PushSubscriptionsUpdateSubscription'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    put('update subscription') do
      tags 'Api', 'V1', 'Push', 'Subscriptions'
      operationId 'v1PushSubscriptionsUpdateSubscription'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    delete('delete subscription') do
      tags 'Api', 'V1', 'Push', 'Subscriptions'
      operationId 'v1PushSubscriptionsDeleteSubscription'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create subscription') do
      tags 'Api', 'V1', 'Push', 'Subscriptions'
      operationId 'v1PushSubscriptionsCreateSubscription'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
