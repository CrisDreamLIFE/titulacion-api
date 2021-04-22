class ProposalsController < ApplicationController
  require 'student_summary'
  before_action :set_proposal, only: [:show, :update, :destroy]

  # GET /proposals
  def index
    @proposals = Proposal.all

    render json: @proposals
  end

  def newProposal
    student = StudentSummary.where(email: params["student_email"]).take
    if(student["first_lastname"].nil?)
      name = student["name"]
    else
      name = student["name"] + " " + student["first_lastname"] + " "+ student["second_lastname"]
    end
    proposal = Proposal.new(student_id: student["id"], 
                            professor_id:params["professor_id"],
                            topic_id: params["topic_id"],
                            topic_name: params["topic_name"],
                            title: params["title"],
                            summary: params["summary"],
                            rute_document: "", #cuando logre subir archivos, se debe poner aqui la ruta
                            semester: params["semester"],
                            year: params["year"],
                            student_name: name,
                            professor_name: params["professor_name"],
                            #fileTest: params["file"]
                            )
    proposal.save
    prop = Proposal.where(student_id: student["id"]).take
    puts prop.fileTest.blob_id
    render json: prop.fileTest.blob_id
  end

  def updateProposal
    student = StudentSummary.where(email: params["student_email"]).take
    if(student["first_lastname"].nil?)
      name = student["name"]
    else
      name = student["name"] + " " + student["first_lastname"] + " "+ student["second_lastname"]
    end
    proposal = Proposal.where(id: params["id"]).take
    proposal.update(student_id: student["id"], 
              professor_id:params["professor_id"],
              topic_id: params["topic_id"],
              topic_name: params["topic_name"],
              title: params["title"],
              summary: params["summary"],
              rute_document: "", #cuando logre subir archivos, se debe poner aqui la ruta
              semester: params["semester"],
              year: params["year"],
              student_name: name,
              professor_name: params["professor_name"],
              #fileTest: params["file"]
              )
    proposal.save
    render json: 200
  end

  def proposalByEmail
    #estudiante = Proposal.estudianteConCorreo(params["student_email"])
    estudiante = StudentSummary.where(email: params["student_email"]).take
    propuesta = Proposal.where(student_id: estudiante["id"]);
    if (propuesta.length == 0)
      propuesta = 0
    else
      propuesta = propuesta[0]
    end
  
    render json: propuesta
    
  end

  def propuestaProfesor
    #propuesta = Proposal.where(professor_id: params["professor_id"])
    propuesta = Proposal.where(professor_id: 19)
    render json: propuesta
  end

  def propuestaEstudiante
    propuesta = Proposal.where(student_id: params["student_id"])
    puts propuesta
    render json: propuesta[0]
  end

  # GET /proposals/1
  def show
    render json: @proposal
  end

  # POST /proposals
  def create
    @proposal = Proposal.new(proposal_params)

    if @proposal.save
      render json: @proposal, status: :created, location: @proposal
    else
      render json: @proposal.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /proposals/1
  def update
    if @proposal.update(proposal_params)
      render json: @proposal
    else
      render json: @proposal.errors, status: :unprocessable_entity
    end
  end

  # DELETE /proposals/1
  def destroy
    @proposal.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_proposal
      @proposal = Proposal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def proposal_params
      params.require(:proposal).permit(:student_id, :professor_id, :topic_id, :topic_name, :title, :summary, :rute_document)
    end
end
