# Upgrade 2.1.0 inizio
class CreateSc2 < ActiveRecord::Migration
  def self.up
    add_column :units, :sc2_tsk, :string, :limit => 10
    #
    create_table "sc2s", force: :cascade do |t|
      t.integer  "unit_id"
      t.string   "sgti",       limit: 250						# tutte
      t.string   "cmmr",       limit: 25						# DT
      t.string   "lrc",        limit: 250						# F
      t.string   "lrd",        limit: 50 						# F
      t.string   "mtce",       limit: 250						# DT
      t.string   "sdtt",       limit: 50 						# DT,CARS
      t.string   "sdts",       limit: 50 						# CARS
      t.string   "dpgf",       limit: 100						# DT
      t.float    "misa",       limit: 6 		 				# tutte
      t.float    "misl",       limit: 6							# tutte
      t.string   "ort",        limit: 50						# CARS
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2s", ["db_source", "legacy_id"], name: "index_sc2s_on_db_source_and_legacy_id", using: :btree
    add_index "sc2s", ["unit_id"], name: "index_sc2s_on_unit_id", using: :btree

    #
    create_table "sc2_techniques", force: :cascade do |t|
      t.integer  "unit_id"
      t.string   "mtct",       limit: 250						# BDM=70, DT=250, per le altre con Supporto in MTC
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2_techniques", ["db_source", "legacy_id"], name: "index_sc2_techniques_on_db_source_and_legacy_id", using: :btree
    add_index "sc2_techniques", ["unit_id"], name: "index_sc2_techniques_on_unit_id", using: :btree

    #
    create_table "sc2_scales", force: :cascade do |t|
      t.integer  "unit_id"
      t.string   "sca",        limit: 100						# DT,CARS
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2_scales", ["db_source", "legacy_id"], name: "index_sc2_scales_on_db_source_and_legacy_id", using: :btree
    add_index "sc2_scales", ["unit_id"], name: "index_sc2_scales_on_unit_id", using: :btree

    #
    create_table "sc2_textual_elements", force: :cascade do |t|
      t.integer  "unit_id"
      t.string   "isri",       limit: 2200					# tutte
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2_textual_elements", ["db_source", "legacy_id"], name: "index_sc2_textual_elements_on_db_source_and_legacy_id", using: :btree
    add_index "sc2_textual_elements", ["unit_id"], name: "index_sc2_textual_elements_on_unit_id", using: :btree

    #
    create_table "sc2_visual_elements", force: :cascade do |t|
      t.integer  "unit_id"
      t.string   "stmd",       limit: 500					 	# tutte
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2_visual_elements", ["db_source", "legacy_id"], name: "index_sc2_visual_elements_on_db_source_and_legacy_id", using: :btree
    add_index "sc2_visual_elements", ["unit_id"], name: "index_sc2_visual_elements_on_unit_id", using: :btree

    #
    create_table "sc2_authors", force: :cascade do |t|
      t.integer  "unit_id"
      t.string   "autr",       limit: 50					 	# tutte
      t.string   "autn",       limit: 150					 	# tutte
      t.string   "auta",       limit: 100					 	# tutte
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2_authors", ["db_source", "legacy_id"], name: "index_sc2_authors_on_db_source_and_legacy_id", using: :btree
    add_index "sc2_authors", ["unit_id"], name: "index_sc2_authors_on_unit_id", using: :btree

    #
    create_table "sc2_attribution_reasons", force: :cascade do |t|
      t.integer  "sc2_author_id"
      t.string   "autm",       limit: 250					 	# tutte
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2_attribution_reasons", ["db_source", "legacy_id"], name: "index_sc2_attribution_reasons_on_db_source_and_legacy_id", using: :btree
    add_index "sc2_attribution_reasons", ["sc2_author_id"], name: "index_sc2_attribution_reasons_on_sc2_author_id", using: :btree

    #
    create_table "sc2_commissions", force: :cascade do |t|
      t.integer  "unit_id"
      t.string   "cmmc",       limit: 100					 	# tutte
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2_commissions", ["db_source", "legacy_id"], name: "index_sc2_commissions_on_db_source_and_legacy_id", using: :btree
    add_index "sc2_commissions", ["unit_id"], name: "index_sc2_commissions_on_unit_id", using: :btree

    #
    create_table "sc2_commission_names", force: :cascade do |t|
      t.integer  "sc2_commission_id"
      t.string   "cmmn",       limit: 70					 	# tutte
      t.string   "db_source",  limit: 255
      t.string   "legacy_id",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2_commission_names", ["db_source", "legacy_id"], name: "index_sc2_commission_names_on_db_source_and_legacy_id", using: :btree
    add_index "sc2_commission_names", ["sc2_commission_id"], name: "index_sc2_commission_names_on_sc2_commission_id", using: :btree
	end

  def self.down	
    #irreversible migration
	end
end
# Upgrade 2.1.0 fine
