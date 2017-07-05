class AddPublishedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :published, :boolean, default: true
  end
end
