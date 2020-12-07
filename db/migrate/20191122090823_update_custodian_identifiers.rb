class UpdateCustodianIdentifiers < ActiveRecord::Migration
  def up
    change_column :custodian_identifiers, :note, :text, :limit => 16777215
  end
  def down
    change_column :custodian_identifiers, :note, :text, :limit => 16777215
  end
end
