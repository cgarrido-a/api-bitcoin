FactoryBot.define do
    factory :transaction do
      currency_from { 'USD' }
      currency_to { 'BTC' }
      amount_from { 100 }
      amount_to { 0.002 }
      transaction_type { 'buy' }
      association :user
    end
  end