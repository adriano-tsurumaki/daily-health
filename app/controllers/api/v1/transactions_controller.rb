class Api::V1::TransactionsController < Api::BaseController
  before_action :set_transaction, only: [ :show, :update, :destroy ]

  def index
    transactions = current_user.transactions.kept
      .includes(:payment_method, :category, :tags, :transaction_items, :installment_plan, :recurrence)
      .select { |transaction| transaction.period_bucket == selected_bucket }
      .sort_by { |transaction| [ transaction.commitment_date || Date.current, transaction.created_at ] }
      .reverse

    render json: transactions.map { |transaction| transaction_json(transaction) }
  end

  def show
    render json: transaction_json(@transaction)
  end

  def create
    transaction =
      if installment_plan_requested?
        create_transaction_with_installments!
      else
        attrs = base_transaction_attributes.merge(
          tag_ids: transaction_params[:tag_ids]
        )

        if transaction_params[:transaction_items_attributes].present?
          attrs[:transaction_items_attributes] = transaction_params[:transaction_items_attributes]
        end

        current_user.transactions.create!(attrs)
      end

    render json: transaction_json(transaction.reload), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render_errors(e.record)
  end

  def update
    if @transaction.update(transaction_params.except(:installment_plan_attributes))
      render json: transaction_json(@transaction.reload)
    else
      render_errors(@transaction)
    end
  end

  def destroy
    @transaction.soft_delete!
    head :no_content
  end

  private

  def set_transaction
    @transaction = current_user.transactions.kept
      .includes(:payment_method, :category, :tags, :transaction_items, :installment_plan, :recurrence)
      .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Transacao nao encontrada" }, status: :not_found
  end

  def transaction_params
    params.require(:transaction).permit(
      :amount, :description, :merchant_name, :payment_date, :due_date, :transaction_type, :status,
      :payment_method_id, :category_id, :recurrence_id,
      tag_ids: [],
      installment_plan_attributes: [ :name, :total_installments, :interval_in_months ],
      transaction_items_attributes: [ :id, :name, :quantity, :unit_of_measure, :unit_price, :_destroy ]
    )
  end

  def transaction_json(transaction)
    {
      id: transaction.id,
      amount: transaction.amount,
      description: transaction.description,
      merchant_name: transaction.merchant_name,
      payment_date: transaction.payment_date,
      due_date: transaction.due_date,
      transaction_type: transaction.transaction_type,
      status: transaction.status,
      review_status: transaction.review_status,
      entry_state: transaction.entry_state,
      period_bucket: transaction.period_bucket,
      payment_method: transaction.payment_method ? payment_method_json(transaction.payment_method) : nil,
      category: transaction.category ? category_json(transaction.category) : nil,
      recurrence: transaction.recurrence ? recurrence_json(transaction.recurrence) : nil,
      installment_plan: transaction.installment_plan ? installment_plan_json(transaction) : nil,
      tags: transaction.tags.map { |tag| tag_json(tag) },
      transaction_items: transaction.transaction_items.map { |item| transaction_item_json(item) }
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

  def payment_method_json(payment_method)
    {
      id: payment_method.id,
      name: payment_method.name,
      identifier: payment_method.identifier,
      kind: payment_method.kind,
      is_active: payment_method.is_active,
      display_color: payment_method.display_color,
      closing_day: payment_method.closing_day,
      due_day: payment_method.due_day,
      credit_limit: payment_method.credit_limit,
      review_status: payment_method.review_status
    }
  end

  def category_json(category)
    {
      id: category.id,
      name: category.name,
      monthly_limit: category.monthly_limit,
      color: category.color
    }
  end

  def recurrence_json(recurrence)
    {
      id: recurrence.id,
      name: recurrence.name,
      amount: recurrence.amount,
      frequency: recurrence.frequency,
      recurrence_interval: recurrence.recurrence_interval,
      next_due_date: recurrence.next_due_date,
      end_date: recurrence.end_date,
      is_active: recurrence.is_active
    }
  end

  def installment_plan_json(transaction)
    plan = transaction.installment_plan

    {
      id: plan.id,
      name: plan.name,
      total_amount: plan.total_amount,
      total_installments: plan.total_installments,
      current_installment: transaction.installment_position,
      interval_in_months: plan.interval_in_months
    }
  end

  def tag_json(tag)
    { id: tag.id, name: tag.name }
  end

  def selected_bucket
    month = (params[:month] || Date.current.month).to_i
    year = (params[:year] || Date.current.year).to_i
    format("%<year>04d-%<month>02d", year: year, month: month)
  end

  def installment_plan_requested?
    installment_attrs = transaction_params[:installment_plan_attributes]
    installment_attrs.present? && installment_attrs[:total_installments].to_i > 1
  end

  def base_transaction_attributes
    transaction_params.except(
      :tag_ids,
      :transaction_items_attributes,
      :installment_plan_attributes
    ).to_h
  end

  def create_transaction_with_installments!
    attrs = base_transaction_attributes
    payment_date = Date.parse(attrs["payment_date"].to_s)
    due_date = attrs["due_date"].present? ? Date.parse(attrs["due_date"].to_s) : nil
    installment_attrs = transaction_params[:installment_plan_attributes]
    total_installments = installment_attrs[:total_installments].to_i
    interval_in_months = [ installment_attrs[:interval_in_months].to_i, 1 ].max
    amounts = split_installments(attrs["amount"], total_installments)
    first_transaction = nil

    Transaction.transaction do
      plan = current_user.installment_plans.create!(
        name: installment_attrs[:name].presence || attrs["description"],
        description: attrs["description"],
        total_amount: attrs["amount"],
        total_installments: total_installments,
        interval_in_months: interval_in_months,
        start_date: payment_date,
        end_date: payment_date >> ((total_installments - 1) * interval_in_months),
        category_id: attrs["category_id"],
        payment_method_id: attrs["payment_method_id"]
      )

      total_installments.times do |index|
        scheduled_payment_date = payment_date >> (index * interval_in_months)
        scheduled_due_date = due_date.present? ? due_date >> (index * interval_in_months) : nil

        transaction = current_user.transactions.create!(
          attrs.merge(
            "amount" => amounts[index],
            "payment_date" => scheduled_payment_date,
            "due_date" => scheduled_due_date,
            "status" => index.zero? ? attrs["status"] : "pending",
            "installment_plan_id" => plan.id,
            "installment_position" => index + 1
          )
        )

        transaction.tag_ids = transaction_params[:tag_ids] if transaction_params[:tag_ids].present?
        if index.zero? && transaction_params[:transaction_items_attributes].present?
          transaction.update!(
            transaction_items_attributes: transaction_params[:transaction_items_attributes]
          )
        end

        first_transaction ||= transaction
      end
    end

    first_transaction
  end

  def split_installments(total_amount, total_installments)
    total_cents = (BigDecimal(total_amount.to_s) * 100).round(0).to_i
    base_cents, extra_cents = total_cents.divmod(total_installments)

    Array.new(total_installments) do |index|
      cents = base_cents + (index < extra_cents ? 1 : 0)
      BigDecimal(cents.to_s) / 100
    end
  end
end
