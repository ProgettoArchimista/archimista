class UpdateSc2Authors < ActiveRecord::Migration
def up
    change_column :sc2_authors, :autn, :text, :limit => 16777215
  end
  def down
    change_column :sc2_authors, :autn, :text, :limit => 16777215
  end
end
