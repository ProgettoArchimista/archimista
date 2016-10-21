class ExportsController < ApplicationController
# Upgrade 2.0.0 inizio
require 'exportjson'
# Upgrade 2.0.0 fine

  def index
    @fonds = Fond.list.
      roots.
      accessible_by(current_ability, :read).
      active.
      default_order

    @custodians = Custodian.export_list.accessible_by(current_ability, :read)
    @projects = Project.export_list.accessible_by(current_ability, :read)
    
    if params[:target_id].present? && params[:target_class].present?
      suffix = Time.now.strftime("%Y%m%d%H%M%S")

      @export = Export.new
      @export.target_id = params[:target_id]
      @export.target_class = params[:target_class]
      @export.mode = params[:mode]
      @export.metadata_file = Export::TMP_EXPORTS + "/metadata-#{suffix}.json"
      @export.data_file = Export::TMP_EXPORTS + "/data-#{suffix}.json"
      @export.dest_file = "#{Rails.root}/public/downloads/archimista-#{get_target_class_caption(@export.target_class)}-#{suffix}.aef"
# Upgrade 2.2.0 inizio
#      @export.group_id = current_user.group_id
      model = params[:target_class].singularize.camelize.constantize
      entity = model.find(params[:target_id])
      @export.group_id = entity.group_id
# Upgrade 2.2.0 fine
      @export.create_export_file

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

  def download
    #File.delete("#{Export::TMP_EXPORTS}/#{params[:data]}")
    #File.delete("#{Export::TMP_EXPORTS}/#{params[:meta]}")
    file = "#{Rails.root}/public/downloads/#{params[:file]}"
    send_file(file)
  end

# Upgrade 2.2.0 inizio
  def units
    if params[:unit_ids].present? && params[:ref_fond_id].present?
      suffix = Time.now.strftime("%Y%m%d%H%M%S")

      @export = Export.new
      @export.target_id = -1
      @export.target_class = "unit"
      @export.mode = "full"
      @export.group_id = Fond.find(params[:ref_fond_id]).group_id
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
    end
  end
  
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

end

