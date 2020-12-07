class UpdateFondNames < ActiveRecord::Migration
  def up
    change_column :fond_names, :name, :text, :limit => 16777215
    change_column :fond_names, :note, :text, :limit => 16777215
  end
  def down
    change_column :fond_names, :name, :text, :limit => 16777215
    change_column :fond_names, :note, :text, :limit => 16777215
  end
end
