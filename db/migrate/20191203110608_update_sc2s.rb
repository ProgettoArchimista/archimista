class UpdateSc2s < ActiveRecord::Migration
def up
    change_column :sc2s, :sgti, :text, :limit => 16777215
    change_column :sc2s, :cmmr, :text, :limit => 16777215
    change_column :sc2s, :lrc, :text, :limit => 16777215
  end
  def down
    change_column :sc2s, :sgti, :text, :limit => 16777215
    change_column :sc2s, :cmmr, :text, :limit => 16777215
    change_column :sc2s, :lrc, :text, :limit => 16777215
  end
end
