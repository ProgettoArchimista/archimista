# Upgrade 2.2.0 inizio
class UpdateUnitsSc2TskVocabulary < ActiveRecord::Migration
  def self.up
    vocId = prv_get_target_sc2_vocabulary_id
    #
    terms = Sc2Term.where(:sc2_vocabulary_id => vocId)
    terms.each do |t|
      t.term_key = t.term_value
      t.save
    end
  end

  def self.down
    vocId = prv_get_target_sc2_vocabulary_id

    term = Sc2Term.where(:sc2_vocabulary_id => vocId, :term_value => "CARS").first
    term.term_key = "CARS - Cartografia storica"
    term.save

    term = Sc2Term.where(:sc2_vocabulary_id => vocId, :term_value => "D").first
    term.term_key = "D - Disegno artistico"
    term.save

    term = Sc2Term.where(:sc2_vocabulary_id => vocId, :term_value => "DT").first
    term.term_key = "DT - Disegno tecnico"
    term.save

    term = Sc2Term.where(:sc2_vocabulary_id => vocId, :term_value => "F").first
    term.term_key = "F - Fotografia"
    term.save

    term = Sc2Term.where(:sc2_vocabulary_id => vocId, :term_value => "S").first
    term.term_key = "S - Stampa"
    term.save
  end
	
	private
	
	def prv_get_target_sc2_vocabulary_id
    return Sc2Vocabulary.select(:id).where(:name => "units.sc2_tsk").first.id
	end
end
# Upgrade 2.2.0 fine
