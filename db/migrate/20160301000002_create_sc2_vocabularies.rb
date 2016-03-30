# Upgrade 2.1.0 inizio
require 'date'

class CreateSc2Vocabularies < ActiveRecord::Migration
  def self.up
    #
    create_table "sc2_vocabularies", force: :cascade do |t|
      t.string   "name",       limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2_vocabularies", ["name"], name: "index_sc2_vocabularies_on_name"
    #
    create_table "sc2_terms", force: :cascade do |t|
      t.integer  "sc2_vocabulary_id"
      t.integer  "position"
      t.string   "term_key",           limit: 255
      t.string   "term_value",         limit: 255
      t.string   "term_scope",         limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "sc2_terms", ["sc2_vocabulary_id"], name: "index_sc2_terms_on_sc2_vocabulary_id"

    #
    voc_data_dir = "#{Rails.root}/db/migrate/20160301000002_data"
		
    prv_load_sc2_vocabulary(voc_data_dir, "units.sc2_tsk")
    prv_load_sc2_vocabulary(voc_data_dir, "sc2_authors.autr")
    prv_load_sc2_vocabulary(voc_data_dir, "sc2_attribution_reasons.autm")
    prv_load_sc2_vocabulary(voc_data_dir, "units.medium")
    prv_load_sc2_vocabulary(voc_data_dir, "sc2_techniques.mtct")
    prv_load_sc2_vocabulary(voc_data_dir, "sc2.mtce")
    prv_load_sc2_vocabulary(voc_data_dir, "sc2_scales.sca")
    prv_load_sc2_vocabulary(voc_data_dir, "sc2.sdtt")
    prv_load_sc2_vocabulary(voc_data_dir, "sc2.sdts")
	end

  def self.down	
    execute("DROP TABLE sc2_terms")
    execute("DROP TABLE sc2_vocabularies")
	end

private

  def prv_load_sc2_vocabulary(voc_data_dir, voc_name)
    voc = Sc2Vocabulary.new(:name => voc_name)
    voc.save
    voc_id = Sc2Vocabulary.where(:name => voc_name).first.id
    prv_load_voc_data_json(voc_data_dir, voc_name + ".json", voc_id)
  end

  def prv_load_voc_data_json(voc_data_dir, filename, voc_id)
		File.open(voc_data_dir + "/" + filename, "r") do |file|
			file.each do |line|
				voc_record = JSON.parse line
        voc_record["sc2_vocabulary_id"] = voc_id
				Sc2Term.create! voc_record
			end
		end
  end
end
# Upgrade 2.1.0 fine
