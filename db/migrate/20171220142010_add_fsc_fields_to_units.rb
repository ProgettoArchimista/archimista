class AddFscFieldsToUnits < ActiveRecord::Migration
  def change
    add_column :units, :fsc_name, :string
    add_column :units, :fsc_surname, :string
  end
end
