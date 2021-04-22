class ThesisSummary < ApplicationRecord
    def tesisxProfesor(id)
        todo = ThesisSummary.where(guide_id: id).order(year: :desc)
        if(todo.length==0)
            todo =0
        end
        todo
    end

    def anhosTotales(tesis)
        anhos = []
        tesis.each_with_index do |tes, i|
            if(!anhos.include? tes["year"])
                puts "no lo incluye"
                anhos.push(tes["year"])
            end
        end
        anhos
    end

    def cantidadThesisForYear(tesis, anhos)
        cantidades= []
        thesis = tesis
        anhos.each_with_index do |anho, i|
            contador = 0
            thesis.each_with_index do |the, j|
                if anho == the['year']
                    contador = contador + 1
                end  
            end
            cantidades.push(contador)
        end
        cantidades
    end
        
end
