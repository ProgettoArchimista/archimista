class UpdateFondEditors < ActiveRecord::Migration
  def up
    change_column :fond_editors, :name, :text, :limit => 16777215
    change_column :fond_editors, :qualifier, :text, :limit => 16777215
  end
  def down
    change_column :fond_editors, :name, :text, :limit => 16777215
    change_column :fond_editors, :qualifier, :text, :limit => 16777215
  end
end
