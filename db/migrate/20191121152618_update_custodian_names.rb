class UpdateCustodianNames < ActiveRecord::Migration
  def up
    change_column :custodian_names, :name, :text, :limit => 16777215
    change_column :custodian_names, :note, :text, :limit => 16777215
  end
  def down
    change_column :custodian_names, :name, :text, :limit => 16777215
    change_column :custodian_names, :note, :text, :limit => 16777215
  end
end
