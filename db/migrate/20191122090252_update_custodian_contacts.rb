class UpdateCustodianContacts < ActiveRecord::Migration
  def up
    change_column :custodian_contacts, :contact_note, :text, :limit => 16777215
  end
  def down
    change_column :custodian_contacts, :contact_note, :text, :limit => 16777215
  end
end
