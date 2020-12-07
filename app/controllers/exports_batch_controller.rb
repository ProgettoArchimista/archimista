class ExportsBatchController < ApplicationController

  OK_EXPORT_MESSAGE = "Esportazione batch avviata."
  KO_EXPORT_MESSAGE = "Errore nell'avvio dell'esportazione batch."

  def index
    @export_folder = "#{Rails.root}/public/exports"
    
    @fonds = Fond.list.
      roots.
      accessible_by(current_ability, :read).
      active.
      default_order

    @custodians = Custodian.export_list.accessible_by(current_ability, :read)
    @projects = Project.export_list.accessible_by(current_ability, :read)
    @creators = Creator.export_list.accessible_by(current_ability, :read)
    @sources = Source.export_list.accessible_by(current_ability, :read)

    @project_select_options = []
    @projects.each do |project|
      @project_select_options.append([project.name, project.id])
    end

    @fonds_select_options = []
    @fonds.each do |fond|
      @fonds_select_options.append([fond.name, fond.id])
    end

    @custodians_select_options = []
    @custodians.each do |custodian|
      @custodians_select_options.append([custodian.name, custodian.id])
    end

    @sources_select_options = []
    @sources.each do |source|
      @sources_select_options.append([source.short_title, source.id])
    end
  end

  def icarimport
    begin
      fond_id = params[:fond_id]
      if fond_id.nil?
        add_message = " Selezionare un Complesso."
        redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE + add_message)
        return
      end

      rake_req = 'rake ead:build_xml[icar-import,"' + fond_id + '"]'

      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def aefallfonds
    begin
      project_id = params[:project_id]
      if project_id.nil?
        add_message = " Selezionare un Progetto."
        redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE + add_message)
        return
      end

      rake_req = 'rake aef:build_data[fonds,"SELECT DISTINCT f.* from fonds f\, rel_project_fonds r\, projects p where p.id=r.project_id and f.id=r.fond_id and f.published is true and p.id=' + project_id + ' and trashed is false and f.ancestry_depth=0 and p.published is true"]'

      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def aeffondsnoancestry
    begin
      fond_ids = params[:fond_id]
      if fond_ids.nil?
        add_message = " Selezionare almeno un Fondo."
        redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE + add_message)
        return
      end

      fond_ids_list = fond_ids.to_s.gsub("[", "(").gsub("]", ")").gsub("\"", "").gsub(" ", "").gsub(",", "\\,")

      rake_req = 'rake aef:build_data[fonds,"SELECT DISTINCT * from fonds where id IN ' + fond_ids_list + ' and ancestry_depth=0"]'

      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def aefallfondsnoancestry
    begin
      rake_req = 'rake aef:build_data[fonds,"SELECT DISTINCT * from fonds where ancestry_depth=0"]'
      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def aefprojects
    begin
      project_ids = params[:project_id]
      if project_ids.nil?
        add_message = " Selezionare almeno un Progetto."
        redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE + add_message)
        return
      end

      project_ids_list = project_ids.to_s.gsub("[", "(").gsub("]", ")").gsub("\"", "").gsub(" ", "").gsub(",", "\\,")

      rake_req = 'rake aef:build_data[projects,"SELECT DISTINCT * from projects where id IN ' + project_ids_list + ' and published is true"]'

      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE)  
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def aefallprojects
    begin
      rake_req = 'rake aef:build_data[projects,"SELECT DISTINCT * from projects where published is true"]'
      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def aefcustodiansproject
    begin
      project_id = params[:project_id]
      if project_id.nil?
        add_message = " Selezionare un Progetto."
        redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE + add_message)
        return
      end

      rake_req = 'rake aef:build_data[custodians,"SELECT * from custodians where id IN (SELECT DISTINCT custodian_id FROM rel_custodian_fonds WHERE fond_id IN (SELECT DISTINCT f.id from rel_project_fonds r\, fonds f\, projects p where p.id=r.project_id and f.id=r.fond_id and f.published is true and p.id=' + project_id + ' and trashed is false and f.ancestry_depth=0 and p.published is true))"]'

      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def aefcustodians
    begin
      custodian_ids = params[:custodian_id]
      if custodian_ids.nil?
        add_message = " Selezionare almeno un Conservatore."
        redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE + add_message)
        return
      end

      custodian_ids_list = custodian_ids.to_s.gsub("[", "(").gsub("]", ")").gsub("\"", "").gsub(" ", "").gsub(",", "\\,")

      rake_req = 'rake aef:build_data[custodians,"SELECT DISTINCT * from custodians where id IN ' + custodian_ids_list + '"]'

      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE)  
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def aefallcustodians
    begin
      rake_req = 'rake aef:build_data[custodians,"SELECT DISTINCT * from custodians"]'
      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def xmlallfonds
    begin
      project_id = params[:project_id]
      if project_id.nil?
        add_message = " Selezionare un Progetto."
        redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE + add_message)
        return
      end

      rake_req = 'rake ead:build_xml[fonds,"SELECT DISTINCT f.* from rel_project_fonds r\, fonds f\, projects p where p.id=r.project_id and f.id=r.fond_id and f.published is true and p.id=' + project_id + ' and trashed is false and f.ancestry_depth=0"]'

      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def xmlfondsnoancestry
    begin
      fond_ids = params[:fond_id]
      if fond_ids.nil?
        add_message = " Selezionare almeno un Fondo."
        redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE + add_message)
        return
      end

      fond_ids_list = fond_ids.to_s.gsub("[", "(").gsub("]", ")").gsub("\"", "").gsub(" ", "").gsub(",", "\\,")

      rake_req = 'rake ead:build_xml[fonds,"SELECT DISTINCT * from fonds where id IN ' + fond_ids_list + ' and ancestry_depth=0"]'

      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def xmlallfondsnoancestry
    begin
      rake_req = 'rake ead:build_xml[fonds,"SELECT DISTINCT * from fonds where ancestry_depth=0"]'
      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def xmlsourcesproject
    begin
      project_id = params[:project_id]
      if project_id.nil?
        add_message = " Selezionare un Progetto."
        redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE + add_message)
        return
      end

      rake_req = 'rake ead:build_xml[sources,"SELECT * from sources where id IN (SELECT DISTINCT source_id FROM rel_fond_sources WHERE fond_id IN (SELECT DISTINCT f.id from rel_project_fonds r\, fonds f\, projects p where p.id=r.project_id and f.id=r.fond_id and f.published is true and p.id=' + project_id + ' and trashed is false and f.ancestry_depth=0))"]'
      # cambiato: rel_source_fonds -> rel_fond_sources

      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def xmlsources
    begin
      source_ids = params[:source_id]
      if source_ids.nil?
        add_message = " Selezionare almeno una Fonte o Strumento."
        redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE + add_message)
        return
      end

      source_ids_list = source_ids.to_s.gsub("[", "(").gsub("]", ")").gsub("\"", "").gsub(" ", "").gsub(",", "\\,")

      rake_req = 'rake ead:build_xml[sources,"SELECT DISTINCT * from sources where id IN ' + source_ids_list + '"]'

      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

  def xmlallsources
    begin
      rake_req = 'rake ead:build_xml[sources,"SELECT DISTINCT * from sources"]'
      Rails.logger.info "Esecuzione rake task: " + rake_req
      system rake_req
      redirect_to({ :action=>'index' }, :notice => OK_EXPORT_MESSAGE) 
    rescue Exception => e
      Rails.logger.warn "ECCEZIONE in exports_batch_controller: #{e.message}"
      redirect_to({ :action=>'index' }, :alert => KO_EXPORT_MESSAGE)
    end
  end

end
