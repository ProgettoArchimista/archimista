class UpdateSources < ActiveRecord::Migration
 def up
    change_column :sources, :short_title, :text, :limit => 16777215
    change_column :sources, :title, :text, :limit => 16777215
    change_column :sources, :date_string, :text, :limit => 255
    change_column :sources, :abstract, :text, :limit => 16777215
    change_column :sources, :author, :text, :limit => 16777215
    change_column :sources, :editor, :text, :limit => 16777215
    change_column :sources, :place, :text, :limit => 16777215
    change_column :sources, :publisher, :text, :limit => 16777215
    change_column :sources, :related_item, :text, :limit => 16777215
    change_column :sources, :related_item_specs, :text, :limit => 16777215
  end
  def down
    change_column :sources, :short_title, :text, :limit => 16777215
    change_column :sources, :title, :text, :limit => 16777215
    change_column :sources, :date_string, :text, :limit => 255
    change_column :sources, :abstract, :text, :limit => 16777215
    change_column :sources, :author, :text, :limit => 16777215
    change_column :sources, :editor, :text, :limit => 16777215
    change_column :sources, :place, :text, :limit => 16777215
    change_column :sources, :publisher, :text, :limit => 16777215
    change_column :sources, :related_item, :text, :limit => 16777215
    change_column :sources, :related_item_specs, :text, :limit => 16777215
  end
end
