class ChangeAccessConditionToFonds < ActiveRecord::Migration
  def change
    change_column :fonds, :access_condition, :text, :limit => 16777215
    change_column :fonds, :access_condition_note, :text, :limit => 16777215
  end
end
