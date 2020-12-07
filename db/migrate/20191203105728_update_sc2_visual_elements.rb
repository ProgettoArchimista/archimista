class UpdateSc2VisualElements < ActiveRecord::Migration
def up
    change_column :sc2_visual_elements, :stmd, :text, :limit => 16777215
  end
  def down
    change_column :sc2_visual_elements, :stmd, :text, :limit => 16777215
  end
end
