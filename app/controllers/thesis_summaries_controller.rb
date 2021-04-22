class ThesisSummariesController < ApplicationController
  before_action :set_thesis_summary, only: [:show, :update, :destroy]
  require 'ThesisJavierUtilities'

#Update info thesis
  def updateInfo
    obj = ThesisJavierUtilities.new()
    thesis = obj.selectAllThesis
    #render :json => thesis#data
    thesis.each_with_index do |element, index|
      if (ThesisSummary.where(thesis_id: element["id"]).empty?)
        puts "estoy vacio"
        thesis = ThesisSummary.new(thesis_id:element["id"],
                thype_id:element["thesis_type"], #valor que hay que buscar y poner unos id o case para asignar el tipo
                topic:element["topic"],
                program_id: element["student"]["program"],
                status: element["status"],
                year: element["year"],
                semester:element["semester"],
                dias_rev:0,
                guia_name: element["guide"]["name"],
                student_name: element["student"]["name"],
                student_email: element["student"]["email"],
                student_first_lastname: element["student"]["first_lastname"],
                student_second_lastname: element["student"]["second_lastname"],
                title: element["title"],
                guide_id:element["guide"]["id"],
                guia_email:element["guide"]["email"],
                guia_first_lastname: element["guide"]["first_lastname"],
                guia_second_lastname: element["guide"]["second_lastname"]
                )
        thesis.save
      
      else
        puts "ACTUALIZO ----------------->"
      #if !(ThesisSummary.where(thesis_id: element["id"]).empty?)
        thesis = ThesisSummary.where(thesis_id: element["id"]).take
                thesis.update(thesis_id:element["id"],
                thype_id:element["thesis_type"], #valor que hay que buscar y poner unos id o case para asignar el tipo
                topic:element["topic"],
                program_id: element["student"]["program"],
                status: element["status"],
                year: element["year"],
                semester:element["semester"],
                dias_rev:0,
                guia_name: element["guide"]["name"],
                student_name: element["student"]["name"],
                student_email: element["student"]["email"],
                student_first_lastname: element["student"]["first_lastname"],
                student_second_lastname: element["student"]["second_lastname"],
                title: element["title"],
                guide_id:element["guide"]["id"],
                guia_email:element["guide"]["email"],
                guia_first_lastname: element["guide"]["first_lastname"],
                guia_second_lastname: element["guide"]["second_lastname"]
        )
      end
    end
  end

  # GET /thesis_summaries
  def index
    @thesis_summaries = ThesisSummary.all.order(year: :desc)#(:name, email: :desc)

    render json: @thesis_summaries
  end

  # GET /thesis_summaries/1
  def show
    render json: @thesis_summary
  end

  # POST /thesis_summaries
  def create
    @thesis_summary = ThesisSummary.new(thesis_summary_params)

    if @thesis_summary.save
      render json: @thesis_summary, status: :created, location: @thesis_summary
    else
      render json: @thesis_summary.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /thesis_summaries/1
  def update
    if @thesis_summary.update(thesis_summary_params)
      render json: @thesis_summary
    else
      render json: @thesis_summary.errors, status: :unprocessable_entity
    end
  end

  # DELETE /thesis_summaries/1
  def destroy
    @thesis_summary.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_thesis_summary
      @thesis_summary = ThesisSummary.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def thesis_summary_params
      params.require(:thesis_summary).permit(:thesis_id, :thype_id, :topic_id, :program_id, :status, :year, :semester, :dias_rev)
    end
end
