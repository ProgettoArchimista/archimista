class UpdateSc2TextualElements < ActiveRecord::Migration
def up
    change_column :sc2_textual_elements, :isri, :text, :limit => 16777215
  end
  def down
    change_column :sc2_textual_elements, :isri, :text, :limit => 16777215
  end
end
