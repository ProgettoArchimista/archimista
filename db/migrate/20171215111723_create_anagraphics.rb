class CreateAnagraphics < ActiveRecord::Migration
  def change
    create_table :anagraphics do |t|
	    t.string   "anagraphic_type",         limit: 255
	    t.string   "name",         limit: 255
	    t.string   "surname",        limit: 255
	    t.string   "start_date_place",    limit: 255
	    t.date     "start_date"
	    t.string   "end_date_place",      limit: 255
    	t.date     "end_date"
	    t.integer  "group_id",     limit: 4
	    t.string   "db_source",    limit: 255
	    t.string   "legacy_id",    limit: 255
	    t.datetime "created_at"
    	t.datetime "updated_at"
    end

    add_index "anagraphics", ["db_source", "legacy_id"], name: "index_anagraphics_on_source_and_legacy_id", using: :btree

    create_table "rel_unit_anagraphics", force: :cascade do |t|
	    t.integer  "unit_id",           limit: 4
	    t.integer  "anagraphic_id",        limit: 4
	    t.string   "db_source",         limit: 255
	    t.string   "legacy_unit_id",    limit: 255
	    t.string   "legacy_anagraphic_id", limit: 255
	    t.datetime "created_at"
	    t.datetime "updated_at"
	  end

	  add_index "rel_unit_anagraphics", ["db_source", "legacy_anagraphic_id"], name: "index_rel_unit_anagraphics_on_source_and_legacy_anagraphic_id", using: :btree
	  add_index "rel_unit_anagraphics", ["db_source", "legacy_unit_id"], name: "index_rel_unit_anagraphics_on_source_and_legacy_unit_id", using: :btree
	  add_index "rel_unit_anagraphics", ["anagraphic_id"], name: "index_rel_unit_anagraphics_on_anagraphic_id", using: :btree
	  add_index "rel_unit_anagraphics", ["unit_id"], name: "index_rel_unit_anagraphics_on_unit_id", using: :btree

  end
end


  