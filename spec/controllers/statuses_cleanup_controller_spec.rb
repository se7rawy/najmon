require 'rails_helper'

RSpec.describe StatusesCleanupController, type: :controller do
  render_views

  before do
    @user = Fabricate(:user)
    sign_in @user, scope: :user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(200)
    end
  end

  describe 'PUT #update' do
    it 'updates the account status cleanup policy' do
      put :update, params: { account_statuses_cleanup_policy: { enabled: true, min_status_age: 2.weeks.seconds, keep_direct: false, keep_polls: true } }
      expect(response).to redirect_to(statuses_cleanup_path)
      expect(@user.account.statuses_cleanup_policy.enabled).to be true
      expect(@user.account.statuses_cleanup_policy.keep_direct).to be false
      expect(@user.account.statuses_cleanup_policy.keep_polls).to be true
    end
  end
end
