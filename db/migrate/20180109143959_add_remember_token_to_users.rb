class AddRememberTokenToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :remember_token, :string, null: true
  end
end
