class UpdateFscNationalities < ActiveRecord::Migration
def up
    change_column :fsc_nationalities, :nationality, :text, :limit => 16777215
  end
  def down
    change_column :fsc_nationalities, :nationality, :text, :limit => 16777215
  end
end
