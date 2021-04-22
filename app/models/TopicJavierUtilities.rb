class TopicJavierUtilities
    #include HTTParty

    def selectAllTopics
        url = 'http://127.0.0.1:8000/tracker/topic/'
        response = RestClient.get url, {Authorization: 'Token ca393b0e830aa77ab90aa8a18fd2877f23091ad2'}
        @a_hash = JSON.parse(response.body) #hasheamos la respuesta para poder acceder
    end

    def selectAllPrograms
        url = 'http://127.0.0.1:8000/tracker/program'
        response = RestClient.get url, {Authorization: 'Token ca393b0e830aa77ab90aa8a18fd2877f23091ad2'}
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
        url = 'http://127.0.0.1:8000/tracker/thesis/'
        #thesis = RestClient.get url, {Authorization: 'Token ca393b0e830aa77ab90aa8a18fd2877f23091ad2'}
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
