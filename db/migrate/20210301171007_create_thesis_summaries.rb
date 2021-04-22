class CreateThesisSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :thesis_summaries do |t|
      t.integer :thesis_id
      t.integer :thype_id
      t.integer :guide_id
      t.string :topic
      t.integer :program_id
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


thesis = ThesisSummary.new(thesis_id:element["id"],
                thype_id:element["thesis_type"], #valor que hay que buscar y poner unos id o case para asignar el tipo
                topic:element["topic"],
                program_id: element["student"]["program"],
                status: element["status"],
                year: element["year"],
                semester:element["semester"],
                dias_rev:0,
                guia_name: element["guide"]["name"],
                student_name: element["student"]["name"],
                student_email: element["student"]["email"],
                student_first_lastname: element["student"]["first_lastname"],
                student_second_lastname: element["student"]["second_lastname"],
                title: element["title"],
                guide_id:element["guide"]["id"],
                guia_email:element["guide"]["email"],
                guia_first_lastname: element["guide"]["first_lastname"],
                guia_second_lastname: element["guide"]["second_lastname"]
                )
        thesis.save