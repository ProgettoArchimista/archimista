class ExportsController < ApplicationController
# Upgrade 2.0.0 inizio
require 'exportjson'
require 'builder'
# Upgrade 2.0.0 fine

  @@is_icar_file = false
  @@icar_download_file = ""

  def index
    @fonds = Fond.list.
      roots.
      accessible_by(current_ability, :read).
      active.
      default_order

    @custodians = Custodian.export_list.accessible_by(current_ability, :read)
    @projects = Project.export_list.accessible_by(current_ability, :read)
    @creators = Creator.export_list.accessible_by(current_ability, :read)
    @sources = Source.export_list.accessible_by(current_ability, :read)

    if params[:target_id].present? && params[:target_class].present?
      suffix = Time.now.strftime("%Y%m%d%H%M%S")

      @export = Export.new
      @export.target_id = params[:target_id]
      @export.target_class = params[:target_class]
      @export.mode = params[:mode]
      @export.metadata_file = Export::TMP_EXPORTS + "/metadata-#{suffix}.json"
      @export.data_file = Export::TMP_EXPORTS + "/data-#{suffix}.json"
      @export.dest_file = "#{Rails.root}/public/downloads/archimista-#{get_target_class_caption(@export.target_class)}-#{suffix}.aef"
# Upgrade 3.0.0 inizio
      @export.inc_digit = params[:inc_digit]
# Upgrade 3.0.0 fine
# Upgrade 2.2.0 inizio
#      @export.group_id = current_user.group_id
      model = params[:target_class].singularize.camelize.constantize
      entity = model.find(params[:target_id])
      @export.group_id = entity.group_id
# Upgrade 2.2.0 fine
      begin
        @export.create_export_file
      rescue Exception => e
        Rails.logger.info "ERRORE: #{e.message}"
        redirect_to exports_path, :alert => 'Errore nella creazione del file di export'
        return
      end

# Upgrade 2.0.0 inizio
# usando la struttura @export si verificava un errore
      @exportjson = ExportJson.new
      @exportjson.metadata_file = @export.metadata_file
      @exportjson.data_file = @export.data_file
      @exportjson.dest_file = @export.dest_file
# Upgrade 2.0.0 fine

      respond_to do |format|
# Upgrade 2.0.0 inizio
#        format.json { render :json => @export }
        format.json { render :json => @exportjson }
# Upgrade 2.0.0 fine
      end
    end
  end

  def xml
    if params[:target_id].present? && params[:target_class].present?
      suffix = Time.now.strftime("%Y%m%d%H%M%S")
      @export = Export.new
      @export.target_id = params[:target_id]
      @export.target_class = params[:target_class]
      @export.mode = params[:mode]            
      @export.metadata_file = Export::TMP_EXPORTS + "/metadata-#{suffix}.json"
      @export.data_file = Export::TMP_EXPORTS + "/data-#{params[:target_class]}-#{suffix}.xml"
      @export.dest_file = "#{Rails.root}/public/downloads/archimista-#{get_target_class_caption(@export.target_class)}-#{suffix}.zip"
      @export.inc_digit = params[:inc_digit]

      model = params[:target_class].singularize.camelize.constantize
      entity = model.find(params[:target_id])
      @export.group_id = entity.group_id
      target_xml = params[:target_xml]
      if target_xml.include? "san"
        @@is_icar_file = false
        @export.create_export_xml_san_file
      else
        @@is_icar_file = true
        @export.stream_icar_import
        @@icar_download_file = @export.get_icarimportfile
      end
          

      @exportjson = ExportJson.new
      @exportjson.metadata_file = @export.metadata_file
      @exportjson.data_file = @export.data_file
      @exportjson.dest_file = @export.dest_file

      respond_to do |format|
        format.json { render :json => @exportjson }
      end
    end
  end 

  def download
    #File.delete("#{Export::TMP_EXPORTS}/#{params[:data]}")
    #File.delete("#{Export::TMP_EXPORTS}/#{params[:meta]}")    
    if @@is_icar_file
      file = @@icar_download_file
    else
      file = "#{Rails.root}/public/downloads/#{params[:file]}"
    end
    send_file(file)
  end

# Upgrade 2.2.0 inizio
  def units
    # Upgrade 3.0.0 inizio
	# Definizione dell'export in formato csv per unità
    if params[:unit_ids].present? && params[:ref_fond_id].present?
	  suffix = Time.now.strftime("%Y%m%d%H%M%S")
	  @export = Export.new
	  @export.target_id = -1
	  @export.target_class = "unit"
	  @export.mode = "full"
	  @export.group_id = Fond.find(params[:ref_fond_id]).group_id
      if params[:export_type].present? && params[:export_type] == "aef"
        @export.metadata_file = Export::TMP_EXPORTS + "/metadata-#{suffix}.json"
        @export.data_file = Export::TMP_EXPORTS + "/data-#{suffix}.json"
        @export.dest_file = "#{Rails.root}/public/downloads/archimista-#{get_target_class_caption(@export.target_class)}-#{suffix}.aef"

        @export.create_units_export_file(params[:unit_ids])

        @exportjson = ExportJson.new
        @exportjson.metadata_file = @export.metadata_file
        @exportjson.data_file = @export.data_file
        @exportjson.dest_file = @export.dest_file
        respond_to do |format|
          format.json { render :json => @exportjson }
        end
      elsif params[:export_type].present? && params[:export_type] == "csv"
        @export.data_file = Export::TMP_EXPORTS + "/exports-#{suffix}.csv"
        @export.dest_file = "#{Rails.root}/public/downloads/exports-#{suffix}.csv"
        dest_folder = "#{Rails.root}/public/downloads/"
        
        @export.create_units_export_file_csv(params[:unit_ids], params[:ref_fond_id], dest_folder)

        @exportjson = ExportJson.new
        @exportjson.data_file = @export.data_file
        @exportjson.dest_file = @export.dest_file
        respond_to do |format|
          format.json { render :json => @exportjson }
        end
      end    
    end
  end
  # Upgrade 3.0.0 fine
  def get_target_class_caption(target_class)
    case target_class
      when "fond"
        caption = "export_complesso"
      when "custodian"
        caption = "export_conservatore"
      when "project"
        caption = "export_progetto"
      when "unit"
        caption = "export_unita"
      else
        caption = (target_class.nil? || target_class == "") ? "export" : "export_" + target_class
    end
    return caption
  end
# Upgrade 2.2.0 fine

  def units_ead
    if params[:units].present?
      ids = String.new
      params[:units].each do |unit|
        ids += unit.to_s + "\\,"
      end
      ids = ids[0...-2]
      rake_req = "rake ead:build_xml[units,\"SELECT DISTINCT * from units where id IN (" + ids + ")\"]"
      puts rake_req
      system rake_req
    end
=begin
# Al momento solo le unita' vengono ricercate e quindi esportate in EAD
    if(params[:fonds].present?)
      ids = String.new
      params[:units].each do |fond|
        ids += fond.to_s + "\\,"
      end
      ids = ids[0...-2]
      rake_req = "rake ead:build_xml[fonds,\"SELECT DISTINCT * from fonds where id IN (" + ids + ")\"]"
      puts rake_req
      system rake_req
    end
=end
    head :ok
  end

  def fonds_aef
    if params[:fonds].present?
      ids = String.new
      params[:fonds].each do |fond|
        ids += fond.to_s + "\\,"
      end
      ids = ids[0...-2]
      rake_req = "rake aef:build_data[fonds,\"SELECT DISTINCT * from fonds where id IN (" + ids + ")\"]"
      puts rake_req
      system rake_req
    end
    head :ok
  end

end

