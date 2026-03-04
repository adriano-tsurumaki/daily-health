class Api::V1::FoodController < Api::BaseController
  before_action :set_food, only: [ :show, :update, :destroy ]

  # GET /api/v1/food
  def index
    foods = current_user.food_items.includes(:food_nutrition).order(:name)
    render json: foods.map { |f| food_json(f) }
  end

  # GET /api/v1/food/:id
  def show
    render json: food_json(@food)
  end

  # POST /api/v1/food
  def create
    food = current_user.food_items.build(food_params)

    if food.save
      render json: food_json(food), status: :created
    else
      render_errors(food)
    end
  end

  # PATCH/PUT /api/v1/food/:id
  def update
    if @food.update(food_params)
      render json: food_json(@food)
    else
      render_errors(@food)
    end
  end

  # DELETE /api/v1/food/:id
  def destroy
    @food.soft_delete!
    head :no_content
  end

  private

  def set_food
    @food = current_user.food_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Alimento não encontrado" }, status: :not_found
  end

  def food_params
    params.require(:food).permit(
      :name, :brand, :default_unit,
      food_nutrition_attributes: [
        :id, :basis_amount, :basis_unit,
        :calories, :carbo, :protein, :fat, :fiber, :sugar
      ]
    )
  end

  def food_json(food)
    {
      id: food.id,
      name: food.name,
      brand: food.brand,
      default_unit: food.default_unit,
      food_nutrition: food.food_nutrition ? nutrition_json(food.food_nutrition) : nil
    }
  end

  def nutrition_json(nutrition)
    {
      id: nutrition.id,
      basis_amount: nutrition.basis_amount,
      basis_unit: nutrition.basis_unit,
      calories: nutrition.calories,
      carbo: nutrition.carbo,
      protein: nutrition.protein,
      fat: nutrition.fat,
      fiber: nutrition.fiber,
      sugar: nutrition.sugar
    }
  end
end
