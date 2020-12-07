class UpdateUnitEvents < ActiveRecord::Migration
  def up
    change_column :unit_events, :note, :text, :limit => 16777215
  end
  def down
    change_column :unit_events, :note, :text, :limit => 16777215
  end
end
