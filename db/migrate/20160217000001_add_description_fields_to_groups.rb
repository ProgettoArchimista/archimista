class AddDescriptionFieldsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :short_name, :string, :limit => 30
    add_column :groups, :site_caption, :string, :limit => 255
    add_column :groups, :description, :text
    add_column :groups, :credits_link_caption, :string, :limit => 255
    add_column :groups, :credits, :text

    case ActiveRecord::Base.configurations[Rails.env]['adapter']
      when 'sqlite', 'sqlite3'
        execute("UPDATE groups SET short_name = 'Gruppo' || id")
      when 'mysql', 'mysql2'
        execute("UPDATE groups SET short_name = CONCAT('Gruppo', id)")
    end
  end

  def self.down
    remove_column :groups, :short_name
    remove_column :groups, :site_caption
    remove_column :groups, :description
    remove_column :groups, :credits_link_caption
    remove_column :groups, :credits
  end
end
