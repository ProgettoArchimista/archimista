class FeDesigner < ActiveRecord::Migration
  def change
  	create_table :fe_designers, force: :cascade do |t|
      t.integer  "unit_id"
  		t.string	"designer_name",	limit: 255
  		t.string	"designer_role",	limit: 255
  		t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
  	end

  	add_index "fe_designers", ["db_source", "legacy_id"], name: "index_fe_designers_on_source_and_legacy_id", using: :btree
  	add_index "fe_designers", ["unit_id"], name: "index_fe_designers_on_unit_id", using: :btree
  end
end
