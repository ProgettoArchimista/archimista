class FeCadastral < ActiveRecord::Migration
  def change
  	create_table :fe_cadastrals, force: :cascade do |t|
      t.integer  "unit_id"
  		t.integer   "way_code",   				limit: 4
  		t.string	"cadastral_municipality",	limit: 255
  		t.integer   "municipality_code",   		limit: 4
  		t.integer   "paper_code",   			limit: 4
  		t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
  	end

  	add_index "fe_cadastrals", ["db_source", "legacy_id"], name: "index_fe_cadastrals_on_source_and_legacy_id", using: :btree
  	add_index "fe_cadastrals", ["unit_id"], name: "index_fe_cadastrals_on_unit_id", using: :btree
  end
end
