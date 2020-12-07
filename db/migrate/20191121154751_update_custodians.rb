class UpdateCustodians < ActiveRecord::Migration
  def up
    change_column :custodians, :history, :text, :limit => 16777215
    change_column :custodians, :holdings, :text, :limit => 16777215
    change_column :custodians, :collecting_policies, :text, :limit => 16777215
    change_column :custodians, :administrative_structure, :text, :limit => 16777215
    change_column :custodians, :accessibility, :text, :limit => 16777215
    change_column :custodians, :services, :text, :limit => 16777215
  end
  def down
    change_column :custodians, :history, :text, :limit => 16777215
    change_column :custodians, :holdings, :text, :limit => 16777215
    change_column :custodians, :collecting_policies, :text, :limit => 16777215
    change_column :custodians, :administrative_structure, :text, :limit => 16777215
    change_column :custodians, :accessibility, :text, :limit => 16777215
    change_column :custodians, :services, :text, :limit => 16777215
  end
end
