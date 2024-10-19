class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email
      t.decimal :balance_usd
      t.decimal :balance_btc

      t.timestamps
    end
  end
end
