# Upgrade 2.1.0 inizio
class UpdateProjectCredits < ActiveRecord::Migration
  def self.up
    #
    voc = Vocabulary.where(:name => "project_credits.qualifier").first
    voc.name = "project_managers.qualifier"
    voc.save
    vocId_pm = voc.id
    #
    voc = Vocabulary.new(name: "project_stakeholders.qualifier")
    voc.save
    vocId_ps = voc.id

    #
    Term.where(:vocabulary_id => vocId_pm).each do |term|
      term.delete
    end
    #
    Term.new(vocabulary_id: vocId_pm, position: 1, term_key: "responsabile_scientifico", term_value: "responsabile scientifico").save
    Term.new(vocabulary_id: vocId_pm, position: 2, term_key: "responsabile_operativo", term_value: "responsabile operativo").save
    Term.new(vocabulary_id: vocId_pm, position: 3, term_key: "coordinatore", term_value: "coordinatore").save
    Term.new(vocabulary_id: vocId_pm, position: 4, term_key: "schedatore", term_value: "schedatore").save
    #
    Term.new(vocabulary_id: vocId_ps, position: 1, term_key: "finanziamento", term_value: "finanziamento").save
    Term.new(vocabulary_id: vocId_ps, position: 2, term_key: "realizzazione", term_value: "realizzazione").save
    Term.new(vocabulary_id: vocId_ps, position: 3, term_key: "promozione", term_value: "promozione").save
    Term.new(vocabulary_id: vocId_ps, position: 4, term_key: "coordinamento_operativo", term_value: "coordinamento operativo").save

    #
    create_table "project_managers" do |t|
      t.integer  "project_id"
      t.string   "qualifier",   limit: 255
      t.string   "name", limit: 255
      t.string   "db_source",   limit: 255
      t.string   "legacy_id",   limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "project_stakeholders" do |t|
      t.integer  "project_id"
      t.string   "qualifier",   limit: 255
      t.string   "name", limit: 255
      t.string   "db_source",   limit: 255
      t.string   "legacy_id",   limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    moveInfos =
    [
      { :src_credit_type => "PM", :src_qualifier => "coordinatore", :dst_tbl => "project_managers", :dst_qualifier => "coordinatore" },
      { :src_credit_type => "PM", :src_qualifier => "schedatore", :dst_tbl => "project_managers", :dst_qualifier => "schedatore" },
      { :src_credit_type => "PM", :src_qualifier => "responsabile scientifico", :dst_tbl => "project_managers", :dst_qualifier => "responsabile scientifico" },
      { :src_credit_type => "PS", :src_qualifier => "schedatore", :dst_tbl => "project_managers", :dst_qualifier => "schedatore" },
      { :src_credit_type => "PS", :src_qualifier => "responsabile scientifico", :dst_tbl => "project_managers", :dst_qualifier => "responsabile scientifico" },
      { :src_credit_type => "PM", :src_qualifier => "finanziatore", :dst_tbl => "project_stakeholders", :dst_qualifier => "finanziamento" },
      { :src_credit_type => "PM", :src_qualifier => "promotore", :dst_tbl => "project_stakeholders", :dst_qualifier => "promozione" },
      { :src_credit_type => "PM", :src_qualifier => "realizzatore", :dst_tbl => "project_stakeholders", :dst_qualifier => "realizzazione" },
      { :src_credit_type => "PS", :src_qualifier => "coordinatore", :dst_tbl => "project_stakeholders", :dst_qualifier => "coordinamento operativo" },
      { :src_credit_type => "PS", :src_qualifier => "finanziatore", :dst_tbl => "project_stakeholders", :dst_qualifier => "finanziamento" },
      { :src_credit_type => "PS", :src_qualifier => "promotore", :dst_tbl => "project_stakeholders", :dst_qualifier => "promozione" },
      { :src_credit_type => "PS", :src_qualifier => "realizzatore", :dst_tbl => "project_stakeholders", :dst_qualifier => "realizzazione" }
    ]
    moveInfos.each do |moving|
      execute("INSERT INTO #{moving[:dst_tbl]} (project_id, qualifier, name, db_source, legacy_id, created_at, updated_at) SELECT project_id, '#{moving[:dst_qualifier]}', credit_name, db_source, legacy_id, created_at, updated_at FROM project_credits WHERE credit_type='#{moving[:src_credit_type]}' AND qualifier = '#{moving[:src_qualifier]}'")
      execute("DELETE FROM project_credits WHERE credit_type='#{moving[:src_credit_type]}' AND qualifier = '#{moving[:src_qualifier]}'")
    end
    execute("INSERT INTO project_managers (project_id, qualifier, name, db_source, legacy_id, created_at, updated_at) SELECT project_id, qualifier, credit_name, db_source, legacy_id, created_at, updated_at FROM project_credits WHERE credit_type='PM'")
    execute("INSERT INTO project_stakeholders (project_id, qualifier, name, db_source, legacy_id, created_at, updated_at) SELECT project_id, qualifier, credit_name, db_source, legacy_id, created_at, updated_at FROM project_credits WHERE credit_type='PS'")
    execute("INSERT INTO project_managers (project_id, qualifier, name, db_source, legacy_id, created_at, updated_at) SELECT project_id, qualifier, credit_name, db_source, legacy_id, created_at, updated_at FROM project_credits")
    execute("DROP TABLE project_credits")

		add_index "project_managers", ["project_id"], name: "index_project_managers_on_project_id", using: :btree
		add_index "project_managers", ["db_source", "legacy_id"], name: "index_project_managers_on_source_and_legacy_id", using: :btree

		add_index "project_stakeholders", ["project_id"], name: "index_project_stakeholders_on_project_id", using: :btree
		add_index "project_stakeholders", ["db_source", "legacy_id"], name: "index_project_stakeholders_on_source_and_legacy_id", using: :btree
	end

  def self.down	
		voc = Vocabulary.where(:name => "project_managers.qualifier").first
    voc.name = "project_credits.qualifier"
    voc.save
    vocId_pm = voc.id
    #
		voc = Vocabulary.where(:name => "project_stakeholders.qualifier").first
    vocId_ps = voc.id
		voc.delete
		#
    Term.where(:vocabulary_id => vocId_pm).each do |term|
      term.delete
    end
    #
    Term.where(:vocabulary_id => vocId_ps).each do |term|
      term.delete
    end
    #
    Term.new(vocabulary_id: vocId_pm, position: 1, term_key: "coordinator", term_value: "coordinatore").save
    Term.new(vocabulary_id: vocId_pm, position: 2, term_key: "funder", term_value: "finanziatore").save
    Term.new(vocabulary_id: vocId_pm, position: 3, term_key: "promoter", term_value: "promotore").save
    Term.new(vocabulary_id: vocId_pm, position: 4, term_key: "realizzatore", term_value: "realizzatore").save
    Term.new(vocabulary_id: vocId_pm, position: 5, term_key: "schedatore", term_value: "schedatore").save
    Term.new(vocabulary_id: vocId_pm, position: 6, term_key: "scientific_consultant", term_value: "responsabile scientifico").save

		create_table "project_credits", force: :cascade do |t|
			t.integer  "project_id"
			t.string   "credit_type", limit: 255
			t.string   "qualifier",   limit: 255
			t.string   "credit_name", limit: 255
			t.string   "db_source",   limit: 255
			t.string   "legacy_id",   limit: 255
			t.datetime "created_at"
			t.datetime "updated_at"
		end

    moveInfos =
    [
      { :src_qualifier => "coordinatore", :src_tbl => "project_managers", :dst_credit_type => "PM", :dst_qualifier => "coordinatore" },
      { :src_qualifier => "schedatore", :src_tbl => "project_managers", :dst_credit_type => "PM", :dst_qualifier => "schedatore" },
      { :src_qualifier => "responsabile scientifico", :src_tbl => "project_managers", :dst_credit_type => "PM", :dst_qualifier => "responsabile scientifico" },
      { :src_qualifier => "responsabile operativo", :src_tbl => "project_managers", :dst_credit_type => "PM", :dst_qualifier => "" },
			
      { :src_qualifier => "finanziamento", :src_tbl => "project_stakeholders", :dst_credit_type => "PS", :dst_qualifier => "finanziatore" },
      { :src_qualifier => "realizzazione", :src_tbl => "project_stakeholders", :dst_credit_type => "PS", :dst_qualifier => "realizzatore	" },
      { :src_qualifier => "promozione", :src_tbl => "project_stakeholders", :dst_credit_type => "PS", :dst_qualifier => "promotore" },
      { :src_qualifier => "coordinamento operativo", :src_tbl => "project_stakeholders", :dst_credit_type => "PS", :dst_qualifier => "coordinatore" }
		]

    moveInfos.each do |moving|
      execute("INSERT INTO project_credits (project_id, credit_type, qualifier, credit_name, db_source, legacy_id, created_at, updated_at) SELECT project_id, '#{moving[:dst_credit_type]}', '#{moving[:dst_qualifier]}', name, db_source, legacy_id, created_at, updated_at FROM #{moving[:src_tbl]} WHERE qualifier = '#{moving[:src_qualifier]}'")
      execute("DELETE FROM #{moving[:src_tbl]} WHERE qualifier = '#{moving[:src_qualifier]}'")
    end
		execute("INSERT INTO project_credits (project_id, credit_type, qualifier, credit_name, db_source, legacy_id, created_at, updated_at) SELECT project_id, 'PM', qualifier, name, db_source, legacy_id, created_at, updated_at FROM project_managers")
    execute("DROP TABLE project_managers")

		execute("INSERT INTO project_credits (project_id, credit_type, qualifier, credit_name, db_source, legacy_id, created_at, updated_at) SELECT project_id, 'PS', qualifier, name, db_source, legacy_id, created_at, updated_at FROM project_stakeholders")
    execute("DROP TABLE project_stakeholders")

		add_index "project_credits", ["project_id"], name: "index_project_credits_on_project_id", using: :btree
		add_index "project_credits", ["db_source", "legacy_id"], name: "index_project_credits_on_source_and_legacy_id", using: :btree
	end
end
# Upgrade 2.1.0 fine
