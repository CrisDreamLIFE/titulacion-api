class AddFileToProposal < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :file, :integer

  end
end
