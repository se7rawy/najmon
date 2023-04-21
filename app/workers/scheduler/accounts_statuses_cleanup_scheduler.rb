# frozen_string_literal: true

class Scheduler::AccountsStatusesCleanupScheduler
  include Sidekiq::Worker
  include Redisable

  # This limit is mostly to be nice to the fediverse at large and not
  # generate too much traffic.
  # This also helps limiting the running time of the scheduler itself.
  MAX_BUDGET         = 150

  # This is an attempt to spread the load across remote servers, as
  # spreading deletions across diverse accounts is likely to spread
  # the deletion across diverse followers. It also helps each individual
  # user see some effect sooner.
  PER_ACCOUNT_BUDGET = 5

  # This is an attempt to limit the workload generated by status removal
  # jobs to something the particular server can handle.
  PER_THREAD_BUDGET  = 6

  # These are latency limits on various queues above which a server is
  # considered to be under load, causing the auto-deletion to be entirely
  # skipped for that run.
  LOAD_LATENCY_THRESHOLDS = {
    default: 5,
    push: 10,
    # The `pull` queue has lower priority jobs, and it's unlikely that
    # pushing deletes would cause much issues with this queue if it didn't
    # cause issues with `default` and `push`. Yet, do not enqueue deletes
    # if the instance is lagging behind too much.
    pull: 5.minutes.to_i,
  }.freeze

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    return if under_load?

    budget = compute_budget
    first_policy_id = last_processed_id

    loop do
      num_processed_accounts = 0

      scope = AccountStatusesCleanupPolicy.where(enabled: true)
      scope.where(Account.arel_table[:id].gt(first_policy_id)) if first_policy_id.present?
      scope.find_each(order: :asc) do |policy|
        num_deleted = AccountStatusesCleanupService.new.call(policy, [budget, PER_ACCOUNT_BUDGET].min)
        num_processed_accounts += 1 unless num_deleted.zero?
        budget -= num_deleted
        if budget.zero?
          save_last_processed_id(policy.id)
          break
        end
      end

      # The idea here is to loop through all policies at least once until the budget is exhausted
      # and start back after the last processed account otherwise
      break if budget.zero? || (num_processed_accounts.zero? && first_policy_id.nil?)

      first_policy_id = nil
    end
  end

  def compute_budget
    # Each post deletion is a `RemovalWorker` job (on `default` queue), each
    # potentially spawning many `ActivityPub::DeliveryWorker` jobs (on the `push` queue).
    threads = Sidekiq::ProcessSet.new.select { |x| x['queues'].include?('push') }.pluck('concurrency').sum
    [PER_THREAD_BUDGET * threads, MAX_BUDGET].min
  end

  def under_load?
    LOAD_LATENCY_THRESHOLDS.any? { |queue, max_latency| queue_under_load?(queue, max_latency) }
  end

  private

  def queue_under_load?(name, max_latency)
    Sidekiq::Queue.new(name).latency > max_latency
  end

  def last_processed_id
    redis.get('account_statuses_cleanup_scheduler:last_account_id')
  end

  def save_last_processed_id(id)
    if id.nil?
      redis.del('account_statuses_cleanup_scheduler:last_account_id')
    else
      redis.set('account_statuses_cleanup_scheduler:last_account_id', id, ex: 1.hour.seconds)
    end
  end
end
