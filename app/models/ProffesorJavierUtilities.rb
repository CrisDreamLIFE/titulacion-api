class ProffesorJavierUtilities
    #include HTTParty

    #no existe el servicio en django
    def allGrades
        url = 'http://127.0.0.1:8000/tracker/grades/'
        response = RestClient.get url, {Authorization: 'Token ca393b0e830aa77ab90aa8a18fd2877f23091ad2'}
        @a_hash = JSON.parse(response.body)
    end

    def selectAllProffesors
        url = 'http://127.0.0.1:8000/tracker/professor/'
        response = RestClient.get url, {Authorization: 'Token ca393b0e830aa77ab90aa8a18fd2877f23091ad2'}
        @a_hash = JSON.parse(response.body) #hasheamos la respuesta para poder acceder
    end

    def cantidadThesisForProffesor(proffesors)
        cantidadesO = []
        cantidadesC = []
        url = 'http://127.0.0.1:8000/tracker/thesis/'
        thesis = RestClient.get url, {Authorization: 'Token ca393b0e830aa77ab90aa8a18fd2877f23091ad2'}
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