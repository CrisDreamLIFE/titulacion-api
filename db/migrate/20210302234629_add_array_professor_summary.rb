class AddArrayProfessorSummary < ActiveRecord::Migration[6.1]
  def change
    add_column :professor_summaries, :topicos, :string, array:true, default:[]
  end
end
