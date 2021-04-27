class StudentSummariesController < ApplicationController
  before_action :set_student_summary, only: [:show, :update, :destroy]

  require 'StudentJavierUtilities'
  require 'TopicJavierUtilities'
  #Update info student
  def updateInfo
    occ = TopicJavierUtilities.new()
    obj = StudentJavierUtilities.new()
    students = obj.selectAllStudent
    programas = occ.selectAllPrograms
    students.each_with_index do |element, index|
      gradoName = nil
      programas.each_with_index do |prog, i|
        if(element["program"]==prog["grade"])
          gradoName = prog["name"]
        end
      end

      if StudentSummary.where(email: element["email"]).empty?
        student = StudentSummary.new(email:element["email"],
                student_id: element["id"],
                name:element["name"],
                first_lastname:element["first_lastname"],
                second_lastname: element["second_lastname"],
                year_income:  element["year_income"],
                program_id: element["program"],  #grade_id
                program_name: gradoName,
                num_temas: 1,#especial,
                num_guias: 1 #especial
                )
        student.save

      
      else
        student = StudentSummary.where(email: element["email"]).take
        student.update(email:element["email"],
                      student_id: element["id"],
                      name:element["name"],
                      first_lastname:element["first_lastname"],
                      second_lastname: element["second_lastname"],
                      year_income:  element["year_income"],
                      program_id: element["program"],  #grade_id
                      program_name: gradoName, #especial
                      num_temas: 1,#especial,
                      num_guias: 1 #especial
              )
      end
    end
  end


  def newStudent
    student = StudentSummary.new(name: params["student_name"], 
                                email: params["student_email"])
    student.save
    render json: student
  end

  def searchByEmail
    puts "el email que me llega"
    puts params["student_email"]
    student =  StudentSummary.where(email: params["student_email"])
    is = false
    if (student.length() ==1)
      student = student[0]
      is = true
      
    else
      student = 0
      #creo cuerpo del json con is=false
    end
    data = {
        "is" => is,
        "student" => student
      }
    render json: data
  end

  def allStudents
    students = StudentSummary.where.not(first_lastname: nil)
    render json: students
  end

  # GET /student_summaries
  def index
    @student_summaries = StudentSummary.all

    render json: @student_summaries
  end

  # GET /student_summaries/1
  def show
    render json: @student_summary
  end

  # POST /student_summaries
  def create
    @student_summary = StudentSummary.new(student_summary_params)

    if @student_summary.save
      render json: @student_summary, status: :created, location: @student_summary
    else
      render json: @student_summary.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /student_summaries/1
  def update
    if @student_summary.update(student_summary_params)
      render json: @student_summary
    else
      render json: @student_summary.errors, status: :unprocessable_entity
    end
  end

  # DELETE /student_summaries/1
  def destroy
    @student_summary.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student_summary
      @student_summary = StudentSummary.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def student_summary_params
      params.require(:student_summary).permit(:student_id, :name, :first_lastname, :second_lastname, :year_income, :email, :program_id, :program_name, :num_temas, :num_guias)
    end
end
