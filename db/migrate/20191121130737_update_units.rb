class UpdateUnits < ActiveRecord::Migration
  def up
    change_column :units, :title, :text, :limit => 16777215
    change_column :units, :content, :text, :limit => 16777215
    change_column :units, :extent, :text, :limit => 16777215
    change_column :units, :arrangement_note, :text, :limit => 16777215
    change_column :units, :related_materials, :text, :limit => 16777215
    change_column :units, :physical_description, :text, :limit => 16777215
    change_column :units, :preservation_note, :text, :limit => 16777215
    change_column :units, :restoration, :text, :limit => 16777215
    change_column :units, :note, :text, :limit => 16777215
    change_column :units, :access_condition_note, :text, :limit => 16777215
    change_column :units, :use_condition_note, :text, :limit => 16777215
    change_column :units, :tmp_reference_string, :text, :limit => 16777215
    change_column :units, :reference_number, :text, :limit => 16777215
    change_column :units, :fsc_name, :text, :limit => 16777215
    change_column :units, :fsc_surname, :text, :limit => 16777215
    change_column :units, :physical_container_type, :text, :limit => 16777215
    change_column :units, :physical_container_title, :text, :limit => 16777215
    change_column :units, :physical_container_number, :text, :limit => 16777215
  end
  def down
    change_column :units, :title, :text, :limit => 16777215
    change_column :units, :content, :text, :limit => 16777215
    change_column :units, :extent, :text, :limit => 16777215
    change_column :units, :arrangement_note, :text, :limit => 16777215
    change_column :units, :related_materials, :text, :limit => 16777215
    change_column :units, :physical_description, :text, :limit => 16777215
    change_column :units, :preservation_note, :text, :limit => 16777215
    change_column :units, :restoration, :text, :limit => 16777215
    change_column :units, :note, :text, :limit => 16777215
    change_column :units, :access_condition_note, :text, :limit => 16777215
    change_column :units, :use_condition_note, :text, :limit => 16777215
    change_column :units, :tmp_reference_string, :text, :limit => 16777215
    change_column :units, :reference_number, :text, :limit => 16777215
    change_column :units, :fsc_name, :text, :limit => 16777215
    change_column :units, :fsc_surname, :text, :limit => 16777215
    change_column :units, :physical_container_type, :text, :limit => 16777215
    change_column :units, :physical_container_number, :text, :limit => 16777215
  end
end
