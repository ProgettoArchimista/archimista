class UpdateLangs < ActiveRecord::Migration
  def up
    Lang.update_all(active: 1)
    Lang.where(it_name: "").update_all("it_name=en_name")
    Lang.where(it_name: nil).update_all("it_name=en_name")
  end
  def down
    Lang.update_all(active: 0)
  end
end
