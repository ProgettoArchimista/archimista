class CreatorsController < ApplicationController
  helper_method :sort_column
  load_and_authorize_resource
# Upgrade 2.2.0 inizio
  skip_load_and_authorize_resource :only => [ :list ]
# Upgrade 2.2.0 fine

# Upgrade 2.2.0 inizio
  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        if (["show","edit","update","destroy"].include?(params[:action]))
          c = Creator.select("group_id").find(params[:id])
          @current_ability ||= Ability.new(current_user, c.group_id)
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
=begin
    @creators = Creator.list.search(params[:q]).accessible_by(current_ability, :read).paginate(:page => params[:page],
      :order => sort_column + ' ' + sort_direction,
      :include => :preferred_event)
=end
# Upgrade 2.2.0 inizio
=begin
    @creators = Creator.list.search(params[:q]).accessible_by(current_ability, :read).
      order(sort_column + ' ' + sort_direction).
      includes(:preferred_event).page(params[:page])
=end
    @creators = Creator.list.search(params[:q]).accessible_by(current_ability, :read).
      order(sort_column + ' ' + sort_direction).
      includes(:preferred_event,:projects).page(params[:page])
# Upgrade 2.2.0 fine
# Upgrade 2.0.0 fine
  end

  def list
    search_param  = [params[:term], params[:q]].find(&:present?)
    @creators = Creator.accessible_by(current_ability, :read).autocomplete_list(search_param)

    ActiveRecord::Base.include_root_in_json = false
    results = @creators.to_json(:methods => [:id, :value], :only => :methods)

    respond_to do |format|
      format.json { render :json => results }
    end
  end

  def show
    @creator = Creator.find(params[:id])
  end

  def new
    terms
    @creator = Creator.new
    params[:type] ||= 'C'
    @events = @creator.events_for_view
    setup_relation_collections
  end

  def edit
    @creator = Creator.find(params[:id])
    terms
    @events = @creator.events_for_view
    setup_relation_collections
  end

  def create
# Upgrade 2.0.0 inizio Strong parameters
#    @creator = Creator.new(params[:creator]).tap do |creator|
    @creator = Creator.new(creator_params).tap do |creator|
# Upgrade 2.0.0 fine
      creator.created_by = current_user.id
      creator.updated_by = current_user.id
# Upgrade 2.2.0 inizio
#      creator.group_id = current_user.group_id
        if current_user.is_multi_group_user?()
          creator.group_id = current_ability.target_group_id
        else
          creator.group_id = current_user.rel_user_groups[0].group_id
        end
# Upgrade 2.2.0 fine
    end
    @events = @creator.events.sort_by(&:order_date)
    @creator.save

    setup_relation_collections  # must be called after validation, otherwise records
    # marked for destruction won't be processed
    if @creator.valid?
      if params[:save_and_continue]
        redirect_to(edit_creator_url(@creator), :notice => 'Scheda creata')
      else
        redirect_to(@creator, :notice => 'Scheda creata')
      end
    else
      terms
      @events = @creator.events_for_view if @events.empty?
      render :action => "new"
    end
  end

  def update
    @creator = Creator.find(params[:id]).tap {|creator| creator.updated_by = current_user.id }
    @events = @creator.events.sort_by(&:order_date)
# Upgrade 2.0.0 inizio Strong parameters
#    @creator.update_attributes(params[:creator])
    @creator.update_attributes(creator_params)
# Upgrade 2.0.0 fine
    setup_relation_collections  # must be called after validation, otherwise records
    # marked for destruction won't be processed

    if @creator.valid?
      if params[:save_and_continue]
        redirect_to(edit_creator_url(@creator), :notice => 'Scheda aggiornata')
      else
        redirect_to(@creator)
      end
    else
      terms
      @events = @creator.events_for_view if @events.empty?
      render :action => "edit"
    end
  end

  def destroy
    @creator = Creator.find(params[:id])
    @creator.destroy

    redirect_to(creators_url, :notice => "Scheda eliminata")
  end

  private

  def setup_relation_collections
    return unless @creator

# Upgrade 2.0.0 inizio
=begin
    relation_collections  :related => "fonds", :through => "rel_creator_fonds",
      :available => Fond.accessible_by(current_ability, :read).roots.active.count('id'),
      :suggested => Proc.new{ Fond.roots.active.all( :select => 'id, name', :order => "name" ) }
=end
    relation_collections  :related => "fonds", :through => "rel_creator_fonds",
      :available => Fond.accessible_by(current_ability, :read).roots.active.count('id'),
      :suggested => Proc.new{ Fond.roots.active.select('id, name').order("name" ) }
# Upgrade 2.0.0 fine

# Upgrade 2.0.0 inizio
=begin
    relation_collections  :related => "institutions", :through => "rel_creator_institutions",
      :available => Institution.accessible_by(current_ability, :read).count('id'),
      :suggested => Proc.new{ Institution.accessible_by(current_ability, :read).all(:select => 'id, name', :order => 'name') }
=end
    relation_collections  :related => "institutions", :through => "rel_creator_institutions",
      :available => Institution.accessible_by(current_ability, :read).count('id'),
      :suggested => Proc.new{ Institution.accessible_by(current_ability, :read).select('id, name').order('name') }
# Upgrade 2.0.0 fine

    relation_collections  :related => "related_creators", :through => "rel_creator_creators",
      :available => Creator.accessible_by(current_ability, :read).count('id'),
      :suggested => Proc.new{ Creator.accessible_by(current_ability, :read).sorted_suggested }

    relation_collections  :related => "sources", :through => "rel_creator_sources"

# Upgrade 2.0.0 inizio
#    @association_types = CreatorAssociationType.all(:select => 'id, association_type', :order => 'id')
    @association_types = CreatorAssociationType.select('id, association_type').order('id')
# Upgrade 2.0.0 fine
  end

  def sort_column
# Upgrade 2.2.0 inizio
#    params[:sort] || "name"
    params[:sort] || "creator_names.name"
# Upgrade 2.2.0 fine
  end

# Upgrade 2.0.0 inizio Strong parameters
  private
    def creator_params
      params.require(:creator).permit!
    end
# Upgrade 2.0.0 fine

end

