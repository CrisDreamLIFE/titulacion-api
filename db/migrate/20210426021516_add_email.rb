class AddEmail < ActiveRecord::Migration[6.1]
  def change
    add_column :work_plans, :student_email, :string

  end
end
