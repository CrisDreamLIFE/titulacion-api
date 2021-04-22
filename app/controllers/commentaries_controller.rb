class CommentariesController < ApplicationController
  before_action :set_commentary, only: [:show, :update, :destroy]

  # GET /commentaries
  def index
    @commentaries = Commentary.all

    render json: @commentaries
  end

  # GET /commentaries/1
  def show
    render json: @commentary
  end

  # POST /commentaries
  def create
    @commentary = Commentary.new(commentary_params)

    if @commentary.save
      render json: @commentary, status: :created, location: @commentary
    else
      render json: @commentary.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /commentaries/1
  def update
    if @commentary.update(commentary_params)
      render json: @commentary
    else
      render json: @commentary.errors, status: :unprocessable_entity
    end
  end

  # DELETE /commentaries/1
  def destroy
    @commentary.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commentary
      @commentary = Commentary.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def commentary_params
      params.require(:commentary).permit(:message, :issuer_id, :issuer_date, :state)
    end
end
