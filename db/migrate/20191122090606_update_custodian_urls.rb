class UpdateCustodianUrls < ActiveRecord::Migration
  def up
    change_column :custodian_urls, :note, :text, :limit => 16777215
  end
  def down
    change_column :custodian_urls, :note, :text, :limit => 16777215
  end
end
