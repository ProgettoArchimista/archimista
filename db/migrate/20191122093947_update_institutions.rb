class UpdateInstitutions < ActiveRecord::Migration
  def up
    change_column :institutions, :name, :text, :limit => 16777215
    change_column :institutions, :description, :text, :limit => 16777215
    change_column :institutions, :note, :text, :limit => 16777215
  end
  def down
    change_column :institutions, :name, :text, :limit => 16777215
    change_column :institutions, :description, :text, :limit => 16777215
    change_column :institutions, :note, :text, :limit => 16777215
  end
end
