class AddUrlToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :url, :string, null: true, default: nil
  end
end
