class UpdateCreatorNames < ActiveRecord::Migration
 def up
    change_column :creator_names, :name, :text, :limit => 16777215
    change_column :creator_names, :first_name, :text, :limit => 16777215
    change_column :creator_names, :last_name, :text, :limit => 16777215
    change_column :creator_names, :note, :text, :limit => 16777215
  end
  def down
    change_column :creator_names, :name, :text, :limit => 16777215
    change_column :creator_names, :first_name, :text, :limit => 16777215
    change_column :creator_names, :last_name, :text, :limit => 16777215
    change_column :creator_names, :note, :text, :limit => 16777215
  end
end
