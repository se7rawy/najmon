# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/v1/accounts/{account_id}' do
  it 'returns account entity as 200 OK' do
    account = Fabricate(:account)

    get "/api/v1/accounts/#{account.id}"

    aggregate_failures do
      expect(response).to have_http_status(200)
      expect(body_as_json[:id]).to eq(account.id.to_s)
    end
  end

  it 'returns 404 if account not found' do
    get '/api/v1/accounts/1'

    aggregate_failures do
      expect(response).to have_http_status(404)
      expect(body_as_json[:error]).to eq('Record not found')
    end
  end

  context 'when with token' do
    it 'returns account entity as 200 OK if token is valid' do
      account = Fabricate(:account)
      user = Fabricate(:user, account: account)
      token = Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:accounts').token

      get "/api/v1/accounts/#{account.id}", headers: { Authorization: "Bearer #{token}" }

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(body_as_json[:id]).to eq(account.id.to_s)
      end
    end

    it 'returns 403 if scope of token is invalid' do
      account = Fabricate(:account)
      user = Fabricate(:user, account: account)
      token = Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'write:statuses').token

      get "/api/v1/accounts/#{account.id}", headers: { Authorization: "Bearer #{token}" }

      aggregate_failures do
        expect(response).to have_http_status(403)
        expect(body_as_json[:error]).to eq('This action is outside the authorized scopes')
      end
    end
  end

  describe 'about username' do
    it 'is equal to value in username column' do
      account = Fabricate(:account, username: 'local_username')

      get "/api/v1/accounts/#{account.id}"
      response_body = body_as_json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq(account.id.to_s)
        expect(response_body[:username]).to eq('local_username')
      end
    end
  end
end
