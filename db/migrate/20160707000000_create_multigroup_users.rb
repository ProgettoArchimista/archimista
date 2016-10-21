# Upgrade 2.2.0 inizio
class CreateMultigroupUsers < ActiveRecord::Migration
  def self.up
    #
    create_table "rel_user_groups", force: :cascade do |t|
      t.integer  "user_id"
      t.integer  "group_id"
      t.string   "role", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by", default: 1
      t.integer  "updated_by", default: 1
    end
    add_index "rel_user_groups", ["user_id"], name: "index_rel_user_groups_on_user_id"
    add_index "rel_user_groups", ["group_id"], name: "index_rel_user_groups_on_group_id"
    #
    execute("INSERT INTO rel_user_groups (user_id,group_id,role,created_at,updated_at,created_by,updated_by) SELECT id,group_id,role,created_at,updated_at,1,1 FROM users")
    #
    remove_column :users, :group_id
    remove_column :users, :role
	end

  def self.down	
    #irreversible migration
	end
end
# Upgrade 2.2.0 fine
