class ProfessorSummariesController < ApplicationController
  before_action :set_professor_summary, only: [:show, :update, :destroy]

  require 'TopicJavierUtilities'
  require 'thesis_summary'

  #Update info thesis
  def updateInfo
    occ = TopicJavierUtilities.new()
    obj = ProffesorJavierUtilities.new()
    ooo = ProfessorSummary.new()
    proffesors = obj.selectAllProffesors
    cantidades = obj.cantidadThesisForProffesor(proffesors)
    medias = ooo.finalMediaXProfesor(proffesors)
    programas = occ.selectAllPrograms
    proffesors.each_with_index do |element, index|
      gradoName = nil
      programas.each_with_index do |prog, i|
        if(element["grade"]==prog["grade"])
          gradoName = prog["name"]
        end
      end
      if ProfessorSummary.where(email: element["email"]).empty?
        thesis = ProfessorSummary.new(email:element["email"],
                name:element["name"], #valor que hay que buscar y poner unos id o case para asignar el tipo
                first_lastname:element["first_lastname"],
                second_lastname: element["second_lastname"],
                grade: element["grade"],
                grade_name: gradoName,
                email: element["email"],
                avatar:element["avatar"],
                num_tesis: cantidades[0][index], 
                num_tesis_tot: cantidades[0][index] + cantidades[1][index],
                num_tesis_med: medias[index], #especial
                asignadas: element["assigned"],
                dias_rev_med: 0, #especial
                academic: element["academic"],
                num_tesis_abandonadas: 5, #especial
                tiempo_final_med: 1.3 #especial
                #opicos: element["topics"]
                )
        thesis.save

      
      else
        thesis = ProfessorSummary.where(email: element["email"]).take
        thesis.update(email:element["email"],
                name:element["name"], #valor que hay que buscar y poner unos id o case para asignar el tipo
                first_lastname:element["first_lastname"],
                second_lastname: element["second_lastname"],
                grade: element["grade"],
                grade_name: gradoName,
                email: element["email"],
                avatar:element["avatar"],
                num_tesis: cantidades[0][index], 
                num_tesis_tot: cantidades[0][index] + cantidades[1][index], 
                num_tesis_med: medias[index], #especial
                asignadas: element["assigned"],
                dias_rev_med: 0, #especial
                academic: element["academic"],
                num_tesis_abandonadas: 5, #especial
                tiempo_final_med: 1.3 #especial
                #topicos: element["topics"]
              )
      end
    end
  end

  def searchByEmail
    professor =  ProfessorSummary.where(email: params["professor_email"])
    is = false
    puts "el admin"
    puts professor[0]
    puts "df"
    if (professor.length() ==1)
      professor = professor[0]
      is = true
      
    else
      professor = 0
      #creo cuerpo del json con is=false
    end
    data = {
        "is" => is,
        "professor" => professor
      }
    render json: data
  end

  def professorMemorias
    puts "email que me llega"
    puts params["guia_email"]
    tesis_all = ThesisSummary.where(guia_email: params["guia_email"])
    if tesis_all.length == 0
      tesis_all = 0
    end
    render json: tesis_all
  end

  # GET /professor_summaries
  def index
    @professor_summaries = ProfessorSummary.all.order(:first_lastname)#(:name, email: :desc)

    render json: @professor_summaries
  end

  # GET /professor_summaries/1
  def show
    render json: @professor_summary
  end

  # POST /professor_summaries
  def create
    @professor_summary = ProfessorSummary.new(professor_summary_params)

    if @professor_summary.save
      render json: @professor_summary, status: :created, location: @professor_summary
    else
      render json: @professor_summary.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /professor_summaries/1
  def update
    if @professor_summary.update(professor_summary_params)
      render json: @professor_summary
    else
      render json: @professor_summary.errors, status: :unprocessable_entity
    end
  end

  # DELETE /professor_summaries/1
  def destroy
    @professor_summary.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_professor_summary
      @professor_summary = ProfessorSummary.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def professor_summary_params
      params.require(:professor_summary).permit(:professor_id, :name, :first_lastname, :second_lastname, :grade, :email, :avatar, :num_tesis, :num_tesis_med, :asignadas, :topicos, :dias_rev_med, :academic, :num_tesis_abandonadas, :tiempo_final_med)
    end
end
