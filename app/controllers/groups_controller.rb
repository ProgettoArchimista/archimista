class GroupsController < ApplicationController
  helper_method :sort_column

  load_and_authorize_resource

  def index
# Upgrade 2.0.0 inizio
#    @groups = Group.accessible_by(current_ability, :manage).all(:order => lower_sort_column + ' ' + sort_direction)
#    @assets = DigitalObject.sum(:asset_file_size, :group => "group_id")

    @groups = Group.accessible_by(current_ability, :manage).order(lower_sort_column + ' ' + sort_direction)
    @assets = DigitalObject.group("group_id").sum(:asset_file_size)
# Upgrade 2.0.0 fine
  end

  def show
    @group = Group.find(params[:id])
  end

  def new
    @group = Group.new
  end

  def create
# Upgrade 2.0.0 inizio Strong parameters
#    @group = Group.new(params[:group])
    @group = Group.new(group_params)
# Upgrade 2.0.0 fine

    if @group.save
      redirect_to(groups_url, :notice => "Creato il gruppo: #{@group.name}")
    else
      render :action => "new"
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])

# Upgrade 2.0.0 inizio Strong parameters
=begin
    if @group.update_attributes(params[:group])
      redirect_to(groups_url, :notice => "Gruppo aggiornato.")
    else
      render :action => "edit"
    end
=end
    if @group.update_attributes(group_params)
      redirect_to(groups_url, :notice => "Gruppo aggiornato.")
    else
      render :action => "edit"
    end
# Upgrade 2.0.0 fine
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    redirect_to(groups_url, :notice => "Eliminato il gruppo: #{@group.name}")
  end

  private

  def sort_column
    params[:sort] || "created_at"
  end

# Upgrade 2.0.0 inizio Strong parameters
  def group_params
    params.require(:group).permit!
  end
# Upgrade 2.0.0 fine

end
