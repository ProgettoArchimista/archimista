class FeContext < ActiveRecord::Migration
  def change
  	create_table :fe_contexts, force: :cascade do |t|
      t.integer  "unit_id"
  		t.integer	"number",				limit: 4
  		t.integer	"sub_number",			limit: 4
  		t.string	"classification",		limit: 255
  		t.string	"applicant",			limit: 255
  		t.string	"request",				limit: 255
  		t.integer	"license_number",		limit: 4
  		t.integer	"license_year",			limit: 4
  		t.integer	"protocol_number",		limit: 4
  		t.date      "license_date"
  		t.integer	"habitability_number",	limit: 4
  		t.integer	"habitability_year",	limit: 4
  		t.date      "habitability_date"
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
  	end

  	add_index "fe_contexts", ["db_source", "legacy_id"], name: "index_fe_contexts_on_source_and_legacy_id", using: :btree
  	add_index "fe_contexts", ["unit_id"], name: "index_fe_contexts_on_unit_id", using: :btree
  end
end
