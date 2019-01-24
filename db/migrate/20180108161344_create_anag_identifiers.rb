class CreateAnagIdentifiers < ActiveRecord::Migration
  def change
    create_table :anag_identifiers do |t|
    	t.integer  "anagraphic_id",    limit: 4
    	t.string   "identifier",       limit: 255
    	t.string   "qualifier",  	   limit: 255
    	t.string   "db_source",        limit: 255
      	t.string   "legacy_id",        limit: 255
      	t.datetime "created_at"
      	t.datetime "updated_at"
    end

    add_index "anag_identifiers", ["db_source", "legacy_id"], name: "index_anag_identifiers_on_source_and_legacy_id", using: :btree
  	add_index "anag_identifiers", ["anagraphic_id"], name: "index_anag_identifiers_on_anagraphic_id", using: :btree

  end
end
