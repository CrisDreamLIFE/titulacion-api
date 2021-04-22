class AddprofessorNameToProposal < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :professor_name, :string
  end
end
