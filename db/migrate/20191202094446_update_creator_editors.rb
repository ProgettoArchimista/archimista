class UpdateCreatorEditors < ActiveRecord::Migration
  def up
    change_column :creator_editors, :name, :text, :limit => 16777215
    change_column :creator_editors, :qualifier, :text, :limit => 16777215
  end
  def down
    change_column :creator_editors, :name, :text, :limit => 16777215
    change_column :creator_editors, :qualifier, :text, :limit => 16777215
  end
end
