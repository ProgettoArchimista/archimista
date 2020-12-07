class UpdateCreatorIdentifiers < ActiveRecord::Migration
  def up
    change_column :creator_identifiers, :identifier, :text, :limit => 16777215
    change_column :creator_identifiers, :identifier_source, :text, :limit => 16777215
    change_column :creator_identifiers, :note, :text, :limit => 16777215
  end
  def down
    change_column :creator_identifiers, :identifier, :text, :limit => 16777215
    change_column :creator_identifiers, :identifier_source, :text, :limit => 16777215
    change_column :creator_identifiers, :note, :text, :limit => 16777215
  end
end
