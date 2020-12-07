class ImportsController < ApplicationController
  load_and_authorize_resource
  # Upgrade 2.2.0 inizio
  skip_load_and_authorize_resource :only => [ :new ]
  # Upgrade 2.2.0 fine

  attr_accessor :is_batch_import, :batch_import_user, :batch_import_filename
  
  # Upgrade 2.2.0 inizio
  def current_ability
    current_user_tmp = NIL
    if !@is_batch_import
      current_user_tmp = current_user
    else
      current_user_tmp = @batch_import_user
    end
    current_user = current_user_tmp

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
    if !@is_batch_import
      if @current_ability.nil?
        @current_ability = super
      end
    end
    return @current_ability
  end
  # Upgrade 2.2.0 fine

  def index
    # Upgrade 2.0.0 inizio
    #@imports = Import.accessible_by(current_ability, :read).all(:include => [:importable], :conditions => {:deletable => true}, :order => "created_at DESC")
    @imports = Import.accessible_by(current_ability, :read).includes([:importable]).where({:deletable => true}).order("created_at DESC")
    # Upgrade 2.0.0 fine
  end

  def new
    @import = Import.new
    @is_icar_import = false
  end

  def create
    if import_params.present?
      current_user_tmp = NIL
      if !@is_batch_import
        @import = Import.new(import_params)
        current_user_tmp = current_user
      else
        current_user_tmp = @batch_import_user
        @import = Import.new({"group_id"=>"1"})
        @import.is_batch_import = true
        @import.batch_import_filename = @batch_import_filename
      end
      current_user = current_user_tmp

      @import.user_id = current_user.id
      if current_user.is_multi_group_user?()
        @import.group_id = current_ability.target_group_id
      else
        @import.group_id = current_user.rel_user_groups[0].group_id
      end
      
      if !@is_batch_import
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
      end

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
          if !@is_batch_import
            redirect_to redirect_url_new, :alert => e.message
          else
            Rails.logger.warn e.message
            puts "\n>>> #{e.message}"
          end
          return
        end
        # Upgrade 2.2.0 inizio
        #if @import.import_aef_file(current_user)
        extens = File.extname(@import.data_file_name).downcase.gsub('.', '')
        if ['aef'].include? extens
          if @import.import_aef_file(current_user, current_ability)
        # Upgrade 2.2.0 fine
            @import.delete_tmp_files
            @import.update_attributes :importable_id => @import.importable_id, :importable_type => @import.importable_type
            msg = "File importato correttamente."
            if !@is_batch_import
              redirect_to redirect_url, :notice => msg
            else
              Rails.logger.info msg
              puts "\n> #{msg}"
            end
          else
            @import.delete_tmp_files
            @import.delete
            msg = "Si è verificato un errore durante l'importazione del file <code>aef</code>."
            if !@is_batch_import
              redirect_to redirect_url, :alert => msg
            else
              Rails.logger.warn msg
              puts "\n>>> #{msg}"
            end
          end
        elsif ['xml'].include? extens
          result = @import.import_xml_file(current_user, current_ability)
          if result == 1
            @import.update_attributes :importable_id => @import.importable_id, :importable_type => @import.importable_type
            if @import.does_source_have_fonds
              msg_notice = "File importato correttamente."
              msg_alert = "Fonte importata collegata a dei complessi.\n I complessi collegati devono essere riassociati manualmente"
              if !@is_batch_import
                redirect_to redirect_url, :notice => msg_notice, :alert => msg_alert
              else
                Rails.logger.info msg_notice
                Rails.logger.warn msg_alert
                puts "\n> #{msg_notice}"
                puts ">>> #{msg_alert}"
              end
            else
              msg = "File importato correttamente."
              if !@is_batch_import
                redirect_to redirect_url, :notice => msg
              else
                Rails.logger.info msg
                puts "\n> #{msg}"
              end
            end
          else
            @import.delete
            
            if result == 2
              alert = "Si è verificato un errore nella validazione del file <code>xml</code>."
            else
              alert = "Si è verificato un errore durante l'importazione del file <code>xml</code>."
            end

            if !@is_batch_import
              redirect_to redirect_url, :alert => alert
            else
              Rails.logger.warn alert
              puts "\n>>> #{alert}"
            end
          end
        elsif ['csv'].include? extens
          if @import.import_csv_file(current_user, current_ability)
            msg = "File importato correttamente."
            if !@is_batch_import
              redirect_to redirect_url, :notice => msg
            else
              Rails.logger.info msg
              puts "\n> #{msg}"
            end
          else            
            @import.delete
            msg = "Si è verificato un errore durante l'importazione del file <code>csv</code>."
            if !@is_batch_import
              redirect_to redirect_url, :alert => msg
            else
              Rails.logger.warn msg
              puts "\n>>> #{msg}"
            end
          end
        else
          @import.delete
          msg = "Formato file non supportato."
          if !@is_batch_import
            redirect_to redirect_url, :alert => msg
          else
            Rails.logger.warn msg
            puts "\n>>> #{msg}"
          end
        end
      else
        msg = "Si è verificato un errore durante il salvataggio del file <code>aef</code>."
        if !@is_batch_import
          redirect_to redirect_url, :alert => msg
        else
          Rails.logger.warn msg
          puts "\n>>> #{msg}"
        end
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

  def import_params
    if !@is_batch_import
      imp_pars = params.require(:import).permit!
    else
      imp_pars = {"is_import_batch" => true} 
    end
    return imp_pars
  end

end
