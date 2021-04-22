class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :state
      t.date :start_date
      t.date :end_date
      t.date :close_date
      t.belongs_to :activity, index:true, foreign_key: true
      t.timestamps
    end
  end
end
