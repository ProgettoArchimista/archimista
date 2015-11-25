class UpdateImports < ActiveRecord::Migration
  def self.up
    imports = Import.all
    imports.each do |import|
      import.importable_type = 'Fond'
# Upgrade 2.0.0 inizio
#      import.importable_id = Fond.all(:select => :id, :conditions => "db_source = '#{import.identifier}' AND ancestry IS NULL").first.id
      import.importable_id = Fond.select(:id).where("db_source = '#{import.identifier}' AND ancestry IS NULL").first.id
# Upgrade 2.0.0 fine
      import.save
    end
  end

  def self.down
  end
end
