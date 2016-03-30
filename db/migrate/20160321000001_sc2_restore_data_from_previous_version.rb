class Sc2RestoreDataFromPreviousVersion < ActiveRecord::Migration

  extend Sc2Restore

  def self.up
    restore_d_f_s(nil)
    restore_bdm_oa(nil)
  end

  def self.down
    #irreversible migration
  end

private

end
