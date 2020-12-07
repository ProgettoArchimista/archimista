class UpdateSc2CommissionNames < ActiveRecord::Migration
def up
    change_column :sc2_commission_names, :cmmn, :text, :limit => 16777215
  end
  def down
    change_column :sc2_commission_names, :cmmn, :text, :limit => 16777215
  end
end
