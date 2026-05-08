class Api::V1::RecurrencesController < Api::BaseController
  before_action :set_recurrence, only: [ :show, :update, :destroy ]

  def index
    recurrences = current_user.recurrences.kept.includes(:category, :payment_method).order(:next_due_date)
    render json: recurrences.map { |recurrence| recurrence_json(recurrence) }
  end

  def show
    render json: recurrence_json(@recurrence)
  end

  def create
    recurrence = current_user.recurrences.build(recurrence_params)

    if recurrence.save
      render json: recurrence_json(recurrence), status: :created
    else
      render_errors(recurrence)
    end
  end

  def update
    if @recurrence.update(recurrence_params)
      render json: recurrence_json(@recurrence)
    else
      render_errors(@recurrence)
    end
  end

  def destroy
    @recurrence.soft_delete!
    head :no_content
  end

  private

  def set_recurrence
    @recurrence = current_user.recurrences.kept.includes(:category, :payment_method).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recorrência não encontrada" }, status: :not_found
  end

  def recurrence_params
    params.require(:recurrence).permit(
      :name, :amount, :category_id, :payment_method_id,
      :frequency, :recurrence_interval, :next_due_date, :end_date, :is_active
    )
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
      is_active: recurrence.is_active,
      review_status: recurrence.review_status,
      category: recurrence.category ? category_json(recurrence.category) : nil,
      payment_method: recurrence.payment_method ? payment_method_json(recurrence.payment_method) : nil,
      projection: {
        next_3_months: recurrence.projected_total(3),
        next_6_months: recurrence.projected_total(6),
        next_12_months: recurrence.projected_total(12)
      },
      upcoming_occurrences: recurrence.occurrences_between(Date.current, Date.current >> 12).first(6)
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

  def payment_method_json(payment_method)
    {
      id: payment_method.id,
      name: payment_method.name,
      kind: payment_method.kind,
      display_color: payment_method.display_color,
      review_status: payment_method.review_status
    }
  end
end
