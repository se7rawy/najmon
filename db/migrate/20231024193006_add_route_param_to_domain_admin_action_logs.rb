# frozen_string_literal: true

class AddRouteParamToDomainAdminActionLogs < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    Admin::ActionLog.unscoped.where(target_type: %w(DomainBlock DomainAllow Instance UnavailableDomain)).find_each do |action_log|
      # We don't actually need to look at the target, as the human identifier is
      # the value we want for the route_param
      action_log.update(route_param: action_log.human_identifier)
    end
  end

  def down; end
end
