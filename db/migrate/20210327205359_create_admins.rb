class CreateAdmins < ActiveRecord::Migration[6.1]
  def change
    create_table :admins do |t|
      t.string :email
      t.string :name
      t.string :first_lastname
      t.string :second_lastname

      t.timestamps
    end
  end
end
