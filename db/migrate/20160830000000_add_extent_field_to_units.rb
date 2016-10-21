# Upgrade 2.2.0 inizio
class AddExtentFieldToUnits < ActiveRecord::Migration
  def self.up
    add_column :units, :extent, :text
  end

  def self.down
    remove_column :units, :extent
  end
end
# Upgrade 2.2.0 fine