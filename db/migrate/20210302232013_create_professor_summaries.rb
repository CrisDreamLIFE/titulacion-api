class CreateProfessorSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :professor_summaries do |t|
      t.integer :professor_id
      t.string :name
      t.string :first_lastname
      t.string :second_lastname
      t.string :grade
      t.string :grade_name
      t.string :email
      t.string :avatar
      t.integer :num_tesis
      t.integer :num_tesis_tot
      t.float :num_tesis_med
      t.integer :asignadas
      t.float :dias_rev_med
      t.boolean :academic
      t.integer :num_tesis_abandonadas
      t.float :tiempo_final_med

      t.timestamps
    end
  end
end
