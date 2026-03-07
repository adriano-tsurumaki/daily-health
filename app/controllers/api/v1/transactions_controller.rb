class Api::V1::TransactionsController < Api::BaseController
  before_action :set_transaction, only: [ :show, :update, :destroy ]

  # GET /api/v1/transactions
  def index
    month = (params[:month] || Date.current.month).to_i
    year = (params[:year] || Date.current.year).to_i
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    transactions = current_user.transactions.kept
      .where(payment_date: start_date..end_date)
      .includes(:payment_method, :category, :tags, :transaction_items)
      .order(payment_date: :desc)

    render json: transactions.map { |t| transaction_json(t) }
  end

  # GET /api/v1/transactions/:id
  def show
    render json: transaction_json(@transaction)
  end

  # POST /api/v1/transactions
  def create
    transaction = current_user.transactions.build(transaction_params)

    if transaction.save
      render json: transaction_json(transaction.reload), status: :created
    else
      render_errors(transaction)
    end
  end

  # PATCH/PUT /api/v1/transactions/:id
  def update
    if @transaction.update(transaction_params)
      render json: transaction_json(@transaction.reload)
    else
      render_errors(@transaction)
    end
  end

  # DELETE /api/v1/transactions/:id
  def destroy
    @transaction.soft_delete!
    head :no_content
  end

  private

  def set_transaction
    @transaction = current_user.transactions.kept
      .includes(:payment_method, :category, :tags, :transaction_items)
      .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Transação não encontrada" }, status: :not_found
  end

  def transaction_params
    params.require(:transaction).permit(
      :amount, :payment_date, :transaction_type, :status,
      :payment_method_id, :category_id,
      tag_ids: [],
      transaction_items_attributes: [ :id, :name, :quantity, :unit_of_measure, :unit_price, :_destroy ]
    )
  end

  def transaction_json(transaction)
    {
      id: transaction.id,
      amount: transaction.amount,
      payment_date: transaction.payment_date,
      transaction_type: transaction.transaction_type,
      status: transaction.status,
      payment_method: transaction.payment_method ? payment_method_json(transaction.payment_method) : nil,
      category: transaction.category ? category_json(transaction.category) : nil,
      tags: transaction.tags.map { |t| tag_json(t) },
      transaction_items: transaction.transaction_items.map { |i| transaction_item_json(i) }
    }
  end

  def transaction_item_json(item)
    {
      id: item.id,
      name: item.name,
      quantity: item.quantity,
      unit_of_measure: item.unit_of_measure,
      unit_price: item.unit_price,
      total: item.total
    }
  end

  def payment_method_json(pm)
    { id: pm.id, name: pm.name, identifier: pm.identifier }
  end

  def category_json(cat)
    { id: cat.id, name: cat.name }
  end

  def tag_json(tag)
    { id: tag.id, name: tag.name }
  end
end
