class UpdateQualifyToCreatorNames < ActiveRecord::Migration
  def change
    CreatorName.connection.execute("UPDATE creator_names set qualifier='OT' where qualifier='AU'")
  end
end
