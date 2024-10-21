FactoryBot.define do
    factory :user do
      balance_usd { 1000 }
      balance_btc { 0.1 }
    end
  end