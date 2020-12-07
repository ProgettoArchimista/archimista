class UpdateProjects < ActiveRecord::Migration
  def up
    change_column :projects, :name, :text, :limit => 16777215
    change_column :projects, :description, :text, :limit => 16777215
    change_column :projects, :note, :text, :limit => 16777215
  end
  def down
    change_column :projects, :name, :text, :limit => 16777215
    change_column :projects, :description, :text, :limit => 16777215
    change_column :projects, :note, :text, :limit => 16777215
  end
end
