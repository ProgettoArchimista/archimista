# Upgrade 2.0.0 inizio
require 'csv'
# Upgrade 2.0.0 fine

class HeadingsController < ApplicationController
  helper_method :sort_column

  load_and_authorize_resource :except => [:ajax_list, :modal_new, :modal_link]

  def index
    terms
    conditions = params[:view] ? "heading_type = '#{params[:view]}'" : ""

# Upgrade 2.0.0 inizio
=begin
    @headings = Heading.accessible_by(current_ability, :read).
                paginate(:page => params[:page],
                         :conditions => conditions,
                         :order => sort_column + ' ' + sort_direction)

    @counts_by_type = Heading.accessible_by(current_ability, :read).count("id", :group => :heading_type)

    @units_counts = RelUnitHeading.count("id", :conditions => {:heading_id => @headings.map(&:id)}, :group => :heading_id)
=end
    @headings = Heading.accessible_by(current_ability, :read).where(conditions).order(sort_column + ' ' + sort_direction).page(params[:page])

    @counts_by_type = Heading.accessible_by(current_ability, :read).group(:heading_type).count("id")

    @units_counts = RelUnitHeading.where({:heading_id => @headings.map(&:id)}).group(:heading_id).count("id")
# Upgrade 2.0.0 fine
  end

  def list
    terms
    term = params[:term] || ""

    unless params[:exclude].blank?
      exclude_condition = " AND id NOT IN (#{params[:exclude].join(',')})"
    end

# Upgrade 2.0.0 inizio
=begin
    @headings = Heading.accessible_by(current_ability, :read).
      find(:all, :conditions => "(LOWER(heading_type) LIKE '%#{term}%'
                                  OR LOWER(name) LIKE '%#{term}%'
                                  OR LOWER(dates) LIKE '%#{term}%'
                                  OR LOWER(qualifier) LIKE '%#{term}%')
                                  #{exclude_condition}",
           :order => "name", :limit => 20)
=end
    @headings = Heading.accessible_by(current_ability, :read).
      where("(LOWER(heading_type) LIKE '%#{term}%'
                                  OR LOWER(name) LIKE '%#{term}%'
                                  OR LOWER(dates) LIKE '%#{term}%'
                                  OR LOWER(qualifier) LIKE '%#{term}%')
                                  #{exclude_condition}").order("name")
# Upgrade 2.0.0 fine

    ActiveRecord::Base.include_root_in_json = false
    response = @headings.to_json(:methods => [:id, :value], :only => :methods)

    respond_to do |format|
      format.json { render :json => response }
    end
  end

  def show
    terms
    @heading = Heading.find(params[:id])
# Upgrade 2.0.0 inizio
=begin
    @units = Unit.all(
     :include => :rel_unit_headings,
     :conditions => "rel_unit_headings.heading_id = #{@heading.id}"
    ).paginate(:page => params[:page])
=end
    @units = Unit.includes(:rel_unit_headings).where("rel_unit_headings.heading_id = #{@heading.id}").references(:rel_unit_headings).page(params[:page])
# Upgrade 2.0.0 fine
  end

  def new
    terms
    @heading = Heading.new
  end

  def edit
    terms
    @heading = Heading.find(params[:id])
  end

  def create
    terms
# Upgrade 2.0.0 inizio Strong parameters
=begin
    @heading = Heading.new(params[:heading]).tap do |heading|
      heading.group_id = current_user.group_id
    end
=end
    @heading = Heading.new(heading_params).tap do |heading|
      heading.group_id = current_user.group_id
    end
# Upgrade 2.0.0 fine

    if @heading.save
      redirect_to(headings_url, :notice => 'Lemma creato')
    else
      render :action => "new"
    end
  end

  def modal_new
    terms
    render :partial => 'headings/new_heading', :layout => false
  end

  def modal_link
    terms
    model = params[:related_entity].singularize.camelize.constantize
# Upgrade 2.0.0 inizio
=begin
    @entity = model.find(params[:related_entity_id], :include => :headings)
    render :partial => 'headings/link_heading', :object => @entity.heading_ids, :layout => false
=end
    @entity = model.includes(:headings).find(params[:related_entity_id])
    render :partial => 'headings/link_heading', :object => @entity.heading_ids, :layout => false, :as => "object"
# Upgrade 2.0.0 fine
  end

  def modal_create
# Upgrade 2.0.0 inizio Strong parameters
#    @heading = Heading.find_or_initialize(params[:heading])
    @heading = Heading.find_or_initialize(heading_params)
# Upgrade 2.0.0 fine

    model = params[:related_entity].singularize.camelize.constantize
    @entity = model.find(params[:related_entity_id])
    respond_to do |format|
      if @heading.new_record?
# Upgrade 2.0.0 inizio Strong parameters
#        @entity.headings.create(params[:heading])
        @entity.headings.create(heading_params)
# Upgrade 2.0.0 fine
        format.json { render :json => {:status => "success" }}
      else
        @entity.headings.push(@heading) unless @entity.headings.include? @heading
        format.json { render :json => {:status => "success" }}
      end
    end
  end

  def ajax_list
    model = params[:related_entity].singularize.camelize.constantize
# Upgrade 2.0.0 inizio
=begin
    @entity = model.find(params[:related_entity_id], :include => :headings)
    render :partial => 'headings/list_for', :object => @entity.headings, :layout => false
=end
    @entity = model.includes(:headings).find(params[:related_entity_id])
    render :partial => 'headings/list_for', :object => @entity.headings, :layout => false, :as => "object"
# Upgrade 2.0.0 fine
  end

  def ajax_remove
    @heading = Heading.find(params[:heading_id])
    model = params[:related_entity].singularize.camelize.constantize
    @entity = model.find(params[:related_entity_id])
    @entity.headings.delete(@heading)

    respond_to do |format|
      if @entity.save
        format.json { render :json => {:status => "success"} }
      else
        format.json { render :json => {:status => "failure", :msg => 'Rimozione non riuscita'} }
      end
    end
  end

  def ajax_link
    @heading = Heading.find(params[:heading_id])
    model = params[:related_entity].singularize.camelize.constantize
    @entity = model.find(params[:related_entity_id])
    @entity.headings.push(@heading) unless @entity.headings.include? @heading
    respond_to do |format|
      format.json { render :json => {:status => "success"} }
    end
  end

  def update
    terms
    @heading = Heading.find(params[:id])

# Upgrade 2.0.0 inizio Strong parameters
=begin
    if @heading.update_attributes(params[:heading])
      redirect_to(headings_url(:view => @heading.heading_type), :notice => 'Lemma aggiornato')
    else
      render :action => "edit"
    end
=end
    if @heading.update_attributes(heading_params)
      redirect_to(headings_url(:view => @heading.heading_type), :notice => 'Lemma aggiornato')
    else
      render :action => "edit"
    end
# Upgrade 2.0.0 fine
  end

  def destroy
    @heading = Heading.find(params[:id])
    @heading.destroy

    redirect_to(headings_url)
  end

  def import_csv
  end

  def preview_csv
    terms

    if params[:upload].present?
      begin
# Upgrade 2.0.0 inizio
#        @csv = FasterCSV.parse(params[:upload][:csv], :col_sep => ";", :headers => headers)
        @csv = CSV.read(params[:upload][:csv].path(), :col_sep => ";", :headers => headers)
# Upgrade 2.0.0 fine
      rescue Exception => e
        flash.now[:alert] = "CSV non valido"
        render :action => "import_csv"
      end
    else
      render :action => "import_csv"
    end
  end

  def save_csv
    terms
    if File.exist?(params[:filename])
      @file = File.new(params[:filename], "r")
# Upgrade 2.0.0 inizio
#      @csv = FasterCSV.new(@file, :col_sep => ";", :headers => headers)
      @csv = CSV.new(@file, :col_sep => ";", :headers => headers)
# Upgrade 2.0.0 fine
      @csv.each do |row|
        @record = Heading.new(
          :heading_type => row[0],
          :name => row[1],
          :dates => row[2],
          :qualifier => row[3],
          :group_id => current_user.group_id
        )
        @record.save
      end
      redirect_to(headings_url, :notice => "Lemmi importati")
    else
      redirect_to(headings_url, :alert => "Si è verificato un errore durante l'importazione dei lemmi")
    end
  end

  private

  def sort_column
     params[:sort] || "name"
  end

# Upgrade 2.0.0 inizio Strong parameters
  def heading_params
    params.require(:heading).permit!
  end
# Upgrade 2.0.0 fine

end
