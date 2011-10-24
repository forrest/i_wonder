class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.boolean :active
      
      t.timestamps
    end
  end
end
