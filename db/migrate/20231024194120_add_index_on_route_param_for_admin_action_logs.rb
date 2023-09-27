# frozen_string_literal: true

class AddIndexOnRouteParamForAdminActionLogs < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :admin_action_logs, [:route_param], algorithm: :concurrently
  end
end
