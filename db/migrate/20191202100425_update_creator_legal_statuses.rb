class UpdateCreatorLegalStatuses < ActiveRecord::Migration
  def up
    change_column :creator_legal_statuses, :note, :text, :limit => 16777215
  end
  def down
    change_column :creator_legal_statuses, :note, :text, :limit => 16777215
  end
end
