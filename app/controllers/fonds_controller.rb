class FondsController < ApplicationController
  include FondsHelper
  helper_method :sort_column

  load_and_authorize_resource
# Upgrade 2.2.0 inizio
#  skip_load_resource :only => [ :save_a_tree, :saving_the_tree ]
  skip_load_and_authorize_resource :only => [ :save_a_tree, :list ]
  skip_load_resource :only => [ :saving_the_tree ]
# Upgrade 2.2.0 fine

# Upgrade 2.2.0 inizio
  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        if (["treeview","tree","trash","move_to_trash","trashed_subtree","restore_subtree","show","edit","ajax_update","merge_with","merge","update","rename","move","destroy","destroy_subtree"].include?(params[:action]))
          f = Fond.select("group_id").find(params[:id])
          @current_ability ||= Ability.new(current_user, f.group_id)
        elsif (["index"].include?(params[:action]))
          @current_ability ||= Ability.new(current_user, -1)
        elsif (["ajax_create"].include?(params[:action]))     
          group_id = str2int(params[:fond][:group_id])
          @current_ability ||= Ability.new(current_user, group_id)
        elsif (["saving_the_tree"].include?(params[:action]))     #save_a_tree non richiede una gestione ad hoc di ability
          if params[:tree][:group_id].present?
            group_id = str2int(params[:tree][:group_id])
            @current_ability ||= Ability.new(current_user, group_id)
          end
        elsif (["list"].include?(params[:action]))
          group_id = str2int(params[:group_id])
          @current_ability ||= Ability.new(current_user, group_id)
        elsif (["create"].include?(params[:action]))
          fp = fond_params
          if request.xhr? && fp[:parent_id].present?
            group_id = Fond.find(fp[:parent_id]).group_id
            @current_ability ||= Ability.new(current_user, group_id)
          else
            #
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

  # Alberi

  def treeview
# Upgrade 2.0.0 inizio
#    @fond = Fond.find(params[:id], :select => "id, name, ancestry")
    @fond = Fond.select("id, name, ancestry").find(params[:id])
# Upgrade 2.0.0 fine
    @root_fond = @fond.is_root? ? @fond : @fond.root
    @trash = @root_fond.descendants.trashed.exists?
  end

  def tree
    @fond = Fond.find(params[:id])
    @root_fond = @fond.is_root? ? @fond : @fond.root

    @nodes = @root_fond.fast_active_subtree_to_jstree_hash

    respond_to do |format|
      format.json { render :json => @nodes }
    end
  end

  def save_a_tree
    @fond_types = Term.fond_types
    set_template_paths
  end

# Upgrade 2.2.0 inizio
=begin
  def saving_the_tree
    @fond_types = Term.fond_types
    set_template_paths
		
    if params[:tree_template].present?
      @root = Fond.save_a_tree_with_sequence(params[:tree_template], :created_by => current_user.id, :updated_by => current_user.id, :group_id => current_user.group_id)
      if @root && @root.valid?
        flash[:notice] = "Struttura importata."
        redirect_to treeview_fond_url(@root)
      else
        flash.now[:alert] = "Struttura non valida. Controlla i livelli e le tipologie indicate."
        render :action => "save_a_tree"
      end
    else
      render :action => "save_a_tree"
    end
  end
=end
  def saving_the_tree
    @fond_types = Term.fond_types
    set_template_paths

    if params[:tree][:group_id].present?
			group_id = str2int(params[:tree][:group_id])
		else
			group_id = -1
		end
    if group_id != -1
      if params[:tree_template].present?
        @root = Fond.save_a_tree_with_sequence(params[:tree_template], :created_by => current_user.id, :updated_by => current_user.id, :group_id => group_id)
        if @root && @root.valid?
          flash[:notice] = "Struttura importata."
          redirect_to treeview_fond_url(@root)
        else
          flash.now[:alert] = "Struttura non valida. Controlla i livelli e le tipologie indicate."
          render :action => "save_a_tree"
        end
      else
        render :action => "save_a_tree"
      end
    else
      render :action => "save_a_tree"
    end
  end
# Upgrade 2.2.0 fine

  def trash
    @fond = Fond.find(params[:id])
    if @fond.is_root?
# Upgrade 2.0.0 inizio
#      @trashed_roots = @fond.descendants.trashed_roots.all(:select => "id, name, updated_at", :order => "updated_at DESC")
      @trashed_roots = @fond.descendants.trashed_roots.select("id, name, updated_at").order("updated_at DESC")
# Upgrade 2.0.0 fine
    else
      redirect_to trash_fond_url(@fond.root.id)
    end
  end

  def move_to_trash
    @fond = Fond.find(params[:id])

    respond_to do |format|
      format.json do
        render :json => {:status => (@fond.trash_subtree_with_external_sequence ? "success" : nil)}
      end
    end
  end

  def trashed_subtree
    @fond = Fond.find(params[:id])
    @nodes = @fond.fast_trashed_subtree_to_jstree_hash

    respond_to do |format|
      format.json { render :json => @nodes }
    end
  end

  def restore_subtree
    @fond = Fond.find(params[:id])

    if @fond.restore_subtree_with_external_sequence
      flash[:notice] = "Complesso ripristinato"
      redirect_to treeview_fond_url(@fond.root)
    else
      flash[:notice] = "Errori nel ripristino del complesso"
      redirect_to trash_fond_url(@fond.root)
    end
  end

  def list
    term = params[:term] || ""
    # results = Fond.autocomplete_search(term)

    unless params[:exclude].blank?
      exclude_condition = " AND id NOT IN (#{params[:exclude].join(',')})"
    end

# Upgrade 2.0.0 inizio
=begin
    @fonds = Fond.accessible_by(current_ability, :read).roots.
      find(:all, :select => "id, name", :include => :preferred_event,
      :conditions => "name LIKE '%#{term}%' #{exclude_condition}", :order => "name", :limit => 10)
=end
    @fonds = Fond.accessible_by(current_ability, :read).roots.
      select("id, name").includes(:preferred_event).
      where("name LIKE '%#{term}%' #{exclude_condition}").order("name").limit(10)
# Upgrade 2.0.0 fine

    ActiveRecord::Base.include_root_in_json = false
    response = @fonds.to_json(:methods => [:id, :value], :only => :methods)

    respond_to do |format|
      format.json { render :json => response }
    end
  end

  # CRUD

  def index
# Upgrade 2.0.0 inizio
=begin
    @fonds = Fond.list.
      roots.
      active.
      search(params[:q]).
      accessible_by(current_ability, :read).
      paginate(:page => params[:page], :order => sort_column + ' ' + sort_direction, :include => :preferred_event)
    if @fonds.size > 0
      @units_counts = Unit.count("id", :joins => :fond,
        :conditions => {:root_fond_id => @fonds.map(&:id), :fonds => {:trashed => false}},
        :group => :root_fond_id)
    end
=end
# Upgrade 2.2.0 inizio
=begin
    @fonds = Fond.list.
      roots.
      active.
      search(params[:q]).
      accessible_by(current_ability, :read).
      order(sort_column + ' ' + sort_direction).includes(:preferred_event).page(params[:page])
=end
    @fonds = Fond.list.
      roots.
      active.
      search(params[:q]).
      accessible_by(current_ability, :read).
      order(sort_column + ' ' + sort_direction).includes(:preferred_event, :projects).page(params[:page])
# Upgrade 2.2.0 fine
    if @fonds.size > 0
      @units_counts = Unit.joins(:fond).
        where({:root_fond_id => @fonds.map(&:id), :fonds => {:trashed => false}}).
        group(:root_fond_id).count("id")
    end
# Upgrade 2.0.0 fine
  end

  def show
    langs
    @fond = Fond.find(params[:id])
    # FIXME: bisognerebbe testare se il fond ha una qualsiasi unità discendente, anche trashed
# Upgrade 2.0.0 inizio
#    @descendant_units_count = Unit.count("id", :joins => :fond, :conditions => {:fond_id => @fond.subtree_ids, :fonds => {:trashed => false}})
    @descendant_units_count = Unit.joins(:fond).where({:fond_id => @fond.subtree_ids, :fonds => {:trashed => false}}).count("id")
# Upgrade 2.0.0 fine

    respond_to do |format|
      format.html
      format.xml do
        stream = render_to_string(:template => "fonds/show.xml.builder")
        send_data(stream, :type => "text/xml", :filename => "#{@fond.name.parameterize.underscore}.xml")
      end
    end
  end

  def edit
    terms
    langs
    @fond = Fond.find(params[:id])
    @events = @fond.events_for_view
    setup_relation_collections
    @sources = @fond.sources.autocomplete_list

    render :partial => 'fonds/form', :layout => false
  end

  def create
    terms
    langs
# Upgrade 2.0.0 inizio Strong parameters
=begin
    @fond = if request.xhr? && params[:fond][:parent_id].present?
      Fond.find(params[:fond][:parent_id]).
        children.
        build(params[:fond].reject{|k,v| [:parent_id, 'parent_id'].include?(k)}).
        tap do |fond|
          fond.created_by = current_user.id
          fond.updated_by = current_user.id
          fond.group_id = current_user.group_id
        end
    else
      Fond.new(params[:fond]).tap do |fond|
        fond.created_by = current_user.id
        fond.updated_by = current_user.id
        fond.group_id = current_user.group_id
      end
    end
=end
    fp = fond_params
    @fond = if request.xhr? && fp[:parent_id].present?
# Upgrade 2.2.0 inizio
=begin
      Fond.find(fp[:parent_id]).
      children.
        build(fp.reject{|k,v| [:parent_id, 'parent_id'].include?(k)}).
        tap do |fond|
          fond.created_by = current_user.id
          fond.updated_by = current_user.id
          fond.group_id = current_user.group_id
        end
=end
      parent = Fond.find(fp[:parent_id])
      parent.children.
        build(fp.reject{|k,v| [:parent_id, 'parent_id'].include?(k)}).
        tap do |fond|
          fond.created_by = current_user.id
          fond.updated_by = current_user.id
          fond.group_id = parent.group_id
# Upgrade 2.2.0 fine
        end
    else
      Fond.new(fp).tap do |fond|
        fond.created_by = current_user.id
        fond.updated_by = current_user.id
# Upgrade 2.2.0 inizio
#        fond.group_id = current_user.group_id
        if current_user.is_multi_group_user?()
          fond.group_id = current_ability.target_group_id
        else
          fond.group_id = current_user.rel_user_groups[0].group_id
        end
# Upgrade 2.2.0 fine
      end
    end
# Upgrade 2.0.0 fine

    @events = @fond.events.sort_by(&:order_date)
    @fond.save_new_in_sequence
    setup_relation_collections
    @sources = @fond.sources.autocomplete_list

    respond_to do |format|
      if @fond.valid?
        @hash_for_json_response = {
          :status => "success",
          :node => @fond.attributes.delete_if{|k,v| ['position',:position].include?(k)}
        }
        if request.xhr?
          format.json { render :json => @hash_for_json_response }
        else
          format.html { redirect_to(@fond, :notice => 'Complesso creato') }
        end
      else
        @events = @fond.events_for_view if @events.empty?
        format.html { render :action => "new" }
      end
    end
  end

  def ajax_create
# Upgrade 2.0.0 inizio Strong parameters
#    @fond = Fond.new(params[:fond])
    @fond = Fond.new(fond_params)
# Upgrade 2.0.0 fine

    respond_to do |format|
      if @fond.save
        format.html { redirect_to(treeview_fond_url(@fond)) }
        format.json { render :json => {:status => "success", :id => "#{@fond.id}", :value => "#{@fond.name}"} }
      else
        format.html { redirect_to(fonds_url) }
        format.json { render :json => {:status => "failure", :msg => "Complesso già presente"} }
      end
    end
  end

  def ajax_update
    terms
    langs
    @fond = Fond.find(params[:id]).tap {|fond| fond.updated_by = current_user.id }
    @events = @fond.events.sort_by(&:order_date)
# Upgrade 2.0.0 inizio Strong parameters
#    @fond.update_attributes(params[:fond])
    @fond.update_attributes(fond_params)
# Upgrade 2.0.0 fine

    if @fond.valid?
      flash.now[:notice] = 'Scheda aggiornata'
      @fond.reload
    end

    @events = @fond.events_for_view.sort_by(&:order_date) if @events.empty?
    setup_relation_collections
    @sources = @fond.sources.autocomplete_list

    render :partial => 'fonds/form', :layout => false
  end

# Upgrade 3.0.0 inizio
  def split_fond
    @fond = Fond.find(params[:id])
    render :partial => 'fonds/fond_split', :object => @fond, :layout => false, :as => "object"
  end

  def split
    if params[:new_root_id].present?
      if params[:id] == params[:new_root_id]
        flash[:alert] =  'Impossibile dividere un complesso archivistico da se stesso.'
        redirect_to fonds_url
        return
      end

      @new_root = Fond.find(params[:new_root_id])

      if @new_root.move_with_external_sequence( :new_parent_id => params[:new_root_id], :new_position => 1, :jstree => true )
        if @new_root.move_with_external_sequence( :new_parent_id => nil, :new_position => 1, :jstree => true )
          new_tree_ids = Fond.find(@new_root.id).subtree_ids
          Unit.where({:fond_id => new_tree_ids}).update_all("root_fond_id = #{@new_root.id}")
          @new_root.update_deletable_status
          @new_root.update_deletable_status
          flash[:notice] = 'Complessi archivistici divisi'
          redirect_to fonds_url
        else
          flash[:alert] = 'Divisione complessi archivistici fallita'
          redirect_to fonds_url
        end
      else
        flash[:alert] = 'Divisione complessi archivistici fallita'
        redirect_to fonds_url
      end
    else
      redirect_to fonds_url
    end
  end
# Upgrade 3.0.0 fine

  def merge_with
    
    @fond = Fond.find(params[:id])
# Upgrade 2.0.0 inizio
=begin
    @available_fonds = Fond.accessible_by(current_ability, :read).roots.
      find(:all, :select => "id, name", :conditions => "id != #{@fond.id}", :include => :preferred_event,
      :order => "name")
    render :partial => 'fonds/merge_with', :locals => {:fonds => @available_fonds}, :object => @fond, :layout => false
=end
    @available_fonds = Fond.accessible_by(current_ability, :read).roots.
      select("id, name").where("id != #{@fond.id}").includes(:preferred_event).
      order("name")
    render :partial => 'fonds/merge_with', :locals => {:fonds => @available_fonds}, :object => @fond, :layout => false, :as => "object"
# Upgrade 2.0.0 fine
  end

  def merge
    @fond = Fond.find(params[:id])

    if params[:new_root_id].present?
      if params[:id] == params[:new_root_id]
        flash[:alert] =  'Impossibile unire un complesso archivistico con se stesso.'
        redirect_to fonds_url
        return
      end

      @choosen_root = Fond.find(params[:choosen_root_id])
      new_root_id = params[:new_root_id].to_i
      if @fond.move_with_external_sequence(:new_parent_id => @choosen_root.id, :new_position => 1)
# Upgrade 3.0.0 inizio
#        Unit.update_all("root_fond_id = #{@new_root.id}", ["root_fond_id = ?", @fond.id])
#        Unit.where(["root_fond_id = ?", @fond.id]).update_all("root_fond_id = #{@new_root.id}")
        real_root_id = Fond.find(new_root_id).root_id
        Unit.where(["root_fond_id = ?", @fond.id]).update_all("root_fond_id = #{new_root_id}")
# Upgrade 3.0.0 fine
        @choosen_root.update_deletable_status
        @fond.update_deletable_status

        # The merged fond is not a root anymore, so clear the relations specific to root fonds.
        @fond.rel_custodian_fonds.clear
        @fond.rel_project_fonds.clear

        flash[:notice] = 'Complessi archivistici uniti'
        #redirect_to treeview_fond_url(@new_root.id)
        redirect_to fonds_url
      else
        flash[:alert] = 'Unione complessi archivistici fallita'
        redirect_to fonds_url
      end
    else
      redirect_to fonds_url
    end
  end

  def update
    terms
    langs
    @fond = Fond.find(params[:id]).tap {|fond| fond.updated_by = current_user.id }
# Upgrade 2.0.0 inizio Strong parameters
#    @fond.update_attributes(params[:fond])
    @fond.update_attributes(fond_params)
# Upgrade 2.0.0 fine
    @events = @fond.events.sort_by(&:order_date)
    setup_relation_collections
    @sources = @fond.sources.autocomplete_list

    if @fond.valid?
      redirect_to(@fond, :notice => 'Scheda aggiornata')
    else
      @events = @fond.events_for_view if @events.blank?
      render :action => "edit"
    end
  end

  def rename
    @fond = Fond.find(params[:id])
# Upgrade 2.0.0 inizio Strong parameters
#    @fond.attributes = params[:fond]
    @fond.attributes = fond_params
# Upgrade 2.0.0 fine

    respond_to do |format|
      @hash_for_json_response = if @fond.save
        { :status => "success",
          :node => @fond.attributes.delete_if{|k,v| ['position',:position].include?(k)} }
      else
        { :status => "success"}
      end
      format.json { render :json => @hash_for_json_response }
    end
  end

  def move
    @fond = Fond.find(params[:id])

# Upgrade 2.0.0 inizio Strong parameters
=begin
    respond_to do |format|
      if @fond.move_with_external_sequence( :new_parent_id => params[:fond][:new_parent_id],
          :new_position => params[:fond][:new_position],
          :jstree => true )
        @hash_for_json_response = {
          :status => "success",
          :node => @fond.attributes.delete_if{|k,v| ['position', :position].include?(k)}
        }
        format.json { render :json => @hash_for_json_response }
      else
        @hash_for_json_response = {:status => nil}
        format.json { render :json => @hash_for_json_response }
      end
    end
=end
    respond_to do |format|
      fp = fond_params
      if @fond.move_with_external_sequence( :new_parent_id => fp[:new_parent_id],
          :new_position => fp[:new_position],
          :jstree => true )
        @hash_for_json_response = {
          :status => "success",
          :node => @fond.attributes.delete_if{|k,v| ['position', :position].include?(k)}
        }
        format.json { render :json => @hash_for_json_response }
      else
        @hash_for_json_response = {:status => nil}
        format.json { render :json => @hash_for_json_response }
      end
    end
# Upgrade 2.0.0 fine
  end

  def destroy
    @fond = Fond.find(params[:id])
    @fond.destroy

    redirect_to fonds_url, :notice => "Complesso <strong>#{h @fond.name}</strong> eliminato"
  end

  # TODO: evitare ricalcolo di sequence_number su units in cancellazione
  def destroy_subtree
    @fond = Fond.find(params[:id])

    if @fond.is_root? # Empty trash
# Upgrade 2.0.0 inizio
#      trashed_roots = @fond.descendants.trashed_roots.all(:select => :id)
      trashed_roots = @fond.descendants.trashed_roots.select(:id)
# Upgrade 2.0.0 fine
      ids = trashed_roots.map(&:id).join(',')
      Fond.destroy_all("id IN (#{ids})")
    else # Destroy single subtree
      @fond.destroy
    end

    redirect_to(trash_fond_url(@fond.root.id))
  end

  # Upgrade 3.0.0 inizio
  # Aggiunte azioni di pubblicazione e rimozione pubblicazione a cascata fondi/unità/oggetti
  def publish
    publish_fond(params[:id])
    redirect_to(fonds_url, :notice => 'Scheda aggiornata')
  end

  def unpublish
    unpublish_fond(params[:id])
    redirect_to(fonds_url, :notice => 'Scheda aggiornata')
  end
# Upgrade 3.0.0 fine

  private

  def setup_relation_collections
    return unless @fond

    relation_collections  :related => "creators", :through => "rel_creator_fonds",
      :suggested => Proc.new{ Creator.accessible_by(current_ability, :read).sorted_suggested }

    relation_collections  :related => "custodians", :through => "rel_custodian_fonds",
      :suggested => Proc.new{ Custodian.accessible_by(current_ability, :read).sorted_suggested },
      :if => @fond.is_root?

# Upgrade 2.0.0 inizio
=begin
    relation_collections  :related => "projects", :through => "rel_project_fonds",
      :suggested => Proc.new{ Project.accessible_by(current_ability, :read).all(:select => 'id, name', :order => 'name') },
      :if => @fond.is_root?
=end
    relation_collections  :related => "projects", :through => "rel_project_fonds",
      :suggested => Proc.new{ Project.accessible_by(current_ability, :read).select('id, name').order('name') },
      :if => @fond.is_root?
# Upgrade 2.0.0 fine

# Upgrade 2.0.0 inizio
=begin
    relation_collections  :related => "document_forms", :through => "rel_fond_document_forms",
      :suggested => Proc.new{ DocumentForm.accessible_by(current_ability, :read).all(:select => 'id, name', :order => 'name') }
=end
    relation_collections  :related => "document_forms", :through => "rel_fond_document_forms",
      :suggested => Proc.new{ DocumentForm.accessible_by(current_ability, :read).select('id, name').order('name') }
# Upgrade 2.0.0 fine

    relation_collections  :related => "sources", :through => "rel_fond_sources"

    relation_collections  :related => "headings", :through => "rel_fond_headings",
      :available => Heading.accessible_by(current_ability, :read).count('id')
  end

  def set_template_paths
    template_paths = Dir.glob(File.join(Rails.root, 'public', 'templates', '*')).sort
    @select_options = template_paths.map do |path|
      File.open(path) do |file|
        [""].tap do |options|
          options << file.readline
          file.each_line{|line| options.first << line}
        end
      end
    end
  end

  def sort_column
# Upgrade 2.2.0 inizio
#    params[:sort] || "name"
    params[:sort] || "fonds.name"
# Upgrade 2.2.0 fine
  end

# Upgrade 2.0.0 inizio Strong parameters
    def fond_params
      params.require(:fond).permit!
    end
# Upgrade 2.0.0 fine

end

