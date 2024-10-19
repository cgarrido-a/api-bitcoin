class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :currency_from
      t.string :currency_to
      t.decimal :amount_from
      t.decimal :amount_to
      t.string :transaction_type

      t.timestamps
    end
  end
end
