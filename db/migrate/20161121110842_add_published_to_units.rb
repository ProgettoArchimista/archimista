class AddPublishedToUnits < ActiveRecord::Migration
  def change
    add_column :units, :published, :boolean, default: true
  end
end
