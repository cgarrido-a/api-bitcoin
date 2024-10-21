Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :users do
    get 'btc_price' => 'transactions#btc_price'
    resources :transactions, only: [:create, :index, :show]
  end
end
