class UpdateFeDesigners < ActiveRecord::Migration
def up
    change_column :fe_designers, :designer_name, :text, :limit => 16777215
    change_column :fe_designers, :designer_role, :text, :limit => 16777215
  end
  def down
    change_column :fe_designers, :designer_name, :text, :limit => 16777215
    change_column :fe_designers, :designer_role, :text, :limit => 16777215
  end
end
