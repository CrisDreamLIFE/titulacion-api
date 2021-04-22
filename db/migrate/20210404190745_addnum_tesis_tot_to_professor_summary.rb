class AddnumTesisTotToProfessorSummary < ActiveRecord::Migration[6.1]
  def change
    add_column :professor_summaries, :num_tesis_tot, :integer
  end
end
