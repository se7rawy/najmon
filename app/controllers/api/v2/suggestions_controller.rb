# frozen_string_literal: true

class Api::V2::SuggestionsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, except: :index
  before_action :require_user!
  before_action :set_suggestions

  def index
    render json: @suggestions, each_serializer: REST::SuggestionSerializer
  end

  def destroy
    account_suggestions.remove(params[:id])
    render_empty
  end

  private

  def set_suggestions
    @suggestions = account_suggestions.get(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params[:offset].to_i
    )
  end

  def account_suggestions
    AccountSuggestions.new(current_account)
  end
end
