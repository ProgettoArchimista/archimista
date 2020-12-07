class UpdateHeadingsGroupId < ActiveRecord::Migration
  def up
    change_column_default(:headings, :group_id, '1')
    Term.connection.execute("UPDATE headings SET group_id = '1' WHERE ISNULL(group_id)")
  end

  def down
    change_column_default(:headings, :group_id, nil)

    # ATTENZIONE: quanto segue può coinvolgere più righe di quelle coinvolte nel metodo up
    Term.connection.execute("UPDATE headings SET group_id = NULL WHERE group_id = '1'")
  end
end
