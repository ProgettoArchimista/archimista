class FeLandParcel < ActiveRecord::Migration
  def change
  	create_table :fe_land_parcels, force: :cascade do |t|
      t.integer  "unit_id"
  		t.string	"land_parcel_number",	limit: 255
  		t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
  	end

  	add_index "fe_land_parcels", ["db_source", "legacy_id"], name: "index_fe_land_parcels_on_source_and_legacy_id", using: :btree
  	add_index "fe_land_parcels", ["unit_id"], name: "index_fe_land_parcels_on_unit_id", using: :btree
  end
end
