class UpdateCreatorActivities < ActiveRecord::Migration
  def up
    change_column :creator_activities, :activity, :text, :limit => 16777215
    change_column :creator_activities, :note, :text, :limit => 16777215
  end
  def down
    change_column :creator_activities, :activity, :text, :limit => 16777215
    change_column :creator_activities, :note, :text, :limit => 16777215
  end
end
