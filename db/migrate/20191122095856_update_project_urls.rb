class UpdateProjectUrls < ActiveRecord::Migration
  def up
    change_column :project_urls, :note, :text, :limit => 16777215
  end
  def down
    change_column :project_urls, :note, :text, :limit => 16777215
  end
end
