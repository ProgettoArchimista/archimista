class AddPublishedToCreators < ActiveRecord::Migration
  def change
    add_column :creators, :published, :boolean, default: true
  end
end
