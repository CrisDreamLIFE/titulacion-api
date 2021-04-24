class TopicJavierUtilities
    #include HTTParty

    def selectAllTopics
        url = 'http://ec2-100-25-103-59.compute-1.amazonaws.com/tracker/topic/'
        response = RestClient.get url, {Authorization: 'Token b99aa300d382f7491e0e6103d8cf5cd55aeecc3e'}
        @a_hash = JSON.parse(response.body) #hasheamos la respuesta para poder acceder
    end

    def selectAllPrograms
        url = 'http://ec2-100-25-103-59.compute-1.amazonaws.com/tracker/program'
        response = RestClient.get url, {Authorization: 'Token b99aa300d382f7491e0e6103d8cf5cd55aeecc3e'}
        @a_hash = JSON.parse(response.body)

    end

    def cantidadThesisForTopic(topics, tesis)
        cantidadesActuales = []
        cantidadesTotal = []
        total=[]
        thesis = tesis
        topics.each_with_index do |topic, i|
            contadorActuales = 0
            contadorTotal = 0
            thesis.each_with_index do |the, j|
                if the["topic"].present?
                    if topic["name"].eql? the['topic']
                        contadorTotal = contadorTotal + 1
                        if the["status"] != 'CL'
                            contadorActuales = contadorActuales + 1
                        end
                    end
                end
            end
            cantidadesActuales.push(contadorActuales)
            cantidadesTotal.push(contadorTotal)
        end
        total.push(cantidadesActuales, cantidadesTotal)
        total
    end

    def cantidadThesisForProgram(programs, tesis)
        if tesis[0].nil?
            puts "entero nuloooo"
        else
            puts tesis[0]["program_id"]
        end
        puts "aaaaaaaaaaaaaaaa"
        cantidadesActuales = []
        cantidadesTotal = []
        total=[]
        url = 'http://ec2-100-25-103-59.compute-1.amazonaws.com/tracker/thesis/'
        #thesis = RestClient.get url, {Authorization: 'Token b99aa300d382f7491e0e6103d8cf5cd55aeecc3e'}
        #thesis = JSON.parse(thesis.body)
        thesis = tesis
        programs.each_with_index do |program, i|
            contadorActuales = 0
            contadorTotal = 0
            thesis.each_with_index do |the, j|
                if !program.nil?
                    puts "-----"
                else
                    puts "soy nulo"
                end
               
                    if program["grade"] == the['program_id']
                        contadorTotal = contadorTotal + 1
                        if the["status"] != 'CL'
                            contadorActuales = contadorActuales + 1
                        end
                    
                end
            end
            cantidadesActuales.push(contadorActuales)
            cantidadesTotal.push(contadorTotal)
        end
        total.push(cantidadesActuales, cantidadesTotal)
        total
    end

end
