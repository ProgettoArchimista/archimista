class ProjectsController < ApplicationController
  include FondsHelper
  load_and_authorize_resource
# Upgrade 2.2.0 inizio
  skip_load_and_authorize_resource :only => [ :list ]
# Upgrade 2.2.0 fine

# Upgrade 2.2.0 inizio
  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        if (["show","edit","update","destroy"].include?(params[:action]))
          p = Project.find(params[:id])
          @current_ability ||= Ability.new(current_user, p.group_id)
        elsif (["list"].include?(params[:action]))
          group_id = str2int(params[:group_id])
          @current_ability ||= Ability.new(current_user, group_id)
        elsif (["index"].include?(params[:action]))
          @current_ability ||= Ability.new(current_user, -1)
        elsif (["new","create"].include?(params[:action]))
          if params[:group_id].present?
            group_id = str2int(params[:group_id])
            @current_ability ||= Ability.new(current_user, group_id)
          end
        end
      end
    end
    if @current_ability.nil?
      @current_ability = super
    end
    return @current_ability
  end
# Upgrade 2.2.0 fine

  def index
# Upgrade 2.0.0 inizio
#    @projects = Project.accessible_by(current_ability, :read).paginate :page => params[:page], :order => "name"
# Upgrade 2.2.0 inizio
#    @projects = Project.accessible_by(current_ability, :read).order("name").page(params[:page])
    @projects = Project.search(params[:q],params[:qpt],params[:qps]).accessible_by(current_ability, :read).order("name").page(params[:page])
# Upgrade 2.2.0 fine
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
# Upgrade 2.2.0 inizio
#      project.group_id = current_user.group_id
        if current_user.is_multi_group_user?()
          project.group_id = current_ability.target_group_id
        else
          project.group_id = current_user.rel_user_groups[0].group_id
        end
# Upgrade 2.2.0 fine
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

# Upgrade 3.0.0 inizio
# Aggiunte azioni di pubblicazione e rimozione pubblicazione a cascata progetto/fondi/unità/oggetti
  def publish
    @project = Project.find(params[:id])
    @project.update_attribute(:published, true)
    @related_fonds = RelProjectFond.where(project_id: params[:id])
    if @related_fonds.empty?
      redirect_to(projects_url, :notice => 'Scheda aggiornata')
    else
      @related_fonds.each do |rel_fond|
        publish_fond(rel_fond.fond_id)
      end
      redirect_to(projects_url, :notice => 'Scheda aggiornata')
    end
    
  end

  def unpublish
    @project = Project.find(params[:id])
    @project.update_attribute(:published, false)
    @related_fonds = RelProjectFond.where(project_id: params[:id])
    if @related_fonds.empty?
      redirect_to(projects_url, :notice => 'Scheda aggiornata')
    else
      @related_fonds.each do |rel_fond|
        unpublish_fond(rel_fond.fond_id)
      end
      redirect_to(projects_url, :notice => 'Scheda aggiornata')
    end
  end
# Upgrade 3.0.0 fine

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

