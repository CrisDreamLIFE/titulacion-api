class CreateWorkPlans < ActiveRecord::Migration[6.1]
  def change
    create_table :work_plans do |t|
      t.string :state
      t.boolean :trabajo_titulacion
      t.integer :activity_pending
      t.integer :activity_finished
      t.integer :thesis_id
      t.timestamps
    end
  end
end
