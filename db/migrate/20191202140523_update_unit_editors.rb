class UpdateUnitEditors < ActiveRecord::Migration
def up
    change_column :unit_editors, :name, :text, :limit => 16777215
    change_column :unit_editors, :qualifier, :text, :limit => 16777215
  end
  def down
    change_column :unit_editors, :name, :text, :limit => 16777215
    change_column :unit_editors, :qualifier, :text, :limit => 16777215
  end
end
