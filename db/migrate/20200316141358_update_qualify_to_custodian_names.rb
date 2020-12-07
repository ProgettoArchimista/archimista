class UpdateQualifyToCustodianNames < ActiveRecord::Migration
  def change
    CustodianName.connection.execute("UPDATE custodian_names set qualifier='OT' where qualifier='AU'")
  end
end
