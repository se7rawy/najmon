# frozen_string_literal: true

class Api::V1::Timelines::PublicController < Api::BaseController
  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

  respond_to :json

  def show
    @statuses = load_statuses
    render 'api/v1/timelines/show'
  end

  private

  def load_statuses
    cached_public_statuses.tap do |statuses|
      set_maps(statuses)
    end
  end

  def cached_public_statuses
    cache_collection public_statuses, Status
  end

  def public_statuses
    Status.as_public_timeline(
      account: current_account,
      local_only: params[:local],
      limit: limit_param(DEFAULT_STATUSES_LIMIT),
      max_id: params[:max_id],
      since_id: params[:since_id]
    )
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_params(core_params)
    params.permit(:local, :limit).merge(core_params)
  end

  def next_path
    api_v1_timelines_public_url pagination_params(max_id: pagination_max_id)
  end

  def prev_path
    api_v1_timelines_public_url pagination_params(since_id: pagination_since_id)
  end

  def pagination_max_id
    @statuses.last.id
  end

  def pagination_since_id
    @statuses.first.id
  end
end
