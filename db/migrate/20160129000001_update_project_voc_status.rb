# Upgrade 2.1.0 inizio
class UpdateProjectVocStatus < ActiveRecord::Migration
  def self.up
    vocId = prv_get_target_vocabulary_id
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "open").first
    term.term_key = "in_corso"
    term.term_value = "in corso"
    term.save
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "closed").first
    term.term_key = "concluso"
    term.term_value = "concluso"
    term.save
    #
    term = Term.new(vocabulary_id: vocId, position: 3, term_key: "revisione", term_value: "revisione")
    term.save
    #
    term = Term.new(vocabulary_id: vocId, position: 4, term_key: "pubblicato", term_value: "pubblicato")
    term.save
  end

  def self.down
		projects = Project.where("status IS NOT NULL")
		projects.each do |project|
			case project.status
				when "revisione"
					new_value = ""
				when "pubblicato"
					new_value = ""
			end
			if (!new_value.nil?)
				project.status = new_value
				project.save
			end
		end
		#
    vocId = prv_get_target_vocabulary_id
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "pubblicato").first
    term.delete
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "revisione").first
    term.delete
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "concluso").first
    term.term_key = "closed"
    term.save
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "in_corso").first
    term.term_key = "open"
    term.save
  end
	
	private
	
	def prv_get_target_vocabulary_id
    return Vocabulary.select(:id).where(:name => "projects.status").first.id
	end
end
# Upgrade 2.1.0 fine
