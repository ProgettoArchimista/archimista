class CustodiansController < ApplicationController
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
          c = Custodian.select("group_id").find(params[:id])
          @current_ability ||= Ability.new(current_user, c.group_id)
        elsif (["list"].include?(params[:action]))
          group_id = str2int(params[:group_id])
          @current_ability ||= Ability.new(current_user, group_id)
        elsif (["index"].include?(params[:action]))
          @current_ability ||= Ability.new(current_user, -1)
        elsif (["new", "create"].include?(params[:action]))
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
#    @custodians = Custodian.list.search(params[:q]).accessible_by(current_ability, :read).paginate(:page => params[:page], :order => sort_column + ' ' + sort_direction)
    @custodians = Custodian.list.search(params[:q]).accessible_by(current_ability, :read).order(sort_column + ' ' + sort_direction).page(params[:page])
# Upgrade 2.0.0 fine
    terms
  end

  def list
    search_param  = [params[:term], params[:q]].find(&:present?)
    custodians    = Custodian.accessible_by(current_ability, :read).autocomplete_list(search_param)

    respond_to do |format|
      format.json { render :json => custodians.map(&:attributes) }
    end
  end

  def show
    @custodian = Custodian.find(params[:id])
  end

  def new
    @custodian = Custodian.new

    terms
    setup_relation_collections
  end

  def edit
    @custodian = Custodian.find(params[:id])
    terms
    setup_relation_collections
  end

  def create
# Upgrade 2.0.0 inizio Strong parameters
#    @custodian = Custodian.new(params[:custodian]).tap do|custodian|
    @custodian = Custodian.new(custodian_params).tap do|custodian|
# Upgrade 2.0.0 fine
      custodian.created_by = current_user.id
      custodian.updated_by = current_user.id
# Upgrade 2.2.0 inizio
#      custodian.group_id = current_user.group_id
        if current_user.is_multi_group_user?()
          custodian.group_id = current_ability.target_group_id
        else
          custodian.group_id = current_user.rel_user_groups[0].group_id
        end
# Upgrade 2.2.0 fine
    end

    @custodian.save
    setup_relation_collections

    if @custodian.valid?
      if params[:save_and_continue]
        redirect_to(edit_custodian_url(@custodian), :notice => 'Scheda creata')
      else
        redirect_to(@custodian, :notice => 'Scheda creata')
      end
    else
      terms
      render :action => "new"
    end
  end

  def update
    @custodian = Custodian.find(params[:id]).tap {|custodian| custodian.updated_by = current_user.id}
# Upgrade 2.0.0 inizio Strong parameters
#    @custodian.update_attributes(params[:custodian])
    @custodian.update_attributes(custodian_params)
# Upgrade 2.0.0 fine
    setup_relation_collections

    if @custodian.valid?
      if params[:save_and_continue]
        redirect_to(edit_custodian_url(@custodian), :notice => 'Scheda aggiornata')
      else
        redirect_to(@custodian)
      end
    else
      terms
      render :action => "edit"
    end
  end

  def destroy
    @custodian = Custodian.find(params[:id])
    @custodian.destroy

    redirect_to(custodians_url)
  end

  private

  def setup_relation_collections
    return unless @custodian

    relation_collections  :related => "fonds", :through => "rel_custodian_fonds",
      :available => Fond.accessible_by(current_ability, :read).roots.unassigned_to_custodian(:unless => @custodian).active.count('id'),
      :suggested => Proc.new{
# Upgrade 2.2.0 inizio
#                      Fond.roots.active.
                      Fond.accessible_by(current_ability, :read).roots.active.
# Upgrade 2.2.0 fine
                           unassigned_to_custodian(:unless => @custodian).
# Upgrade 2.0.0 inizio
#                           scoped( :select => 'fonds.id, fonds.name', :order => "name" )
                            select('fonds.id, fonds.name').order("name")
# Upgrade 2.0.0 fine
                    }

    relation_collections  :related => "sources", :through => "rel_custodian_sources"
  end

  def sort_column
# Upgrade 2.2.0 inizio
#    params[:sort] || "name"
    params[:sort] || "custodian_names.name"
# Upgrade 2.2.0 fine
  end

# Upgrade 2.0.0 inizio Strong parameters
    def custodian_params
      params.require(:custodian).permit!
    end
# Upgrade 2.0.0 fine

end

