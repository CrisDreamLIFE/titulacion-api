class CreateActivities < ActiveRecord::Migration[6.1]
  #Agregar la foranea de workPlan y las cositas que irian en el modelo
  def change
    create_table :activities do |t|
      t.string :title
      t.string :state
      t.date :start_date
      t.date :end_date
      t.date :close_date
      t.integer :task_pending
      t.integer :task_finished
      t.belongs_to :work_plan, index:true, foreign_key: true
      t.timestamps
    end
  end
end
