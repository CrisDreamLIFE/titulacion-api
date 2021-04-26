class WorkPlansController < ApplicationController
  require 'work_plan'
  require 'activity'
  require 'thesis_summary'

  
  # GET /work_plans
  def index
    @work_plans = WorkPlan.all

    render json: @work_plans
  end

  # GET /work_plans/1
  def show
    render json: @work_plan
  end

  # POST /work_plans
  def createWork
    email = params["student_email"]
    tesis_all = ThesisSummary.where(student_email: email)
    tesis_id = nil
    tesis_all.each_with_index do |tesis, i|
      if(tesis["status"] == "OP")
        tesis_id = tesis["id"]
        break  
      end
    end
    work_plan = WorkPlan.new(state: "pendiente",
                              trabajo_titulacion: false,
                              activity_pending: 0,
                              activity_finished: 0,
                              thesis_id: tesis_id,
                              student_email: email
                              )

    if work_plan.save
      params["activity"].each_with_index do |element, index|
        @activity = Activity.new(title:element["title"],
                              start_date:element["start_date"],
                              end_date:element["end_date"],
                              state: "pendiente",
                              work_plan_id: work_plan["id"],
                              task_finished: 0,
                              task_pending:0  

                              )
        @activity.save
      end
      render json: work_plan, status: :created, location: work_plan
    else
      render json: work_plan.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /work_plans/1
  def update
    if @work_plan.update(work_plan_params)
      render json: @work_plan
    else
      render json: @work_plan.errors, status: :unprocessable_entity
    end
  end

  # DELETE /work_plans/1
  def destroy
    @work_plan.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_plan
      @work_plan = WorkPlan.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def work_plan_params
      params.require(:work_plan).permit(:state, :suscription, :actividades_pendientes, :actividades_realizadas)
    end
end