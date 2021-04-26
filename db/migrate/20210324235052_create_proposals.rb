class CreateProposals < ActiveRecord::Migration[6.1]
  def change
    create_table :proposals do |t|
      t.integer :student_id
      t.integer :professor_id
      t.integer :topic_id
      t.string :topic_name
      t.string :title
      t.text :summary
      t.integer :semester
      t.integer :year
      t.string :student_name
      t.string :professor_name
      
      

      t.timestamps
    end
  end
end
