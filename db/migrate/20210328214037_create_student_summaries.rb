class CreateStudentSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :student_summaries do |t|
      t.integer :student_id
      t.string :name
      t.string :first_lastname
      t.string :second_lastname
      t.integer :year_income
      t.string :email
      t.integer :program_id
      t.string :program_name
      t.integer :num_temas
      t.integer :num_guias

      t.timestamps
    end
  end
end
