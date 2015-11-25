class ProjectsController < ApplicationController

  load_and_authorize_resource

  def index
# Upgrade 2.0.0 inizio
#    @projects = Project.accessible_by(current_ability, :read).paginate :page => params[:page], :order => "name"
    @projects = Project.accessible_by(current_ability, :read).order("name").page(params[:page])
# Upgrade 2.0.0 fine
  end

  def list
    search_param  = [params[:term], params[:q]].find(&:present?)
    projects      = Project.accessible_by(current_ability, :read).autocomplete_list(search_param)

    respond_to do |format|
      format.json { render :json => projects.map(&:attributes) }
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
    terms
    setup_relation_collections
  end

  def edit
    @project = Project.find(params[:id])
    terms
    setup_relation_collections
  end

  def create
# Upgrade 2.0.0 inizio Strong parameters
#    @project = Project.new(params[:project]).tap do |project|
    @project = Project.new(project_params).tap do |project|
# Upgrade 2.0.0 fine
      project.created_by = current_user.id
      project.updated_by = current_user.id
      project.group_id = current_user.group_id
    end
    @project.save
    setup_relation_collections

    if @project.valid?
      if params[:save_and_continue]
        redirect_to(edit_project_url(@project), :notice => 'Scheda creata')
      else
        redirect_to(@project, :notice => 'Scheda creata')
      end
    else
      terms
      render :action => "new"
    end
  end

  def update
    @project = Project.find(params[:id]).tap {|project| project.updated_by = current_user.id}
# Upgrade 2.0.0 inizio Strong parameters
#    @project.update_attributes(params[:project])
    @project.update_attributes(project_params)
# Upgrade 2.0.0 fine
    setup_relation_collections

    if @project.valid?
      if params[:save_and_continue]
        redirect_to(edit_project_url(@project), :notice => 'Scheda aggiornata')
      else
        redirect_to(@project, :notice => 'Scheda aggiornata')
      end
    else
      terms
      render :action => "edit"
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    redirect_to(projects_url, :notice => 'Scheda eliminata')
  end

  private

  def setup_relation_collections
    return unless @project
    relation_collections  :related => "fonds", :through => "rel_project_fonds",
      :available => Fond.accessible_by(current_ability, :read).roots.active.count('id'),
      :suggested => Proc.new{
# Upgrade 2.0.0 inizio
#      Fond.roots.active.scoped( :select => 'id, name', :order => "name" )
      Fond.roots.active.select('id, name').order("name")
# Upgrade 2.0.0 fine
    }
  end

# Upgrade 2.0.0 inizio Strong parameters
  def project_params
    params.require(:project).permit!
  end
# Upgrade 2.0.0 fine

end

