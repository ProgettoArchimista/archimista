# Upgrade 2.1.0 inizio
class UpdateProjectVocProjectType < ActiveRecord::Migration
  def self.up
    vocId = prv_get_target_vocabulary_id
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "riordino").first
    term.term_value = "riordino"
    term.position = 2
    term.save
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "schedatura").first
    term.term_key = "recupero"
    term.term_value = "recupero"
    term.position = 3
    term.save
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "censimento").first
    term.position = 1
    term.save
    #
    term = Term.new(vocabulary_id: vocId, position: 4, term_key: "elenchi", term_value: "elenchi")
    term.save
    #
		projects = Project.where("project_type IS NOT NULL")
		projects.each do |project|
			case project.project_type
				when "riordino e schedatura"
					new_value = "riordino"
				when "schedatura"
					new_value = "recupero"
				else
					new_value = nil
			end
			if (!new_value.nil?)
				project.project_type = new_value
				project.save
			end
		end
  end

  def self.down
		projects = Project.where("project_type IS NOT NULL")
		projects.each do |project|
			case project.project_type
				when "riordino"
					new_value = "riordino e schedatura"
				when "recupero"
					new_value = "schedatura"
				when "elenchi"
					new_value = ""
				else
					new_value = nil
			end
			if (!new_value.nil?)
				project.project_type = new_value
				project.save
			end
		end
		#
    vocId = prv_get_target_vocabulary_id
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "elenchi").first
    term.delete
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "censimento").first
    term.position = 3
    term.save
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "recupero").first
    term.term_key = "schedatura"
    term.term_value = "schedatura"
    term.position = 2
    term.save
    #
    term = Term.where(:vocabulary_id => vocId, :term_key => "riordino").first
    term.term_value = "riordino e schedatura"
    term.position = 1
    term.save
  end
	
	private
	
	def prv_get_target_vocabulary_id
    return Vocabulary.select(:id).where(:name => "projects.project_type").first.id
	end
end
# Upgrade 2.1.0 fine
