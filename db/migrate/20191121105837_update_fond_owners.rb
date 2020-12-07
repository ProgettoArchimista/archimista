class UpdateFondOwners < ActiveRecord::Migration
  def up
    change_column :fond_owners, :owner, :text, :limit => 16777215
  end
  def down
    change_column :fond_owners, :owner, :text, :limit => 16777215
  end
end
