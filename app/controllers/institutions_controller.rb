class InstitutionsController < ApplicationController
  load_and_authorize_resource

# Upgrade 2.2.0 inizio
  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        if (["show","edit","update","destroy"].include?(params[:action]))
          i = Institution.find(params[:id])
          @current_ability ||= Ability.new(current_user, i.group_id)
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
# Upgrade 2.2.0 inizio
#     institution.group_id = current_user.group_id
        if current_user.is_multi_group_user?()
          institution.group_id = current_ability.target_group_id
        else
          institution.group_id = current_user.rel_user_groups[0].group_id
        end
# Upgrade 2.2.0 fine
    end

    if @institution.save
# Upgrade 2.2.0 inizio
#      redirect_to(@institution, :notice => 'Scheda creata')
      if params[:save_and_continue]
        redirect_to(edit_institution_url(@institution), :notice => 'Scheda creata')
      else
        redirect_to(@institution, :notice => 'Scheda creata')
      end
# Upgrade 2.2.0 fine
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
# Upgrade 2.2.0 inizio
#      redirect_to(@institution, :notice => 'Scheda aggiornata')
      if params[:save_and_continue]
        redirect_to(edit_institution_url(@institution), :notice => 'Scheda aggiornata')
      else
        redirect_to(@institution, :notice => 'Scheda aggiornata')
      end
# Upgrade 2.2.0 fine
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

