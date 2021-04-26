class CreateThesisSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :thesis_summaries do |t|
      t.integer :thesis_id
      t.integer :thype_id
      t.string :topic
      t.integer :program_id
      t.integer :guide_id
      t.string :status
      t.integer :year
      t.integer :semester
      t.integer :dias_rev
      t.string :student_name
      t.string :student_email
      t.string :student_first_lastname
      t.string :student_second_lastname
      t.string :guia_name
      t.string :guia_email
      t.string :guia_first_lastname
      t.string :guia_second_lastname
      t.string :title

      t.timestamps
    end
  end
end

