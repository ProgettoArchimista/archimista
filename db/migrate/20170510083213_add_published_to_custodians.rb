class AddPublishedToCustodians < ActiveRecord::Migration
  def change
    add_column :custodians, :published, :boolean, default: true
  end
end
