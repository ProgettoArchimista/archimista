class UpdateCreatorEvents < ActiveRecord::Migration
  def up
    change_column :creator_events, :note, :text, :limit => 16777215
    change_column :creator_events, :start_date_place, :text, :limit => 16777215
    change_column :creator_events, :end_date_place, :text, :limit => 16777215
  end
  def down
    change_column :creator_events, :note, :text, :limit => 16777215
    change_column :creator_events, :start_date_place, :text, :limit => 16777215
    change_column :creator_events, :end_date_place, :text, :limit => 16777215
  end
end
