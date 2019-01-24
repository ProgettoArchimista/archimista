class AddFileTypeToUnits < ActiveRecord::Migration
  def change
    add_column :units, :file_type, :string
  end
end
