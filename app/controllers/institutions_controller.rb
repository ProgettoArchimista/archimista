class InstitutionsController < ApplicationController
  load_and_authorize_resource

  def index
    terms
# Upgrade 2.0.0 inizio
#    @institutions = Institution.accessible_by(current_ability, :read).paginate :page => params[:page], :order => 'lower(name)'
    @institutions = Institution.accessible_by(current_ability, :read).order('lower(name)').page(params[:page])
# Upgrade 2.0.0 fine
  end

  def list
# Upgrade 2.0.0 inizio
=begin
    @institutions = Institution.accessible_by(current_ability, :read).all(:select => "id, name AS value",
      :conditions => ["LOWER(name) LIKE ?", "%#{params[:term]}%"],
      :order => 'name')
=end
    @institutions = Institution.accessible_by(current_ability, :read).select("id, name AS value").
      where(["LOWER(name) LIKE ?", "%#{params[:term]}%"]).
      order('name')
# Upgrade 2.0.0 fine

    respond_to do |format|
      format.json { render :json => @institutions.map(&:attributes) }
    end
  end

  def show
    terms
    @institution = Institution.find(params[:id])
  end

  def new
    terms
    @institution = Institution.new

  end

  def edit
    terms
    @institution = Institution.find(params[:id])
  end

  def create
    terms
# Upgrade 2.0.0 inizio Strong parameters
#    @institution = Institution.new(params[:institution]).tap do |institution|
    @institution = Institution.new(institution_params).tap do |institution|
# Upgrade 2.0.0 fine
                       institution.created_by = current_user.id
                       institution.updated_by = current_user.id
                       institution.group_id = current_user.group_id
                      end

    if @institution.save
      redirect_to(@institution, :notice => 'Scheda creata')
    else
      render :action => "new"
    end
  end

  def update
    @institution = Institution.find(params[:id])

# Upgrade 2.0.0 inizio Strong parameters
=begin
    if @institution.update_attributes(params[:institution])
      redirect_to(@institution, :notice => 'Scheda aggiornata')
    else
      render :action => "edit"
    end
=end
    if @institution.update_attributes(institution_params)
      redirect_to(@institution, :notice => 'Scheda aggiornata')
    else
      render :action => "edit"
    end
# Upgrade 2.0.0 fine
  end

  def destroy
    @institution = Institution.find(params[:id])
    @institution.destroy

    redirect_to(institutions_url)
  end

# Upgrade 2.0.0 inizio Strong parameters
  private

  def institution_params
    params.require(:institution).permit!
  end
# Upgrade 2.0.0 fine

end

