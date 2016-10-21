# Upgrade 2.2.0 inizio
class Sc2AddLegacyCurrentIdField < ActiveRecord::Migration
  def self.up
    add_column :sc2_authors, :legacy_current_id, :integer
    add_column :sc2_commissions, :legacy_current_id, :integer

    add_index "sc2_authors", ["db_source", "legacy_current_id"]
    add_index "sc2_commissions", ["db_source", "legacy_current_id"]
  end

  def self.down
    remove_index "sc2_authors", ["db_source", "legacy_current_id"]
    remove_index "sc2_commissions", ["db_source", "legacy_current_id"]

    remove_column :sc2_commissions, :legacy_current_id
    remove_column :sc2_authors, :legacy_current_id
  end
end
# Upgrade 2.2.0 fine
