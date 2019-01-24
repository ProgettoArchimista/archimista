class ImportsController < ApplicationController
  load_and_authorize_resource
# Upgrade 2.2.0 inizio
  skip_load_and_authorize_resource :only => [ :new ]
# Upgrade 2.2.0 fine

# Upgrade 2.2.0 inizio
  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        if (["destroy"].include?(params[:action]))
          i = Import.find(params[:id])
          @current_ability ||= Ability.new(current_user, i.group_id)
        elsif (["create"].include?(params[:action]))
          if params[:import][:group_id].present?
            group_id = str2int(params[:import][:group_id])
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
#    @imports = Import.accessible_by(current_ability, :read).all(:include => [:importable], :conditions => {:deletable => true}, :order => "created_at DESC")
    @imports = Import.accessible_by(current_ability, :read).includes([:importable]).where({:deletable => true}).order("created_at DESC")
# Upgrade 2.0.0 fine
  end

  def new
    @import = Import.new
  end

  def create
# Upgrade 2.0.0 inizio Strong parameters
#    if params[:import].present?
#      @import = Import.new(params[:import])
    if import_params.present?
      @import = Import.new(import_params)
# Upgrade 2.0.0 fine
      @import.user_id = current_user.id
# Upgrade 2.2.0 inizio
#      @import.group_id = current_user.group_id
      if current_user.is_multi_group_user?()
        @import.group_id = current_ability.target_group_id
      else
        @import.group_id = current_user.rel_user_groups[0].group_id
      end
      if (params[:context].present? && params[:context] == "units_import")
        is_units_import = true
        if (params[:ref_fond_id].present?)
          @import.ref_fond_id = params[:ref_fond_id]
        end
        if (params[:ref_root_fond_id].present?)
          @import.ref_root_fond_id = params[:ref_root_fond_id]
        end
        if (params[:ref_fond_id].present?)
          redirect_url = fond_units_path(params[:ref_fond_id])
          redirect_url_new = redirect_url
        else
          redirect_url = imports_url
          redirect_url_new = new_import_url
        end
      else
        is_units_import = false
        redirect_url = imports_url
        redirect_url_new = new_import_url
      end
# Upgrade 2.2.0 fine
      @import.identifier = Digest::SHA1.hexdigest("#{Time.now}")
      if @import.save
        begin
          @import.is_valid_file?
# Upgrade 2.2.0 inizio
          if is_units_import
            if !@import.is_unit_aef_file?
              raise "Il file <code>aef</code> selezionato non è stato creato esportando unità e non può quindi essere utilizzato con questa funzionalità dell'applicazione.<br>Per importarlo è necessario utilizzare le funzioni di importazione di file <code>aef</code> disponibili all'interno della relativa sezione dell'applicazione."
            end
          else
            if @import.is_unit_aef_file?
              raise "Il file <code>aef</code> selezionato è stato creato esportando unità e non può quindi essere utilizzato con questa funzionalità dell'applicazione.<br>Per importarlo è necessario utilizzare la funzionità di importazione di file <code>aef</code> contenenti unità disponibile nella pagina di visualizzazione delle unità di un complesso."
            end
          end
# Upgrade 2.2.0 fine
        rescue Exception => e
          Rails.logger.info("eccezione: #{e.message}")
          @import.delete_tmp_files
          @import.delete
# Upgrade 2.2.0 inizio
#          redirect_to new_import_url, :alert => e.message
          redirect_to redirect_url_new, :alert => e.message
# Upgrade 2.2.0 fine
          return
        end
# Upgrade 2.2.0 inizio
#        if @import.import_aef_file(current_user)
        extens = File.extname(@import.data_file_name).downcase.gsub('.', '')
        if ['aef'].include? extens
          if @import.import_aef_file(current_user, current_ability)
# Upgrade 2.2.0 fine
            @import.delete_tmp_files
            @import.update_attributes :importable_id => @import.importable_id, :importable_type => @import.importable_type
# Upgrade 2.2.0 inizio
#           redirect_to imports_url, :notice => "File importato correttamente."
            redirect_to redirect_url, :notice => "File importato correttamente."
# Upgrade 2.2.0 fine
          else
            @import.delete_tmp_files
            @import.delete
# Upgrade 2.2.0 inizio
#           redirect_to imports_url, :alert => "Si è verificato un errore durante l'importazione del file <code>aef</code>."
            redirect_to redirect_url, :alert => "Si è verificato un errore durante l'importazione del file <code>aef</code>."
# Upgrade 2.2.0 fine
          end
        elsif ['zip'].include? extens                       

          if @import.import_zip_file(current_user, current_ability)

            @import.delete_tmp_files
            @import.update_attributes :importable_id => @import.importable_id, :importable_type => @import.importable_type
            @import.delete_tmp_zip_files

            redirect_to redirect_url, :notice => "File importato correttamente."

          else
            @import.delete_tmp_files
            @import.delete_tmp_zip_files
            @import.delete

            redirect_to redirect_url, :alert => "Si è verificato un errore durante l'importazione del file <code>zip</code>."
          end
        else
          if @import.import_csv_file(current_user, current_ability)
            redirect_to redirect_url, :notice => "File importato correttamente."
          else            
            @import.delete
            redirect_to redirect_url, :alert => "Si è verificato un errore durante l'importazione del file <code>csv</code>."
          end
        end

      else
# Upgrade 2.2.0 inizio
#        redirect_to imports_url, :alert => "Si è verificato un errore durante il salvataggio del file <code>aef</code>."
        redirect_to redirect_url, :alert => "Si è verificato un errore durante il salvataggio del file <code>aef</code>."
# Upgrade 2.2.0 fine
      end
    else
      render :action => "new"
    end
  end

  def destroy
    @import = Import.find(params[:id])
    respond_to do |format|
      if @import.wipe_all_related_records
        @import.destroy
        format.json { render :json => {:status => "success"} }
      else
        format.json { render :json => {:status => "failure", :msg => "Si è verificato un errore"} }
      end
    end
  end

# Upgrade 2.0.0 inizio Strong parameters
  def import_params
    params.require(:import).permit!
  end
# Upgrade 2.0.0 fine

end
