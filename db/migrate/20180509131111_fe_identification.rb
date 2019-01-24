class FeIdentification < ActiveRecord::Migration
  def change
  	create_table :fe_identifications, force: :cascade do |t|
      t.integer  "unit_id"
  		t.string	"code",			limit: 255
  		t.integer	"file_year",	limit: 4
  		t.string	"category",		limit: 255
  		t.string	"identification_class",		limit: 255
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
  	end

  	add_index "fe_identifications", ["db_source", "legacy_id"], name: "index_fe_identifications_on_source_and_legacy_id", using: :btree
  	add_index "fe_identifications", ["unit_id"], name: "index_fe_identifications_on_unit_id", using: :btree
  end
end
