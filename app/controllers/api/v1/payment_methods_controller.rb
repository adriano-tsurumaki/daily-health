class Api::V1::PaymentMethodsController < Api::BaseController
  before_action :set_payment_method, only: [ :update, :destroy ]

  def index
    payment_methods = payment_methods_scope.order(:kind, :name)
    render json: payment_methods.map { |payment_method| payment_method_json(payment_method) }
  end

  def create
    payment_method = current_user.payment_methods.build(payment_method_params)

    if payment_method.save
      render json: payment_method_json(payment_method), status: :created
    else
      render_errors(payment_method)
    end
  end

  def update
    if @payment_method.update(payment_method_params)
      render json: payment_method_json(@payment_method)
    else
      render_errors(@payment_method)
    end
  end

  def destroy
    @payment_method.soft_delete!
    head :no_content
  end

  private

  def set_payment_method
    @payment_method = payment_methods_scope.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Metodo de pagamento nao encontrado" }, status: :not_found
  end

  def payment_methods_scope
    PaymentMethod.kept.where(user_id: [ current_user.id, nil ])
  end

  def payment_method_params
    params.require(:payment_method).permit(
      :name, :locale, :identifier, :kind, :is_active, :display_color,
      :closing_day, :due_day, :credit_limit
    )
  end

  def payment_method_json(payment_method)
    {
      id: payment_method.id,
      name: payment_method.name,
      locale: payment_method.locale,
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
end
