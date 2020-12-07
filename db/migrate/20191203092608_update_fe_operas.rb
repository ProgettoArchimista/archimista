class UpdateFeOperas < ActiveRecord::Migration
def up
    change_column :fe_operas, :building_name, :text, :limit => 16777215
    change_column :fe_operas, :building_type, :text, :limit => 16777215
    change_column :fe_operas, :place_name, :text, :limit => 16777215
    change_column :fe_operas, :place_type, :text, :limit => 16777215
    change_column :fe_operas, :district, :text, :limit => 16777215
  end
  def down
    change_column :fe_operas, :building_name, :text, :limit => 16777215
    change_column :fe_operas, :building_type, :text, :limit => 16777215
    change_column :fe_operas, :place_name, :text, :limit => 16777215
    change_column :fe_operas, :place_type, :text, :limit => 16777215
    change_column :fe_operas, :district, :text, :limit => 16777215
  end
end
