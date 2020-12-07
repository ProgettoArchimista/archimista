class UpdateCreatorUrls < ActiveRecord::Migration
def up
    change_column :creator_urls, :url, :text, :limit => 65535
    change_column :creator_urls, :note, :text, :limit => 16777215
  end
  def down
    change_column :creator_urls, :url, :text, :limit => 65535
    change_column :creator_urls, :note, :text, :limit => 16777215
  end
end
