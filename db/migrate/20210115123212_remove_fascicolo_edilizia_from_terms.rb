class RemoveFascicoloEdiliziaFromTerms < ActiveRecord::Migration
  def change
    Term.connection.execute("DELETE FROM terms WHERE vocabulary_id=28 and position=2 and term_key='building_file' and term_value='fascicolo di edilizia'")
  end
end
