# frozen_string_literal: true

class Api::Activitypub::OutboxController < ApiController
  before_action :set_account

  respond_to :activitystreams2

  def show
    @statuses = Feed.new(:outbox, @account).get(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
    @statuses = cache_collection(@statuses)

    set_maps(@statuses)
    set_counters_maps(@statuses)
    set_account_counters_maps(@statuses.flat_map { |s| [s.account, s.reblog? ? s.reblog.account : nil] }.compact.uniq)

    # Since the statuses are in reverse chronological order, last is the lowest ID.
    @next_path = api_activitypub_outbox_url(max_id: @statuses.last.id)    if @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
    @prev_path = api_activitypub_outbox_url(since_id: @statuses.first.id) unless @statuses.empty?

    set_pagination_headers(@next_path, @prev_path)
  end

  private

  def cache_collection(raw)
    super(raw, Status)
  end

  def set_account
    @account = Account.find(params[:id])
  end
end
