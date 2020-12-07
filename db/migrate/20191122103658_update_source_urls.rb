class UpdateSourceUrls < ActiveRecord::Migration
  def up
    change_column :source_urls, :url, :text, :limit => 65535
    change_column :source_urls, :note, :text, :limit => 16777215
  end
  def down
    change_column :source_urls, :url, :text, :limit => 65535
    change_column :source_urls, :note, :text, :limit => 16777215
  end
end
