class ThesisJavierController < ApplicationController
  require 'ThesisJavierUtilities'
  def index
  end

  #cambiar nombre como el de students.
  def allThesis 
    data=[]
    obj = ThesisJavierUtilities.new()
    thesis = obj.selectAllThesis
    render :json => thesis#data   
  end

end


#data_hash = [{
 #     "name" => "cristian",
  #    "lastName" => "sepulveda cordova",
   #   "memorias" => 2
   # },
    #{
     # "name" => "fabian",
      #"lastName" => "lobos bustos",
      #"memorias" => 4
    #},
    #{
     # "name" => "cristobal",
      #"lastName" => "donoso samame",
      #"memorias" => 6
    #}
  #] 
    #data = data_hash
    #render :json => data 

    #@result = JSON.parse response.to_str
    #@result = obj.selectAllProffesors
    #render json: @result