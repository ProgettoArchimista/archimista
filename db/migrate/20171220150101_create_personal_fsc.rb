class CreatePersonalFsc < ActiveRecord::Migration
  def change
    create_table :personal_fscs, force: :cascade do |t|
    	t.integer  "unit_id",       limit: 4
    	t.string   "code",          limit: 255
    	t.date     "fsc_opened_at"
    	t.date     "fsc_closed_at"
    	t.string   "nationality",   limit: 255
    	t.string   "organization",  limit: 255
    	t.string   "db_source",     limit: 255
      	t.string   "legacy_id",     limit: 255
      	t.datetime "created_at"
      	t.datetime "updated_at"
    end

    add_index "personal_fscs", ["db_source", "legacy_id"], name: "index_personal_fscs_on_source_and_legacy_id", using: :btree
  	add_index "personal_fscs", ["unit_id"], name: "index_personal_fscs_on_unit_id", using: :btree
  end
end