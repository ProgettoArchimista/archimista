class AddPublishedToFonds < ActiveRecord::Migration
  def change
    add_column :fonds, :published, :boolean, default: true
  end
end
