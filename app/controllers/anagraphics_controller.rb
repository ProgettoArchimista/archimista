require 'csv'

class AnagraphicsController < ApplicationController
  helper_method :sort_column

  load_and_authorize_resource :except => [:ajax_list, :modal_new, :modal_link, :import_csv]

  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        if (["show","edit","update","destroy"].include?(params[:action]))
          a = Anagraphic.find(params[:id])
          @current_ability ||= Ability.new(current_user, a.group_id)
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
        elsif (["preview_csv","save_csv"].include?(params[:action]))
          if params[:anagraphic][:group_id].present?
            group_id = str2int(params[:anagraphic][:group_id])
            @current_ability ||= Ability.new(current_user, group_id)
          end
        elsif (["modal_link","modal_create"].include?(params[:action]))
          related_entity_controller = if params["related_entity"].present? then params["related_entity"] else nil end
          related_entity_id = if params["related_entity_id"].present? then params["related_entity_id"] else nil end
          if !related_entity_controller.nil? && !related_entity_id.nil?
            if related_entity_controller == "units"
              group_id = str2int(Fond.find(Unit.find(related_entity_id).fond_id).group_id)
            else
              group_id = nil
            end
            if !group_id.nil?
              @current_ability ||= Ability.new(current_user, group_id)
            end
          end
        elsif (["ajax_link","ajax_remove"].include?(params[:action]))
          if params[:anagraphic_id].present?
            group_id = str2int(Anagraphic.find(params[:anagraphic_id]).group_id)
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

  def index
    terms
    conditions = params[:view] ? "anagraphic_type = '#{params[:view]}'" : ""

    @anagraphics = Anagraphic.list.accessible_by(current_ability, :read).where(conditions).order(sort_column + ' ' + sort_direction).page(params[:page])

    @counts_by_type = Anagraphic.accessible_by(current_ability, :read).group(:anagraphic_type).count("id")

    @units_counts = RelUnitAnagraphic.where({:anagraphic_id => @anagraphics.map(&:id)}).group(:anagraphic_id).count("id")

  end

  def list
    terms
    term = params[:term] || ""

    unless params[:exclude].blank?
      exclude_condition = " AND id NOT IN (#{params[:exclude].join(',')})"
    end

    @anagraphics = Anagraphic.accessible_by(current_ability, :read).
      where("(LOWER(anagraphic_type) LIKE '%#{term}%'
                                  OR LOWER(name) LIKE '%#{term}%'
                                  OR LOWER(surname) LIKE '%#{term}%')
                                  #{exclude_condition}").order("name")

    ActiveRecord::Base.include_root_in_json = false
    response = @anagraphics.to_json(:methods => [:id, :value], :only => :methods)

    respond_to do |format|
      format.json { render :json => response }
    end
  end

  def show
    terms
    @anagraphic = Anagraphic.find(params[:id])

    @units = Unit.includes(:rel_unit_anagraphics).where("rel_unit_anagraphics.anagraphic_id = #{@anagraphic.id}").references(:rel_unit_anagraphics).page(params[:page])
  end

  def new
    terms
    @anagraphic = Anagraphic.new
  end

  def edit
    terms
    @anagraphic = Anagraphic.find(params[:id])
  end

  def create
    terms
    @anagraphic = Anagraphic.new(anagraphic_params).tap do |anagraphic|
      if current_user.is_multi_group_user?()
        anagraphic.group_id = current_ability.target_group_id
      else
        anagraphic.group_id = current_user.rel_user_groups[0].group_id
      end
    end

    if @anagraphic.save
      redirect_to(anagraphics_url, :notice => 'Anagrafica creata')
    else
      render :action => "new"
    end
  end

  def modal_new
    terms
    @anagraphic = Anagraphic.new
    render :partial => 'anagraphics/new_anagraphic', :layout => false
  end

  def modal_link
    terms
    model = params[:related_entity].singularize.camelize.constantize

    @entity = model.includes(:anagraphics).find(params[:related_entity_id])
    render :partial => 'anagraphics/link_anagraphic', :object => @entity.anagraphic_ids, :layout => false, :as => "object"
  end

  def modal_create
    model = params[:related_entity].singularize.camelize.constantize
    @entity = model.find(params[:related_entity_id])
    @anagraphic = Anagraphic.new(anagraphic_params)

    respond_to do |format|
      if @anagraphic.new_record?
        @entity.anagraphics.create(anagraphic_params)
        format.json { render :json => {:status => "success" }}
      else
        @entity.anagraphics.push(@anagraphic) unless @entity.anagraphics.include? @anagraphic
        format.json { render :json => {:status => "success" }}
      end
    end
  end

  def ajax_list
    model = params[:related_entity].singularize.camelize.constantize

    @entity = model.includes(:anagraphics).find(params[:related_entity_id])
    render :partial => 'anagraphics/list_for', :object => @entity.anagraphics, :layout => false, :as => "object"
  end

  def ajax_remove
    @anagraphic = Anagraphic.find(params[:anagraphic_id])
    model = params[:related_entity].singularize.camelize.constantize
    @entity = model.find(params[:related_entity_id])
    @entity.anagraphics.delete(@anagraphic)

    respond_to do |format|
      if @entity.save
        format.json { render :json => {:status => "success"} }
      else
        format.json { render :json => {:status => "failure", :msg => 'Rimozione non riuscita'} }
      end
    end
  end

  def ajax_link
    @anagraphic = Anagraphic.find(params[:anagraphic_id])
    model = params[:related_entity].singularize.camelize.constantize
    @entity = model.find(params[:related_entity_id])
    @entity.anagraphics.push(@anagraphic) unless @entity.anagraphics.include? @anagraphic
    respond_to do |format|
      format.json { render :json => {:status => "success"} }
    end
  end

  def update
    terms
    @anagraphic = Anagraphic.find(params[:id])

    if @anagraphic.update_attributes(anagraphic_params)
      redirect_to(anagraphics_url(:view => @anagraphic.anagraphic_type), :notice => 'Anagrafica aggiornata')
    else
      render :action => "edit"
    end
  end

  def destroy
    @anagraphic = Anagraphic.find(params[:id])
    @anagraphic.destroy

    redirect_to(anagraphics_url)
  end

  def import_csv
  end

  def preview_csv
    terms

    if params[:upload].present?
      begin

        @csv = CSV.read(params[:upload][:csv].path(), :col_sep => ";", :headers => headers)

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

      @csv_anag = CSV.new(@file, :col_sep => ";", :headers => headers)
      
      @csv_identifiers = CSV.read(@file, :col_sep => ";", :headers => headers)

      @csv_identifiers.each_with_index do |csvirow, index|
        if csvirow.empty? 
          @breakrow = index +1
          break
       end
      end

      @csv_anag.each do |row|
        if row.empty?
          break
        else
          aia = Hash.new(0)
          @csv_identifiers.drop(@breakrow).each do |idrow|
            if(idrow[0] == row[0])
              id = rand(10 ** 10).to_s
              aia[id] = {:identifier=> idrow[1], :qualifier=> idrow[2]}
            end
          end
          if aia.size > 0
            @record = Anagraphic.new(
              :anag_identifiers_attributes => aia,
              :anagraphic_type => nil,
              :name => row[1],
              :surname => row[2],
              :start_date_place => row[3],
              :start_date => row[4],
              :end_date_place => row[5],
              :end_date => row[6],
              :group_id => if current_user.is_multi_group_user?() then current_ability.target_group_id else current_user.rel_user_groups[0].group_id end
            )
          else
            @record = Anagraphic.new(
              :anagraphic_type => nil,
              :name => row[1],
              :surname => row[2],
              :start_date_place => row[3],
              :start_date => row[4],
              :end_date_place => row[5],
              :end_date => row[6],
              :group_id => if current_user.is_multi_group_user?() then current_ability.target_group_id else current_user.rel_user_groups[0].group_id end
            )
          end
          @record.save
        end
      end
      redirect_to(anagraphics_url, :notice => "Anagrafiche importate")
    else
      redirect_to(anagraphics_url, :alert => "Si è verificato un errore durante l'importazione delle anagrafiche")
    end
  end

  private

  def sort_column
    params[:sort] || "anagraphics.name"
  end

  def anagraphic_params
    if !params[:group_id].present?
      if current_user.is_multi_group_user?()
        group_id = current_ability.target_group_id
      else
        group_id = current_user.rel_user_groups[0].group_id
      end
      params.require(:anagraphic).merge(group_id: group_id).permit!
    else
      params.require(:anagraphic).permit!
    end
  end
end
