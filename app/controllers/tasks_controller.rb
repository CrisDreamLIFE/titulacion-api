class TasksController < ApplicationController
  before_action :set_task, only: [:show, :update, :destroy]

  # GET /tasks
  def index
    @tasks = Task.all

    render json: @tasks
  end

  # GET /tasks/1
  def show
    render json: @task
  end

  # POST /tasks
  def create
    puts "estoy en el post de tasks"
    activity = params["activity"]
    params["tasks"].each_with_index do |element, index|
      @task = Task.new(title:element["title"],
                            start_date:element["start_date"],
                            end_date:element["end_date"],
                            state: "pendiente",
                            activity_id: activity
                            )
      @task.save
    end
  end


  #PATCH/PUT /list[tasks] se puede iotimizar que se mande solo el que cambió
  def updateTasks
    activity = params["activity"] 
    params["tasks"].each_with_index do |element, index|
      task = Task.find(element["id"])
      task.update(state: element["state"])
    end
  end


  # PATCH/PUT /tasks/1
  def update
    if @task.update(task_params)
      render json: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:title, :state, :start_date, :end_date, :close_date)
    end
end
