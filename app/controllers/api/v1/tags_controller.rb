class Api::V1::TagsController < Api::BaseController
  before_action :set_tag, only: [ :update, :destroy ]

  # GET /api/v1/tags
  def index
    tags = Tag.kept.order(:name)
    render json: tags.map { |t| tag_json(t) }
  end

  # POST /api/v1/tags
  def create
    tag = Tag.new(tag_params)

    if tag.save
      render json: tag_json(tag), status: :created
    else
      render_errors(tag)
    end
  end

  # PATCH/PUT /api/v1/tags/:id
  def update
    if @tag.update(tag_params)
      render json: tag_json(@tag)
    else
      render_errors(@tag)
    end
  end

  # DELETE /api/v1/tags/:id
  def destroy
    @tag.soft_delete!
    head :no_content
  end

  private

  def set_tag
    @tag = Tag.kept.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Tag não encontrada" }, status: :not_found
  end

  def tag_params
    params.require(:tag).permit(:name)
  end

  def tag_json(tag)
    { id: tag.id, name: tag.name }
  end
end
