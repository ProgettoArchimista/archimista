class UpdateFonds < ActiveRecord::Migration
  def up
    change_column :fonds, :name, :text, :limit => 16777215
    change_column :fonds, :extent, :text, :limit => 16777215
    change_column :fonds, :abstract, :text, :limit => 16777215
    change_column :fonds, :description, :text, :limit => 16777215
    change_column :fonds, :history, :text, :limit => 16777215
    change_column :fonds, :arrangement_note, :text, :limit => 16777215
    change_column :fonds, :related_materials, :text, :limit => 16777215
    change_column :fonds, :note, :text, :limit => 16777215
    change_column :fonds, :access_condition_note, :text, :limit => 16777215
    change_column :fonds, :use_condition_note, :text, :limit => 16777215
    change_column :fonds, :preservation_note, :text, :limit => 16777215
  end
  def down
    change_column :fonds, :name, :text, :limit => 16777215
    change_column :fonds, :extent, :text, :limit => 16777215
    change_column :fonds, :abstract, :text, :limit => 16777215
    change_column :fonds, :description, :text, :limit => 16777215
    change_column :fonds, :history, :text, :limit => 16777215
    change_column :fonds, :arrangement_note, :text, :limit => 16777215
    change_column :fonds, :related_materials, :text, :limit => 16777215
    change_column :fonds, :note, :text, :limit => 16777215
    change_column :fonds, :access_condition_note, :text, :limit => 16777215
    change_column :fonds, :use_condition_note, :text, :limit => 16777215
    change_column :fonds, :preservation_note, :text, :limit => 16777215
  end
end
