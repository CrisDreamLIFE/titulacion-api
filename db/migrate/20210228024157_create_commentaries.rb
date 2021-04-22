class CreateCommentaries < ActiveRecord::Migration[6.1]
  def change
    create_table :commentaries do |t|
      t.text :message
      t.integer :issuer_id
      t.date :issuer_date
      t.string :state
      t.belongs_to :activity, index:true, foreign_key: true
      t.timestamps
    end
  end
end
