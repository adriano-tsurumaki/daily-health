class Api::V1::CategoriesController < Api::BaseController
  before_action :set_category, only: [ :update, :destroy ]

  # GET /api/v1/categories
  def index
    categories = current_user.categories.kept.order(:name)
    render json: categories.map { |c| category_json(c) }
  end

  # POST /api/v1/categories
  def create
    category = current_user.categories.build(category_params)

    if category.save
      render json: category_json(category), status: :created
    else
      render_errors(category)
    end
  end

  # PATCH/PUT /api/v1/categories/:id
  def update
    if @category.update(category_params)
      render json: category_json(@category)
    else
      render_errors(@category)
    end
  end

  # DELETE /api/v1/categories/:id
  def destroy
    @category.soft_delete!
    head :no_content
  end

  private

  def set_category
    @category = current_user.categories.kept.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Categoria não encontrada" }, status: :not_found
  end

  def category_params
    params.require(:category).permit(:name)
  end

  def category_json(category)
    { id: category.id, name: category.name }
  end
end
