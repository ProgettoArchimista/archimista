class UpdateFeIdentifications < ActiveRecord::Migration
def up
    change_column :fe_identifications, :code, :text, :limit => 16777215
    change_column :fe_identifications, :category, :text, :limit => 16777215
    change_column :fe_identifications, :identification_class, :text, :limit => 16777215
  end
  def down
    change_column :fe_identifications, :code, :text, :limit => 16777215
    change_column :fe_identifications, :category, :text, :limit => 16777215
    change_column :fe_identifications, :identification_class, :text, :limit => 16777215
  end
end
