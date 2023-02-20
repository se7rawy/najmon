class CreateAccountDomainBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :account_domain_blocks do |t|
      t.integer :account_id
      t.string :domain

      t.timestamps
    end

    add_index :account_domain_blocks, %i(account_id domain), unique: true
  end
end
