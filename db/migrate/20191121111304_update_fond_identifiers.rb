class UpdateFondIdentifiers < ActiveRecord::Migration
  def up
    change_column :fond_identifiers, :note, :text, :limit => 16777215
  end
  def down
    change_column :fond_identifiers, :note, :text, :limit => 16777215
  end
end
