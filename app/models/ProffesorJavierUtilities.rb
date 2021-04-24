class ProffesorJavierUtilities
    #include HTTParty

    #no existe el servicio en django
    def allGrades
        url = 'http://ec2-100-25-103-59.compute-1.amazonaws.com/tracker/grades/'
        response = RestClient.get url, {Authorization: 'Token b99aa300d382f7491e0e6103d8cf5cd55aeecc3e'}
        @a_hash = JSON.parse(response.body)
    end

    def selectAllProffesors
        url = 'http://ec2-100-25-103-59.compute-1.amazonaws.com/tracker/professor/'
        response = RestClient.get url, {Authorization: 'Token b99aa300d382f7491e0e6103d8cf5cd55aeecc3e'}
        @a_hash = JSON.parse(response.body) #hasheamos la respuesta para poder acceder
    end

    def cantidadThesisForProffesor(proffesors)
        cantidadesO = []
        cantidadesC = []
        url = 'http://ec2-100-25-103-59.compute-1.amazonaws.com/tracker/thesis/'
        thesis = RestClient.get url, {Authorization: 'Token b99aa300d382f7491e0e6103d8cf5cd55aeecc3e'}
        thesis = JSON.parse(thesis.body)
        b = 0
        lenProf = proffesors.length
        lenThes = thesis.length
        while b < lenProf
            contadorO = 0
            contadorC = 0
            a = 0
            while a < lenThes
                if thesis[a]["guide"].present?
                    if thesis[a]["status"] != 'CL'
                        if(thesis[a]["guide"]["professor_id"].eql? proffesors[b]['id'])
                            contadorO = contadorO+1
                        end
                    else
                        if(thesis[a]["guide"]["professor_id"].eql? proffesors[b]['id'])
                            contadorC = contadorC+1
                        end 
                    end
                end
                a = a +1
            end
            cantidadesO.push(contadorO)
            cantidadesC.push(contadorC)
            b = b+1
        end
        cantidadesTot= []
        cantidadesTot.push(cantidadesO)
        cantidadesTot.push(cantidadesC)
        cantidadesTot #hasheamos la respuesta para poder acceder
    end

end