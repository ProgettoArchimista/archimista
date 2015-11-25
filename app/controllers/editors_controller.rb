class EditorsController < ApplicationController
  load_and_authorize_resource

  def index
# Upgrade 2.0.0 inizio
=begin
    @editors = Editor.accessible_by(current_ability, :read).paginate :page => params[:page], :order => 'last_name, first_name'
=end
    @editors = Editor.accessible_by(current_ability, :read).order('last_name, first_name').page(params[:page])
# Upgrade 2.0.0 fine
  end

  def show
    @editor = Editor.find(params[:id])
  end

  def new
    @editor = Editor.new
  end

  def edit
    @editor = Editor.find(params[:id])
  end

  def create
# Upgrade 2.0.0 inizio Strong parameters
#    @editor = Editor.new(params[:editor]).tap do |editor|
    @editor = Editor.new(editor_params).tap do |editor|
# Upgrade 2.0.0 fine
      editor.created_by = current_user.id
      editor.updated_by = current_user.id
      editor.group_id = current_user.group_id
    end

    if @editor.save
      redirect_to(editors_url, :notice => 'Scheda creata')
    else
      render :action => "new"
    end
  end

  def update
    @editor = Editor.find(params[:id])
# Upgrade 2.0.0 inizio Strong parameters
=begin
    if @editor.update_attributes(params[:editor])
      redirect_to(editors_url, :notice => 'Scheda aggiornata')
    else
      render :action => "edit"
    end
=end
    if @editor.update_attributes(editor_params)
      redirect_to(editors_url, :notice => 'Scheda aggiornata')
    else
      render :action => "edit"
    end
# Upgrade 2.0.0 fine
  end

  def destroy
    @editor = Editor.find(params[:id])
    @editor.destroy

    redirect_to(editors_url)
  end

  def modal_new
    render :partial => 'editors/new_editor', :layout => false
  end

  def modal_create
# Upgrade 2.0.0 inizio Strong parameters
#    @editor = Editor.new(params[:editor]).tap do |editor|
    @editor = Editor.new(editor_params).tap do |editor|
# Upgrade 2.0.0 fine
      editor.created_by = current_user.id
      editor.updated_by = current_user.id
      editor.group_id = current_user.group_id
    end
    respond_to do |format|
      if @editor.save
        format.json { render :json => {:status => "success", :msg => "Scheda creata"} }
      else
        format.json { render :json => {:status => "failure", :msg => "Scheda non valida oppure già presente"} }
      end
    end
  end

  def list
    term = params[:term] || ""
    term = term.downcase

# Upgrade 2.0.0 inizio
=begin
    @fonds = Editor.accessible_by(current_ability, :read).
      find(:all, :select => "id, first_name, last_name",
      :conditions => "LOWER(first_name) LIKE '%#{term}%' OR LOWER(last_name) LIKE '%#{term}%'",
      :order => "first_name, last_name", :limit => 10)
=end
    @fonds = Editor.accessible_by(current_ability, :read).
      select("id, first_name, last_name").
      where("LOWER(first_name) LIKE '%#{term}%' OR LOWER(last_name) LIKE '%#{term}%'").
      order("first_name, last_name").limit(10)
# Upgrade 2.0.0 fine

    ActiveRecord::Base.include_root_in_json = false
    response = @fonds.to_json(:methods => [:id, :value], :only => :methods)

    respond_to do |format|
      format.json { render :json => response }
    end
  end

# Upgrade 2.0.0 inizio Strong parameters
  def editor_params
    params.require(:editor).permit!
  end
# Upgrade 2.0.0 fine

end
