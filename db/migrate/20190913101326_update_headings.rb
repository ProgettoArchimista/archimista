class UpdateHeadings < ActiveRecord::Migration
  def up
    change_column :headings, :qualifier, :text, :limit => 16777215
  end
  def down
    change_column :headings, :qualifier, :text, :limit => 16777215
  end
end
