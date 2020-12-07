class UpdateFscOrganization < ActiveRecord::Migration
def up
    change_column :fsc_organizations, :organization, :text, :limit => 16777215
  end
  def down
    change_column :fsc_organizations, :organization, :text, :limit => 16777215
  end
end
