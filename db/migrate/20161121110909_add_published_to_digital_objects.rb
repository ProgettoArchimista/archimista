class AddPublishedToDigitalObjects < ActiveRecord::Migration
  def change
    add_column :digital_objects, :published, :boolean, default: true
  end
end
