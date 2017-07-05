class QualityChecksController < ApplicationController
  helper_method :creator_source, :creator_fond

  def index

    if params[:fond_id].present?
      redirect_to :action => 'fond', :id => params[:fond_id], :complete => params[:complete]
    end

    if params[:creator_id].present?
      redirect_to :action => 'creator', :id => params[:creator_id]
    end

    if params[:custodian_id].present?
      redirect_to :action => 'custodian', :id => params[:custodian_id]
    end

    @fonds = Fond.list.
      roots.
      accessible_by(current_ability, :read).
      active.
      default_order

    @creators = Creator.list.accessible_by(current_ability, :read)
    @custodians = Custodian.list.accessible_by(current_ability, :read)

  end

  def fond
# Upgrade 2.0.0 inizio
#    @fonds = Fond.subtree_of(params[:id]).active.all(:include => :preferred_event, :order => "sequence_number")
    @fonds = Fond.subtree_of(params[:id]).active.includes(:preferred_event).order("sequence_number")
# Upgrade 2.0.0 fine

    # campi minimi
    @fonds_with_no_name = @fonds.select { |e| e.name.blank? || e.name == '[nome non compilato]'}
    @fonds_with_no_event = @fonds.select { |e| e.preferred_event.blank? }
    @fonds_with_no_fond_type = @fonds.select { |e| e.fond_type.blank? }

    # campi per un record "decoroso" => solo se inventario?
    @fonds_with_no_description = @fonds.select { |e| e.description.blank? }
    @fonds_with_no_history = @fonds.select { |e| e.history.blank? }
    @fonds_with_no_length = @fonds.select { |e| e.length.blank? }

# Upgrade 3.0.0 inizio
# Potenziamento controllo qualità con l'aggiunta della relazione fondo-progetto
    @fonds_with_no_units = @fonds.select { |e| e.units_count == 0 }
# Upgrade 3.0.0 fine    

    @fond_root_name = @fonds.first.name

    ids = @fonds.map(&:id).join(',')

# Upgrade 2.0.0 inizio
=begin
    @creators  =  Creator.all(
      :joins => :rel_creator_fonds,
      :conditions => "rel_creator_fonds.fond_id IN (#{ids})",
      :include => [:preferred_name, :preferred_event])
=end
    @creators  =  Creator.
      joins(:rel_creator_fonds).
      where("rel_creator_fonds.fond_id IN (#{ids})").
      includes([:preferred_name, :preferred_event])
      .group(:creator_id)
# Upgrade 2.0.0 fine

# Upgrade 2.0.0 inizio
=begin
    @custodians = Custodian.all(
      :joins => :rel_custodian_fonds,
      :conditions => "rel_custodian_fonds.fond_id IN (#{ids})",
      :include => [:preferred_name, :custodian_buildings])
=end
    @custodians = Custodian.
      joins(:rel_custodian_fonds).
      where("rel_custodian_fonds.fond_id IN (#{ids})").
      includes([:preferred_name, :custodian_buildings])
# Upgrade 2.0.0 fine

# Upgrade 3.0.0 inizio
# Potenziamento controllo qualità con l'aggiunta della relazione fondo-progetto, fondo-fonti e produttore-fonti

    @projects = Project.
      joins(:rel_project_fonds)
      .where("rel_project_fonds.fond_id IN (#{params[:id]})")

    @fonds_with_sources = Fond.
      joins(:rel_fond_sources)
      .where("rel_fond_sources.fond_id IN (#{ids})")
      .group(:fond_id)
# Upgrade 3.0.0 fine
  end

  def creator
    @creator = Creator.find(params[:id])
  end

  def custodian
    @custodian = Custodian.find(params[:id])
  end

  def creator_source(id)
     @creator = RelCreatorSource.where("rel_creator_sources.creator_id IN (#{id})")
  end

  def creator_fond(id)
    fond = Fond.find(id)
  end

end
