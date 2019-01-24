class FeOpera < ActiveRecord::Migration
  def change
  	create_table :fe_operas, force: :cascade do |t|
      t.integer  "unit_id"
  		t.boolean   "is_present",   	limit: 1,     default: false, null: false
  		t.string	"status",			limit: 10
  		t.string	"building_name",	limit: 255
  		t.string	"building_type",	limit: 255
  		t.string	"place_name",		limit: 255
  		t.string	"place_type",		limit: 255
  		t.string	"house_number",		limit: 255
  		t.string	"district",			limit: 255
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
  	end

  	add_index "fe_operas", ["db_source", "legacy_id"], name: "index_fe_operas_on_source_and_legacy_id", using: :btree
  	add_index "fe_operas", ["unit_id"], name: "index_fe_operas_on_unit_id", using: :btree
  end
end
