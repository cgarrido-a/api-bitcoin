require 'rails_helper'

RSpec.describe "Transactions API", type: :request do
  let(:user) { User.create(balance_usd: 1000, balance_btc: 0.1) }

  # Simulamos el servicio de Coindesk para devolver un precio fijo de BTC
  before do
    allow(CoindeskService).to receive(:get_btc_price).and_return(50000.0)
  end

  describe "GET /btc_price" do
    it "returns the current price of BTC in USD" do
      get "/users/#{user.id}/btc_price"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['btc_price']).to eq(50000.0)
    end
  end

  describe "POST /transactions" do
    context "when buying BTC" do
      it "creates a buy transaction successfully" do
        transaction_params = {
          transaction: {
            currency_from: 'USD',
            currency_to: 'BTC',
            amount_from: 100,
            transaction_type: 'buy'
          }
        }

        post "/users/#{user.id}/transactions", params: transaction_params
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['amount_to'].to_f).to eq(100 / 50000.0) # cantidad de BTC comprada
      end

      it "returns an error if balance is insufficient" do
        user.update(balance_usd: 50) # Aseguramos que no tenga suficiente balance

        transaction_params = {
          transaction: {
            currency_from: 'USD',
            currency_to: 'BTC',
            amount_from: 100,
            transaction_type: 'buy'
          }
        }

        post "/users/#{user.id}/transactions", params: transaction_params
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Insufficient USD balance')
      end
    end

    context "when selling BTC" do
      it "creates a sell transaction successfully" do
        transaction_params = {
          transaction: {
            currency_from: 'BTC',
            currency_to: 'USD',
            amount_from: 0.01,
            transaction_type: 'sell'
          }
        }

        post "/users/#{user.id}/transactions", params: transaction_params
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['amount_to'].to_f).to eq(0.01 * 50000.0) # cantidad de USD recibida
      end

      it "returns an error if BTC balance is insufficient" do
        user.update(balance_btc: 0.001) # Aseguramos que no tenga suficiente BTC

        transaction_params = {
          transaction: {
            currency_from: 'BTC',
            currency_to: 'USD',
            amount_from: 0.01,
            transaction_type: 'sell'
          }
        }

        post "/users/#{user.id}/transactions", params: transaction_params
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Insufficient BTC balance')
      end
    end
  end

  describe "GET /transactions" do
    it "returns all transactions for a user" do
      # Creamos transacciones de prueba
      user.transactions.create(currency_from: 'USD', currency_to: 'BTC', amount_from: 100, amount_to: 0.002, transaction_type: 'buy')
      user.transactions.create(currency_from: 'BTC', currency_to: 'USD', amount_from: 0.01, amount_to: 500, transaction_type: 'sell')

      get "/users/#{user.id}/transactions"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
    end
  end

  describe "GET /transactions/:id" do
    it "returns the details of a specific transaction" do
      transaction = user.transactions.create(currency_from: 'USD', currency_to: 'BTC', amount_from: 100, amount_to: 0.002, transaction_type: 'buy')

      get "/users/#{user.id}/transactions/#{transaction.id}"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['amount_from'].to_f).to eq(100.0)
      expect(json_response['amount_to'].to_f).to eq(0.002)
    end
  end
end
