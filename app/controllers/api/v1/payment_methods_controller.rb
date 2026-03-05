class Api::V1::PaymentMethodsController < Api::BaseController
  before_action :set_payment_method, only: [ :update, :destroy ]

  # GET /api/v1/payment_methods
  def index
    payment_methods = PaymentMethod.kept.order(:name)
    render json: payment_methods.map { |pm| payment_method_json(pm) }
  end

  # POST /api/v1/payment_methods
  def create
    payment_method = PaymentMethod.new(payment_method_params)

    if payment_method.save
      render json: payment_method_json(payment_method), status: :created
    else
      render_errors(payment_method)
    end
  end

  # PATCH/PUT /api/v1/payment_methods/:id
  def update
    if @payment_method.update(payment_method_params)
      render json: payment_method_json(@payment_method)
    else
      render_errors(@payment_method)
    end
  end

  # DELETE /api/v1/payment_methods/:id
  def destroy
    @payment_method.soft_delete!
    head :no_content
  end

  private

  def set_payment_method
    @payment_method = PaymentMethod.kept.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Método de pagamento não encontrado" }, status: :not_found
  end

  def payment_method_params
    params.require(:payment_method).permit(:name, :locale, :identifier)
  end

  def payment_method_json(pm)
    { id: pm.id, name: pm.name, locale: pm.locale, identifier: pm.identifier }
  end
end
