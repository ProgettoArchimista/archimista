class UpdateFeCadastrals < ActiveRecord::Migration
def up
    change_column :fe_cadastrals, :cadastral_municipality, :text, :limit => 16777215
  end
  def down
    change_column :fe_cadastrals, :cadastral_municipality, :text, :limit => 16777215
  end
end
