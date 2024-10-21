Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :users do
    resources :transactions, only: [:create, :index, :show]
  end
  get 'btc_price' => 'transactions#btc_price'
  root 'swagger_ui#index'
end
