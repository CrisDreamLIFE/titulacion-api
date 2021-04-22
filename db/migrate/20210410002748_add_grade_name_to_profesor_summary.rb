class AddGradeNameToProfesorSummary < ActiveRecord::Migration[6.1]
  def change
    add_column :professor_summaries, :grade_name, :string
  end
end
