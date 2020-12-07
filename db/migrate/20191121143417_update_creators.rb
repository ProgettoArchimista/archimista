class UpdateCreators < ActiveRecord::Migration
 def up
    change_column :creators, :abstract, :text, :limit => 16777215
    change_column :creators, :history, :text, :limit => 16777215
    change_column :creators, :note, :text, :limit => 16777215
    change_column :creators, :residence, :text, :limit => 16777215
  end
  def down
    change_column :creators, :abstract, :text, :limit => 16777215
    change_column :creators, :history, :text, :limit => 16777215
    change_column :creators, :note, :text, :limit => 16777215
    change_column :creators, :residence, :text, :limit => 16777215
  end
end
