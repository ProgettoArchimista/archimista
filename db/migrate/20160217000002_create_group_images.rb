# Upgrade 2.1.0 inizio
class CreateGroupImages < ActiveRecord::Migration
  def self.up
    #
    create_table "group_images", force: :cascade do |t|
      t.integer  "related_group_id"
      t.string   "type",               limit: 255
      t.integer  "position"
      t.string   "title",              limit: 255
      t.text     "description"
      t.string   "access_token",       limit: 255
      t.string   "asset_file_name",    limit: 255
      t.string   "asset_content_type", limit: 255
      t.integer  "asset_file_size"
      t.datetime "asset_updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.integer  "group_id"
      t.string   "db_source",          limit: 255
      t.string   "legacy_id",          limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

		add_index "group_images", ["related_group_id"], name: "index_group_images_on_related_group_id_id"
    add_index "group_images", ["db_source", "legacy_id"], name: "index_group_images_on_source_and_legacy_id"
	end

  def self.down	
    execute("DROP TABLE group_images")
	end
end
# Upgrade 2.1.0 fine
