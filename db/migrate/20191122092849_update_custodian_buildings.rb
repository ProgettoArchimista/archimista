class UpdateCustodianBuildings < ActiveRecord::Migration
  def up
    change_column :custodian_buildings, :name, :text, :limit => 16777215
    change_column :custodian_buildings, :description, :text, :limit => 16777215
  end
  def down
    change_column :custodian_buildings, :name, :text, :limit => 16777215
    change_column :custodian_buildings, :description, :text, :limit => 16777215
  end
end
