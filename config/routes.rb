Rails.application.routes.draw do
  resources :student_summaries
  resources :admins
  devise_for :users
  resources :proposals
  resources :professor_summaries
  resources :thesis_summaries
  resources :commentaries
  resources :tasks
  resources :activities
  resources :work_plans
  get "/dataBarGraph", to: "proffesor_javier#dataBarGraph"
  post "/updateTasks", to: "tasks#updateTasks"
  #get "/allStudents", to: "student_javier#allStudents"
  get "/test", to: "student_javier#test"

  #Thesis
  get "/updateThesis", to: "thesis_summaries#updateInfo"

  #Student
  get "/updateStudent", to: "student_summaries#updateInfo"
  get "/allStudents", to: "student_summaries#allStudents"
  post "/studentByEmail", to: "student_summaries#searchByEmail"
  post "/newStudent", to: "student_summaries#newStudent"

  #Professor
  get "/updateProfessor", to: "professor_summaries#updateInfo"
  post "/professorMemorias", to: "professor_summaries#professorMemorias"
  post "/professorByEmail", to: "professor_summaries#searchByEmail"

  #Proposal
  post "/newProposal", to: "proposals#newProposal"
  post "/updateProposal", to: "proposals#updateProposal"
  post "/propuestaStudent", to: "proposals#propuestaEstudiante"
  post "/propuestaProfessor", to: "proposals#propuestaProfesor"
  post "/proposalByEmail", to: "proposals#proposalByEmail"

  #Admin
  post "/adminByEmail", to: "admins#searchByEmail"

  #Topic
  get "/topics", to: "topic_javier#allTopics"

  #Plan
  post "/PlanByEmail", to: "work_plans#PlanByEmail"

  #Graph
  get "/dataTopicPieGraph", to: "graph_service#dataTopicPieGraph"
  get "/dataProgramPieGraph", to: "graph_service#dataProgramPieGraph"
  get "/dataAnhoBarGraph", to: "graph_service#dataAnhoBarGraph"
  get "/dataGradePieGraph", to: "graph_service#dataGradePieGraph"
  get "/dataAcademicPieGraph", to: "graph_service#dataAcademicPieGraph"
  get "/dataMemoriasBarGraph", to: "graph_service#dataMemoriasBarGraph"
  get "/dataMixBarGraph", to: "graph_service#dataMixBarGraph"
  post "/burdownGraph", to: "graph_service#burdownGraph"   
end

