class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :update, :destroy]
  #state:  "finalizada","proceso","pendiente"
  # GET /activities
  def index
    @data=[]
    activities = Activity.where(work_plan_id: params["work_plan_id"])#order(created_at: :asc)
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
        aux_task[i] = aux
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
      @data[index] = data_aux
    end
    render json: @data
  end

  # GET /activities/1
  def show
    render json: @activity
  end

  # POST /activities
  def create
    params["activity"].each_with_index do |element, index|
      puts element["title"]
    work_plan = params["work_plan_id"]
      @activity = Activity.new(title:element["title"],
                            start_date:element["start_date"],
                            end_date:element["end_date"],
                            state: "pendiente",
                            work_plan_id: work_plan,
                            task_finished: 0,
                            task_pending:0
                            )
      @activity.save
      #if @activity.save
       # render json: @activity, status: :created, location: @activity
      #else
       # render json: @activity.errors, status: :unprocessable_entity
      #end
    end

    
  end

  # PATCH/PUT /activities/1
  def update
    if @activity.update(activity_params)
      render json: @activity
    else
      render json: @activity.errors, status: :unprocessable_entity
    end
  end

  # DELETE /activities/1
  def destroy
    @activity.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def activity_params
      #params.require(:activity).permit(:title, :state, :start_date, :end_date, :close_date, :tareas_pendientes, :tareas_realizadas)
      params.require(:activity)
    end
end
