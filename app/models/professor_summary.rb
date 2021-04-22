class ProfessorSummary < ApplicationRecord
    require 'thesis_summary'

    def professorMemorias(id)
        obj = ThesisSummary.new()
        asd = obj.tesisxProfesor(id)
    end

    def cantidadThesisForProfesor(profesores, tesis)
        cantidadesActuales = []
        cantidadesTotal = []
        total=[]
        thesis = tesis
        profesores.each_with_index do |profe, i|
            contadorActuales = 0
            contadorTotal = 0
            thesis.each_with_index do |the, j|
                if profe["email"] == the['guia_email']
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

    def cantidadProfForAcademic(profesores,academicArray)
        cantidades = []
        academicArray.each_with_index do |aca, i|
            contador = 0
            profesores.each_with_index do |prof, i|
                if(prof["academic"] == aca)
                    contador = contador + 1
                end
            end
            cantidades.push(contador)
        end
        cantidades
    end

    def cantidadProfForGrade(profesores,gradesArray)
        cantidades = []
        gradesArray.each_with_index do |grado, j|
            contador = 0
            profesores.each_with_index do |prof,i|
                if grado == prof["grade_name"]
                    contador = contador + 1
                end
            end
            cantidades.push(contador)
        end
        cantidades
    end
        

    #[[mem1, mem2,mem3],[ , , ]]
    def añosPorProfMem(memorias)
        cantidadesProf=[]  
        memorias.each_with_index do |elements, index|
            años=[]
            if (elements!=0)
                elements.each_with_index do |mem, i|
                    if(!años.include? mem["year"])
                        años.push(mem["year"])
                    end
                end
                cantidadesProf.push(años);
            else
                cantidadesProf.push(0);
            end
        end
        cantidadesProf
    end
    # [[2020,2019,2018],[ , , ,]]
    def mediaPorAño(memorias)
        años = añosPorProfMem(memorias)
        mediasTot=[]
        memorias.each_with_index do |elements, index|
            if(elements!=0)
                medias=[]
                años[index].each_with_index do |año, i|
            
                    cont_1=0
                    cont_2=0
                    elements.each_with_index do |memoria,j|
                        if(año == memoria["year"])
                            if(memoria["semester"]==1)
                                cont_1=cont_1+1
                            else
                                cont_2 = cont_2+1 
                            end
                        end
                    end
                    medias.push(cont_1)
                    medias.push(cont_2) 
                end
            else
                medias = 0
            end
            mediasTot.push(medias)
        end   
        mediasTot 
    end

        #tesisxProfesor
    def finalMediaXProfesor(profesores)
        memorias=[]
        profesores.each_with_index do |prof, l|
            asd = professorMemorias(prof["id"])
            if(asd==0)
                puts "asd:"
                puts prof["professor_id"]
            else 
                puts "no soy 0"
            end
            memorias.push(asd)
        end
        cantidades = mediaPorAño(memorias)
        medias =[]
        cantidades.each_with_index do |cantidad , i|
            if(cantidad != 0)
                n = cantidad.length
                suma = 0
                cantidad.each_with_index do |valor,j|
                    suma = suma + valor
                end
                media = suma.to_f/n.to_f
                medias.push(media.round(2)) 
            else 
                medias.push(0) 
            end
            
        end
        medias
    end

end
