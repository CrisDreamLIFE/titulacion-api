class ProffesorJavierController < ApplicationController
  require 'ProffesorJavierUtilities'
  def index
  end

  #cambiar nombre como el de students.
  def dataBarGraph 
    data=[]
    obj = ProffesorJavierUtilities.new()
    proffesors = obj.selectAllProffesors
    cantidades = obj.cantidadThesisForProffesor(proffesors)
    proffesors.each_with_index do |element, index|
      data_aux = {
        "id" => element["id"],
        "name" => element["name"],
        "first_lastname" => element["first_lastname"],
        "second_lastname" => element["second_lastname"],
        "grade" => element["grade"],
        "email" => element["email"],
        "avatar" => element["avatar"],
        "tesis_number" => cantidades[index]
      }
      puts (data_aux)
      data[index] = data_aux
    end
    render :json => data   
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