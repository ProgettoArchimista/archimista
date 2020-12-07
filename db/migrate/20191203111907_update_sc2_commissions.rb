class UpdateSc2Commissions < ActiveRecord::Migration
def up
    change_column :sc2_commissions, :cmmc, :text, :limit => 16777215
  end
  def down
    change_column :sc2_commissions, :cmmc, :text, :limit => 16777215
  end
end
