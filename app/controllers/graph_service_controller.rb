class GraphServiceController < ApplicationController
    require 'ProffesorJavierUtilities'
    require 'TopicJavierUtilities'
    require 'thesis_summary'
    require 'professor_summary'

    def dataMixBarGraph
        data =[]
        data1 = []
        data2= []
        data3 = [] 
        data4 = [] 
        profesores = ProfessorSummary.all
        profesores.each_with_index do |element,i|
            data_aux = {
                "first_lastname" => element["first_lastname"],
                "second_lastname"=> element["second_lastname"],
                "name" => element["name"],
                "cantidad" => element["asignadas"]
            }
            data1.push(data_aux)
            data_aux = {
                "first_lastname" => element["first_lastname"],
                "second_lastname"=> element["second_lastname"],
                "name" => element["name"],
                "cantidad" => element["num_tesis_medias"]
            }
            data2.push(data_aux)
            data_aux = {
                "first_lastname" => element["first_lastname"],
                "second_lastname"=> element["second_lastname"],
                "name" => element["name"],
                "cantidad" => element["dias_rev_med"]
            }
            data3.push(data_aux)
            data_aux = {
                "first_lastname" => element["first_lastname"],
                "second_lastname"=> element["second_lastname"],
                "name" => element["name"],
                "cantidad" => element["num_tesis_abandonadas"]
            }
            data4.push(data_aux)
        end
        data.push(data1,data2,data3,data4)
        render :json => data
    end

    def dataMemoriasBarGraph
        data1=[]
        data2=[]
        data3=[]
        obj = ProfessorSummary.new()
        profesores = ProfessorSummary.all
        tesis = ThesisSummary.all
        cantidades = obj.cantidadThesisForProfesor(profesores, tesis)
        profesores.each_with_index do |element, index|
            data_aux = {
                "first_lastname" => element["first_lastname"],
                "second_lastname"=> element["second_lastname"],
                "name" => element["name"],
                "cantidad" => cantidades[0][index]
            }
            data_aux2 = {
                "first_lastname" => element["first_lastname"],
                "second_lastname"=> element["second_lastname"],
                "name" => element["name"],
                "cantidad" => cantidades[1][index]
            }
            data1.push(data_aux)
            data2.push(data_aux2)
          end
          data3.push(data1,data2)
          render :json => data3  

    end

    def dataAcademicPieGraph
        data =[]
        obj = ProfessorSummary.new()
        profesores = ProfessorSummary.all
        academicArrayName = ["Académico", "Profesor por hora"]
        academicArray = [true,false]
        cantidades = obj.cantidadProfForAcademic(profesores,academicArray)
        academicArrayName.each_with_index do |aca,i|
            data_aux = {
            "name" => aca,
            "cantidad" => cantidades[i]
            }
            data.push(data_aux)
        end
        render :json => data
    end

    def dataGradePieGraph
        data = []
        obj = ProfessorSummary.new()
        profesores = ProfessorSummary.all
        gradesArray = ["Doctorado", "Magíster","Civil","Ejecución"]
        cantidades = obj.cantidadProfForGrade(profesores,gradesArray)
        gradesArray.each_with_index do |grade,i|
            data_aux = {
            "name" => grade,
            "cantidad" => cantidades[i]
            }
            data.push(data_aux)
        end
        render :json => data
    end

    def dataAnhoBarGraph
        data = []
        tesis = ThesisSummary.all
        obj = ThesisSummary.new()
        anhosArray = obj.anhosTotales(tesis)
        cantidades = obj.cantidadThesisForYear(tesis,anhosArray)
        anhosArray.each_with_index do |anho,i|
            data_aux = {
            "name" => anho.to_s,
            "cantidad" => cantidades[i]
            }
            data.push(data_aux)
        end
        render :json => data
    end

    def dataProgramPieGraph
        data1=[]
        data2=[]
        data3=[]
        obj = TopicJavierUtilities.new()
        programas = obj.selectAllPrograms
        tesis = ThesisSummary.all
        cantidades = obj.cantidadThesisForProgram(programas, tesis)
        programas.each_with_index do |element, index|
          data_aux = {
            "id" => element["id"],
            "name" => element["name"],
            "cantidad" => cantidades[0][index]
          }
          data_aux2 = {
            "id" => element["id"],
            "name" => element["name"],
            "cantidad" => cantidades[1][index]
          }
          data1.push(data_aux)
          data2.push(data_aux2)
        end
        data3.push(data1,data2)
        render :json => data3  

    end

    def dataTopicPieGraph 
        data1=[]
        data2=[]
        data3=[]
        obj = TopicJavierUtilities.new()
        topics = obj.selectAllTopics
        tesis = ThesisSummary.all
        cantidades = obj.cantidadThesisForTopic(topics, tesis)
        topics.each_with_index do |element, index|
          data_aux = {
            "id" => element["id"],
            "name" => element["name"],
            "cantidad" => cantidades[0][index]
          }
          data_aux2 = {
            "id" => element["id"],
            "name" => element["name"],
            "cantidad" => cantidades[1][index]
          }
          data1.push(data_aux)
          data2.push(data_aux2)
        end
        data3.push(data1,data2)
        render :json => data3   
    end

    def burdownGraph
        fechaActual = Time.now
        puts "--"
        puts fechaActual
        puts "**"
        activities = params["activities"]
        puts "-1"
        fechas = allFechas(activities)
        puts "1"
        puts fechas[0]
        puts "2"
        if (fechas.length!=0)
            diaActual = (fechaActual.to_date - fechas.min.to_date).to_i
            semanaActual = diaActual /7
            diferencia = cantidadDiasEntreFechas(fechas)
            num_semanas = (diferencia / 7) +1
            esp_y_real = tareasToFechas(activities, num_semanas, fechas.min)
            esp_pro = sumaProgresiva(esp_y_real[0])
            real_pro = sumaProgresiva(esp_y_real[1])
            final = armarObjeto(esp_pro,real_pro, semanaActual)   
        else
            final = 0
        end
        
        render :json => final

    end

    def allFechas(activities)
        fechas = []
        activities.each_with_index do |activity, i|
            if (activity["tasks"].length !=0)
                activity["tasks"].each_with_index do |task, j|
                    puts task["state"]
                    fechas.push(task["start_date"])
                    fechas.push(task["end_date"])
                    if(task["state"]=="finalizada")
                        fechas.push(task["close_date"])
                    end
                end
            end
        end
        fechas.each_with_index do |fecha,k|
            puts fecha
        end
        fechas
    end

    def cantidadDiasEntreFechas (fechas)
        menor = fechas.min
        mayor = fechas.max
        puts "mayor:"
        puts mayor
        puts "menor:"
        puts menor
        diferencia = mayor.to_date- menor.to_date
        diferencia = diferencia.to_i
        puts "diferencia"
        puts diferencia
        diferencia
    end

    def iniciarCeros(arreglo)
        puts "aaa"
        aux = []
        puts arreglo.length
        arreglo.each_with_index do |pos, i|
            if pos == nil
                aux.push(0)
            end
        end
        aux    
    end

    def tareasToFechas(activities, num_semanas, min)
        puts "asdasd"
        puts "num_semanas"
        puts num_semanas
        sem_1 = iniciarCeros(Array.new(num_semanas))
        sem_2 = iniciarCeros(Array.new(num_semanas))
        puts "sem_1.length"
        puts sem_1.length
        activities.each_with_index do |activity, i|
            if (activity["tasks"].length !=0)
                puts "a"
                activity["tasks"].each_with_index do |task, j|
                    sem_2.each_with_index do |dia, r|
                    end
                    dif = cantidadDiasEntreFechas([min,task["end_date"]])
                    puts "b"
                    n = dif/7
                    sem_1[n] = sem_1[n] + 1
                    if (task["state"] == "finalizada")
                        
                        dif_2 = cantidadDiasEntreFechas([min,task["close_date"]])
                        puts "dif_2"
                        puts dif_2
                        
                        n2 = dif_2/7
                        puts sem_2[n2]
                        sem_2[n2] = sem_2[n2] + 1   
                    end
                end
            end
        end
        puts sem_2[1]
        sem_tot = []
        sem_tot.push(sem_1)
        sem_tot.push(sem_2)
    end

    def sumaProgresiva(semanas)
        aux_1 = []
        cont_1 = 0
        semanas.each_with_index do |valor,i|
            if(valor !=0)
                cont_1 = cont_1 + valor
            end
            aux_1.push(cont_1)
                
        end
        aux_1
    end

    def armarObjeto(semanas_1, semanas_2, semanaActual)
        json_send = []
        aux = []
        aux.push(semanaActual)
        json_send.push(aux)
        aux2=[]
        semanas_1.each_with_index do |element,i|
            if(i==0)
                name = "0"
            else
                name = "semana "+i.to_s
            end
            aux3 = {
                "esperado" => semanas_1[i],
                "real" => semanas_2[i],
                "name" => name
            }
            aux2.push(aux3)
        end
        json_send.push(aux2)
        json_send
    end
end
