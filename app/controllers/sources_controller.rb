class SourcesController < ApplicationController
  load_and_authorize_resource

# Upgrade 2.2.0 inizio
  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        if (["show","edit","update","destroy"].include?(params[:action]))
          s = Source.find(params[:id])
          @current_ability ||= Ability.new(current_user, s.group_id)
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
    @sources = Source.accessible_by(current_ability, :read).search(params[:q]).
      paginate(:page => params[:page], :order => "short_title", :include => :source_type)
=end
    @sources = Source.accessible_by(current_ability, :read).search(params[:q]).
      includes(:source_type).order("short_title").page(params[:page])
# Upgrade 2.0.0 fine
  end

  def list
    sources = Source.accessible_by(current_ability, :read).autocomplete_list(params[:term])
    @export_sources = Source.accessible_by(current_ability, :read).autocomplete_export_list(params[:term])
    results = @export_sources.to_json(:methods => [:id, :value], :only => :methods)

    respond_to do |format|
      format.html do
        render  :partial => "shared/relations/livesearch/results",
                :locals => {:sources => sources,
                            :excluded_ids => [],
                            :selected_label_short => lambda{|source| h(source.short_title)},
                            :selected_label_full  => lambda{|source, builder| builder.formatted_source(source)} }
      end
      format.json { render :json => results }
    end
  end

  def show
    @source = Source.find(params[:id])
  end

  def new
    params[:type] = 1 unless params[:type].present?
    @source = Source.new(:source_type_code => params[:type])

# TAI fonti
    setup_relation_collections

    terms
  end

  def edit
    @source = Source.find(params[:id])
    @source.source_type_code = params[:type] if params[:type].present?

# TAI fonti
    setup_relation_collections

    terms
  end

  def create
# Upgrade 2.0.0 inizio Strong parameters
=begin
    @source = Source.new(params[:source]).tap do |source|
      source.created_by = current_user.id
      source.updated_by = current_user.id
      source.group_id = current_user.group_id
    end
=end
    @source = Source.new(source_params).tap do |source|
      source.created_by = current_user.id
      source.updated_by = current_user.id
# Upgrade 2.2.0 inizio
#      source.group_id = current_user.group_id
        if current_user.is_multi_group_user?()
          source.group_id = current_ability.target_group_id
        else
          source.group_id = current_user.rel_user_groups[0].group_id
        end
# Upgrade 2.2.0 fine
    end
# Upgrade 2.0.0 fine

# Upgrade 2.0.0 inizio
=begin
    if @source.save
      redirect_to(edit_source_url(@source), :notice => 'Scheda creata')
    else
      terms
      render :action => "new"
    end
=end
    @source.save
# TAI fonti
    setup_relation_collections
    if @source.valid?
      redirect_to(edit_source_url(@source), :notice => 'Scheda creata')
    else
      terms
      render :action => "new"
    end
# Upgrade 2.0.0 fine
  end

  def update
    @source = Source.find(params[:id]).tap do |source|
      source.updated_by = current_user.id
    end

# Upgrade 2.0.0 inizio Strong parameters
=begin
    if @source.update_attributes(params[:source])
      redirect_to(edit_source_url(@source), :notice => 'Scheda aggiornata')
    else
      terms
      render :action => "edit"
    end
=end

=begin
    if @source.update_attributes(source_params)
      redirect_to(edit_source_url(@source), :notice => 'Scheda aggiornata')
    else
      terms
      render :action => "edit"
    end
=end
    @source.update_attributes(source_params)
# TAI fonti
    setup_relation_collections
    if @source.valid?
      redirect_to(edit_source_url(@source), :notice => 'Scheda aggiornata')
    else
      terms
      render :action => "edit"
    end

# Upgrade 2.0.0 fine
  end

  def destroy
    @source = Source.find(params[:id])
    @source.destroy

    redirect_to(sources_url, :notice => 'Scheda eliminata')
  end

# Upgrade 2.0.0 inizio Strong parameters
private
    def source_params
      params.require(:source).permit!
    end
# Upgrade 2.0.0 fine


# TAI fonti
  def setup_relation_collections
    return unless @source

    relation_collections  :related => "creators", :through => "rel_creator_sources",
      :suggested => Proc.new{ Creator.accessible_by(current_ability, :read).sorted_suggested }

    relation_collections  :related => "custodians", :through => "rel_custodian_sources",
      :suggested => Proc.new{ Custodian.accessible_by(current_ability, :read).sorted_suggested }

    relation_collections  :related => "fonds", :through => "rel_fond_sources",
      :available => Fond.accessible_by(current_ability, :read).roots.active.count('id'),
      :suggested => Proc.new{ Fond.roots.active.select('id, name').order("name" ) }
  end

end

