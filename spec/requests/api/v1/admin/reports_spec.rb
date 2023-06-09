# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reports' do
  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:scopes)  { 'admin:read:reports admin:write:reports' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  shared_examples 'forbidden for wrong scope' do |wrong_scope|
    let(:scopes) { wrong_scope }

    it 'returns http forbidden' do
      subject

      expect(response).to have_http_status(403)
    end
  end

  shared_examples 'forbidden for wrong role' do |wrong_role|
    let(:role) { UserRole.find_by(name: wrong_role) }

    it 'returns http forbidden' do
      subject

      expect(response).to have_http_status(403)
    end
  end

  describe 'GET /api/v1/admin/reports' do
    subject do
      get '/api/v1/admin/reports', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    context 'when there are no reports' do
      it 'returns an empty list' do
        subject

        expect(body_as_json).to be_empty
      end
    end

    context 'when there are reports' do
      let!(:reporter) { Fabricate(:account) }
      let!(:spammer)  { Fabricate(:account) }
      let(:expected_response) do
        scope.map do |report|
          hash_including({
            id: report.id.to_s,
            action_taken: report.action_taken?,
            category: report.category,
            comment: report.comment,
            account: hash_including(id: report.account.id.to_s),
            target_account: hash_including(id: report.target_account.id.to_s),
            statuses: report.statuses,
            rules: report.rules,
            forwarded: report.forwarded,
          })
        end
      end
      let(:scope) { Report.unresolved }

      before do
        Fabricate(:report)
        Fabricate(:report, target_account: spammer)
        Fabricate(:report, account: reporter, target_account: spammer)
        Fabricate(:report, action_taken_at: 4.days.ago, account: reporter)
        Fabricate(:report, action_taken_at: 20.days.ago)
      end

      it 'returns all unresolved reports' do
        subject

        expect(body_as_json).to match_array(expected_response)
      end

      context 'with resolved param' do
        let(:params) { { resolved: true } }
        let(:scope)  { Report.resolved }

        it 'returns only the resolved reports' do
          subject

          expect(body_as_json).to match_array(expected_response)
        end
      end

      context 'with account_id param' do
        let(:params) { { account_id: reporter.id } }
        let(:scope)  { Report.unresolved.where(account: reporter) }

        it 'returns all unresolved reports filed by the specified account' do
          subject

          expect(body_as_json).to match_array(expected_response)
        end
      end

      context 'with target_account_id param' do
        let(:params) { { target_account_id: spammer.id } }
        let(:scope)  { Report.unresolved.where(target_account: spammer) }

        it 'returns all unresolved reports targeting the specified account' do
          subject

          expect(body_as_json).to match_array(expected_response)
        end
      end

      context 'with limit param' do
        let(:params) { { limit: 1 } }

        it 'returns only the requested number of reports' do
          subject

          expect(body_as_json.size).to eq(1)
        end
      end
    end
  end

  describe 'GET /api/v1/admin/reports/:id' do
    subject do
      get "/api/v1/admin/reports/#{report.id}", headers: headers
    end

    let(:report) { Fabricate(:report) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns the requested report content' do
      subject

      expect(body_as_json).to include(
        {
          id: report.id.to_s,
          action_taken: report.action_taken?,
          category: report.category,
          comment: report.comment,
          account: a_hash_including(id: report.account.id.to_s),
          target_account: a_hash_including(id: report.target_account.id.to_s),
          statuses: report.statuses,
          rules: report.rules,
          forwarded: report.forwarded,
        }
      )
    end
  end

  describe 'PUT /api/v1/admin/reports/:id' do
    subject do
      put "/api/v1/admin/reports/#{report.id}", headers: headers, params: params
    end

    let!(:report) { Fabricate(:report, category: :other) }
    let(:params)  { { category: 'spam' } }

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'updates the report category' do
      expect { subject }.to change { report.reload.category }.from('other').to('spam')
    end

    it 'returns the updated report content' do
      subject

      report.reload

      expect(body_as_json).to include(
        {
          id: report.id.to_s,
          action_taken: report.action_taken?,
          category: report.category,
          comment: report.comment,
          account: a_hash_including(id: report.account.id.to_s),
          target_account: a_hash_including(id: report.target_account.id.to_s),
          statuses: report.statuses,
          rules: report.rules,
          forwarded: report.forwarded,
        }
      )
    end
  end

  describe 'POST #resolve' do
    subject do
      post "/api/v1/admin/reports/#{report.id}/resolve", headers: headers
    end

    let(:report) { Fabricate(:report, action_taken_at: nil) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'marks report as resolved' do
      expect { subject }.to change { report.reload.unresolved? }.from(true).to(false)
    end
  end

  describe 'POST #reopen' do
    subject do
      post "/api/v1/admin/reports/#{report.id}/reopen", headers: headers
    end

    let(:report) { Fabricate(:report, action_taken_at: 10.days.ago) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'marks report as unresolved' do
      expect { subject }.to change { report.reload.unresolved? }.from(false).to(true)
    end
  end

  describe 'POST #assign_to_self' do
    subject do
      post "/api/v1/admin/reports/#{report.id}/assign_to_self", headers: headers
    end

    let(:report) { Fabricate(:report) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'assigns report to the requesting user' do
      expect { subject }.to change { report.reload.assigned_account_id }.from(nil).to(user.account.id)
    end
  end

  describe 'POST #unassign' do
    subject do
      post "/api/v1/admin/reports/#{report.id}/unassign", headers: headers
    end

    let(:report) { Fabricate(:report, assigned_account_id: user.account.id) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'unassigns report from assignee' do
      expect { subject }.to change { report.reload.assigned_account_id }.from(user.account.id).to(nil)
    end
  end
end
