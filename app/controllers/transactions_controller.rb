class TransactionsController < ApplicationController
    before_action :set_user
  
    # Obtener el precio de BTC en tiempo real
    def btc_price
      btc_price = CoindeskService.get_btc_price
      render json: { btc_price: btc_price }, status: :ok
    end
  
    # Crear una transacción de compra o venta
    def create
      btc_price = CoindeskService.get_btc_price
      transaction = @user.transactions.build(transaction_params)
  
      if transaction.currency_from == 'USD'
        transaction.amount_to = transaction.amount_from / btc_price
        if @user.balance_usd >= transaction.amount_from
          @user.balance_usd -= transaction.amount_from
          @user.balance_btc += transaction.amount_to
        else
          return render json: { error: 'Insufficient USD balance' }, status: :unprocessable_entity
        end
      elsif transaction.currency_from == 'BTC'
        transaction.amount_to = transaction.amount_from * btc_price
        if @user.balance_btc >= transaction.amount_from
          @user.balance_btc -= transaction.amount_from
          @user.balance_usd += transaction.amount_to
        else
          return render json: { error: 'Insufficient BTC balance' }, status: :unprocessable_entity
        end
      else
        return render json: { error: 'Invalid currency' }, status: :unprocessable_entity
      end
  
      if transaction.save && @user.save
        render json: transaction, status: :created
      else
        render json: transaction.errors, status: :unprocessable_entity
      end
    end
  
    # Listar las transacciones de un usuario
    def index
      transactions = @user.transactions
      render json: transactions, status: :ok
    end
  
    # Mostrar una transacción en detalle
    def show
      transaction = @user.transactions.find(params[:id])
      render json: transaction, status: :ok
    end
  
    private
  
    def set_user
        @user = User.find(params[:user_id] || 1) # Se podría usar un sistema de autenticación
    end
  
    def transaction_params
      params.require(:transaction).permit(:currency_from, :currency_to, :amount_from, :transaction_type)
    end
  end
  