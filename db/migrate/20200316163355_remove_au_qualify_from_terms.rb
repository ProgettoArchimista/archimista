class RemoveAuQualifyFromTerms < ActiveRecord::Migration
  def change
    Term.connection.execute("DELETE FROM terms WHERE term_key='authorized_name' and term_value='AU'")
  end
end
