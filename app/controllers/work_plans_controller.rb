class WorkPlansController < ApplicationController
  require 'work_plan'
  require 'activity'
  require 'thesis_summary'

  def PlanByEmail
    email = params["student_email"]
    tesis_all = ThesisSummary.where(student_email: email)
    tesis_id = nil
    data=[]
    puts "fuerq del if"
    puts tesis_all[0]
    if(tesis_all.length == 0)
      puts "entre al if"
      data[0]=0
    else
      puts "en el else"
      tesis_all.each_with_index do |tesis, i|
        if(tesis["status"] == "OP")
          tesis_id = tesis["id"]
          break  
        end
      end
      puts "el valor del id:"
      puts tesis_id
      plan = WorkPlan.where(thesis_id: tesis_id)
      if(plan.length == 0)
        data[0]=-1  
      else
        activities = Activity.where(work_plan_id: plan[0]["id"])#order(created_at: :asc)
        activities.each_with_index do |element, index|
          tasks = element.task.order(state: :desc)
          commentaries = element.commentary
          aux_task =[]
          aux_commentary=[]
          tasks.each_with_index do |task, i|
            aux = {
              "activity_id" =>task["id"],
              "close_date" =>task["close_date"],
              "created_at" =>task["created_at"],
              "end_date" =>task["end_date"],
              "id" =>task["id"].to_s,
              "start_date" =>task["start_date"],
              "state" =>task["state"],
              "title" =>task["title"],
              "updated_at" =>task["updated_at"],
            }
            aux_task.push(aux)
          end
          commentaries.each_with_index do |commentary, j|
            #traer el nombre del issuer (autor)
            aux2 = {
              "message" =>commentary["message"],
              "issuer_name" =>"Pepito",
              "issuer_id" =>commentary["issuer_id"],
              "issuer_date" =>commentary["issuer_date"],
              "state" =>commentary["state"],
              "id" =>commentary["id"].to_s
            }
            aux_commentary[j] = aux2
          end
          data_aux = {
            "id" => element["id"],
            "title" => element["title"],
            "state" => element["state"],
            "start_date" => element["start_date"],
            "end_date" => element["end_date"],
            "close_date" => element["close_date"],
            "task_pending" => element["task_pending"],
            "task_finished" => element["task_finished"],
            "tasks" => aux_task,
            "commentaries" => aux_commentary
          }
          data[index] = data_aux
        end
      end
    end
    final = []
    final[0] = plan
    final[1] = data
    render json: final
  end

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
  def create
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
                              thesis_id: tesis_id
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