class UpdateUnitOtherReferenceNumbers < ActiveRecord::Migration
def up
    change_column :unit_other_reference_numbers, :other_reference_number, :text, :limit => 16777215
    change_column :unit_other_reference_numbers, :qualifier, :text, :limit => 16777215
    change_column :unit_other_reference_numbers, :note, :text, :limit => 16777215
  end
  def down
    change_column :unit_other_reference_numbers, :other_reference_number, :text, :limit => 16777215
    change_column :unit_other_reference_numbers, :qualifier, :text, :limit => 16777215
    change_column :unit_other_reference_numbers, :note, :text, :limit => 16777215
  end
end
