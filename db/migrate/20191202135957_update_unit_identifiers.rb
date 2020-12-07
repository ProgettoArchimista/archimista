class UpdateUnitIdentifiers < ActiveRecord::Migration
def up
    change_column :unit_identifiers, :identifier, :text, :limit => 16777215
    change_column :unit_identifiers, :identifier_source, :text, :limit => 16777215
    change_column :unit_identifiers, :note, :text, :limit => 16777215
  end
  def down
    change_column :unit_identifiers, :identifier, :text, :limit => 16777215
    change_column :unit_identifiers, :identifier_source, :text, :limit => 16777215
    change_column :unit_identifiers, :note, :text, :limit => 16777215
  end
end
