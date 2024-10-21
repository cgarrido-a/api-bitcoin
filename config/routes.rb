Rails.application.routes.draw do
  resources :users do
    get 'btc_price', to: 'transactions#btc_price'
    resources :transactions, only: [:create, :index, :show]
  end
end
