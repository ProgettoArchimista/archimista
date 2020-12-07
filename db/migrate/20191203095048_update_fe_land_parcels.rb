class UpdateFeLandParcels < ActiveRecord::Migration
def up
    change_column :fe_land_parcels, :land_parcel_number, :text, :limit => 16777215
  end
  def down
    change_column :fe_land_parcels, :land_parcel_number, :text, :limit => 16777215
  end
end
