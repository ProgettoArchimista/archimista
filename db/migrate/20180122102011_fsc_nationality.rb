class FscNationality < ActiveRecord::Migration
  def change
  	create_table :fsc_nationalities, force: :cascade do |t|
    	t.integer  "unit_id",       limit: 4
    	t.string   "nationality",   limit: 255
    	t.string   "db_source",     limit: 255
    	t.string   "legacy_id",     limit: 255
    	t.datetime "created_at"
    	t.datetime "updated_at"
    end

    add_index "fsc_nationalities", ["db_source", "legacy_id"], name: "index_fsc_nationalities_on_source_and_legacy_id", using: :btree
  	add_index "fsc_nationalities", ["unit_id"], name: "index_fsc_nationalities_on_unit_id", using: :btree
  end
end
