# spec/integration/transactions_spec.rb
require 'swagger_helper'

RSpec.describe 'Transactions API' do
  path '/users/{user_id}/transactions' do
    post 'Creates a transaction' do
      tags 'Transactions'
      consumes 'application/json'
      parameter name: :user_id, in: :path, type: :string, required: true
      parameter name: :transaction, in: :body, required: true, schema: {
        type: :object,
        properties: {
          currency_from: { type: :string },
          currency_to: { type: :string },
          amount_from: { type: :number },
          transaction_type: { type: :string }
        },
        required: %w[currency_from currency_to amount_from transaction_type]
      }

      let(:user) { create(:user) }
      let(:user_id) { user.id }
      let(:transaction) { { currency_from: 'USD', currency_to: 'BTC', amount_from: 100, transaction_type: 'buy' } }

      response '201', 'transaction created' do
        run_test! do |response|
          expect(response).to have_http_status(201)
        end
      end

      response '422', 'invalid request' do
        let(:transaction) { { currency_from: 'INVALID', amount_from: 100 } }
        run_test!
      end
    end
  end

  path '/users/{user_id}/transactions/{id}' do
    get 'Retrieves a transaction' do
      tags 'Transactions'
      produces 'application/json'
      parameter name: :user_id, in: :path, type: :string, required: true
      parameter name: :id, in: :path, type: :string

      let(:user) { create(:user) }
      let(:user_id) { user.id }
      let(:id) { create(:transaction, user: user).id }

      response '200', 'transaction found' do
        run_test!
      end

      response '404', 'transaction not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/btc_price' do
    get 'Retrieves the current BTC price' do
      tags 'BTC Price'
      produces 'application/json'
      
      response '200', 'price found' do
        run_test! do |response|
          expect(response).to have_http_status(200)
          # Puedes agregar aquí más expectativas, como verificar el formato de la respuesta
        end
      end
      
      response '422', 'invalid request' do
        run_test! do |response|
          expect(response).to have_http_status(422)
        end
      end
    end
  end
  
end
