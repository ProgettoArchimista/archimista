module ProjectsHelper
	
	def publish
    	@project = Project.find(project.id)
    	@project.update_attribute(published: true)
    	redirect_to(projects_url, :notice => 'Scheda aggiornata')
  	end

  	def unpublish
    	@project = Project.find(project.id)
    	@project.update_attribute(published: false)
    	redirect_to(projects_url, :notice => 'Scheda aggiornata')
  	end
end
