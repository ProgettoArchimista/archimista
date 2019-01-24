# FIXME: custodian report => report vuoto se manca progetto

# TODO: valutare l'utilizzo di simple_format nelle viste

class ReportsController < ApplicationController

# Upgrade 2.0.0 inizio
  class PDFKitWrapper < PDFKit
    # Overwriting the command method.
    # la funzione command() contenuta nella versione 0.7.0 di pdfkit non produce delle command line corrette se ci sono caratteri come spazi, " (doppiapici), [] (parentesi quadre) in alcuni dei parametri. Questa è un adattamento della versione di command() presente nella versione 0.5.1
    def command(path = nil)
      # da pdfkit-0.5.1 - inizio
      # TAI 11/01/2016 per gestire correttamente i percorsi con eventuali spazi
      # args = [executable]
      strExe = executable
      if strExe.include? " "
        strExe = "\"" + strExe + "\""
      end
      args = [strExe]
      #
      args += @options.to_a.flatten.compact
      args << '--quiet'

      if @source.html?
        args << '-' # Get HTML from stdin
      else
        args << @source.to_s
      end
      # TAI 11/01/2016 per gestire correttamente i percorsi con eventuali spazi
      # args << (path || '-') # Write to file or stdout
      strPath = (path || '-') # Write to file or stdout
      if strPath.include? " "
        strPath = "\"" + strPath + "\""
      end
      args << strPath
      #
      args.map {|arg| %Q{"#{arg.gsub('"', '\"')}"}}
      # da pdfkit-0.5.1 - fine

      args.join(' ')  # da array a stringa
    end
  end
# Upgrade 2.0.0 fine

  LIMIT_FOR_PREVIEW = 100

  def index
    @fonds = Fond.list.
      roots.
      accessible_by(current_ability, :read).
      active.
      default_order

    # TODO: al momento l'interfaccia gestisce massimo 100 record. Fare
    # live_search (anziché paginate) ?
    @custodians = Custodian.export_list.accessible_by(current_ability, :read)
    @projects = Project.export_list.accessible_by(current_ability, :read)

    if params[:q].present? && params[:f].present?
      @fond = Fond.find(params[:f])
      if @fond
        redirect_to :action => 'dashboard', :id => @fond
      end
    end
    if params[:q].present? && params[:c].present?
      @custodian = Custodian.find(params[:c])
      if @custodian
        redirect_to :action => 'custodian', :id => @custodian
      end
    end
    if params[:q].present? && params[:p].present?
      @project = Project.find(params[:p])
      if @project
        redirect_to :action => 'project', :id => @project
      end
    end

  end

  def dashboard
# Upgrade 2.0.0 inizio
#    @fond = Fond.find(params[:id], :include => [:preferred_event, :creators, :custodians])
    @fond = Fond.includes([:preferred_event, :creators, :custodians]).find(params[:id])
# Upgrade 2.0.0 fine
    @units_count = @fond.active_descendant_units_count
  end

  def summary
# Upgrade 2.0.0 inizio
#    @fonds = Fond.subtree_of(params[:id]).active.all(:include => [:preferred_event], :order => "sequence_number")
#    @root_fond_name = @fonds.first.name
# @fond risulta non assegnato, da cui il fatto che è stata aggiunta l'istruzione che lo inizializza. Non è chiaro come poteva funzionare nella precedente versione
    #@fonds = Fond.subtree_of(params[:id]).active.includes([:preferred_event]).order("sequence_number")
    base_ids = [params[:id].to_i]
    tree_ordered_ids = tree_array(base_ids)


    @fonds = Fond.subtree_of(params[:id]).active.includes([:preferred_event]).sort_by{|thing| tree_ordered_ids.index thing.id}
    @fond = Fond.find(params[:id])
    @root_fond_name = @fond.name
    
# Upgrade 2.0.0 fine
    respond_to do |format|
      format.html
      format.pdf do
        filename = pdf_init("summary.html")
        render :json => {:file => "#{filename}.pdf"}
      end
    end
  end

  def tree_array(ids)
     arr = []
     ids.each do |node, children|
      children = Fond.children_of(node).active.order("position").map(&:id)
      arr << node
      arr += tree_array(children) unless children.empty? || children.nil?
     end
     arr
  end

  def inventory
    extend ReportSupport

    # ----------------
    @report_settings = ReportSettings.new(nil, "inventory", "Inventario di complesso archivistico", "inventory", nil)

    ers = EntityReportSettings.new(:project, project_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:custodian, custodian_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:creator, creator_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:fond, fond_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:unit, unit_available_attributes_info, false)
    @report_settings.entity_add(ers)

    # ----------------
    @report_settings.initialize_entities_selected_attribute_names(params, cookies)

    #@fonds = Fond.subtree_of(params[:id]).active.
    #  includes([
    #    :other_names, :fond_langs, :fond_owners, :fond_urls, :fond_identifiers, :fond_editors, :preferred_event, :sources,
    #    [:projects => [:project_managers, :project_stakeholders, :project_urls]],
    #    [:units => [:preferred_event, :unit_damages, :unit_other_reference_numbers, :unit_langs, :unit_urls, :unit_identifiers, :sources, :unit_editors, :iccd_description, :iccd_tech_spec, :iccd_authors, :iccd_subjects, :iccd_damages]],
    #    [:creators => [:preferred_name, :preferred_event, :other_names, :creator_legal_statuses, :creator_urls, :creator_identifiers, :creator_activities, :sources, :creator_editors]],
    #    [:custodians =>  [:preferred_name, :other_names, :custodian_contacts, :custodian_urls, :custodian_identifiers, :custodian_headquarter, :custodian_other_buildings, :sources, :custodian_editors]]
    #  ]).
    #  order("sequence_number")

    base_ids = [params[:id].to_i]
    tree_ordered_ids = tree_array(base_ids)

    @fonds = Fond.subtree_of(params[:id]).active.includes([
        :other_names, :fond_langs, :fond_owners, :fond_urls, :fond_identifiers, :fond_editors, :preferred_event, :sources,
        [:projects => [:project_managers, :project_stakeholders, :project_urls]],
        [:units => [:preferred_event, :unit_damages, :unit_other_reference_numbers, :unit_langs, :unit_urls, :unit_identifiers, :sources, :unit_editors, :iccd_description, :iccd_tech_spec, :iccd_authors, :iccd_subjects, :iccd_damages]],
        [:creators => [:preferred_name, :preferred_event, :other_names, :creator_legal_statuses, :creator_urls, :creator_identifiers, :creator_activities, :sources, :creator_editors]],
        [:custodians =>  [:preferred_name, :other_names, :custodian_contacts, :custodian_urls, :custodian_identifiers, :custodian_headquarter, :custodian_other_buildings, :sources, :custodian_editors]]
      ]).sort_by{|thing| tree_ordered_ids.index thing.id}

    @root_fond = @fonds.first
    @display_sequence_numbers = Unit.display_sequence_numbers_of(@root_fond)

    respond_to do |format|
      format.html
      format.pdf do
        filename = pdf_init("inventory.html")
        render :json => {:file => "#{filename}.pdf"}
      end
      format.rtf do
        filename = "inventory-#{Time.now.strftime('%Y%m%d%H%M%S')}"
        @builder = RtfBuilder.new
        @builder.target_id = params[:id]
        @builder.dest_file = "#{Rails.root}/public/downloads/#{filename}.rtf"
        @builder.build_fond_rtf_file(params, cookies)
        render :json => {:file => "#{filename}.rtf"}
        return
      end
    end
  end

  def creators
# Upgrade 2.0.0 inizio
#    fonds =  Fond.subtree_of(params[:id]).active.all(:include => [:creators => [:preferred_name, :preferred_event]], :order => "sequence_number")
#    @root_fond_name = fonds.first.name
# @fond risulta non assegnato, da cui il fatto che è stata aggiunta l'istruzione che lo inizializza. Non è chiaro come poteva funzionare nella precedente versione
    fonds =  Fond.subtree_of(params[:id]).active.includes([:creators => [:preferred_name, :preferred_event]]).order("sequence_number")
    @fond = fonds.find(params[:id])
    @root_fond_name = @fond.name
# Upgrade 2.0.0 fine

    ids = fonds.map(&:id).join(',')

# Upgrade 2.0.0 inizio
=begin
    @creators  =  Creator.all(
      :joins => :rel_creator_fonds,
      :conditions => "rel_creator_fonds.fond_id IN (#{ids})",
      :include => [:preferred_name, :preferred_event]).uniq
=end
    @creators  =  Creator.
      joins(:rel_creator_fonds).
      where("rel_creator_fonds.fond_id IN (#{ids})").
      includes([:preferred_name, :preferred_event]).uniq
# Upgrade 2.0.0 fine
    respond_to do |format|
      format.html
      format.pdf do
        filename = pdf_init("creators.html")
        render :json => {:file => "#{filename}.pdf"}
      end
    end
  end

  def units
    units_list("units.html")
  end

  def labels
    units_list("labels.html")
  end

  def project
    extend ReportSupport

    # ----------------
    @report_settings = ReportSettings.new(nil, "project", "report per progetto", "project", nil)

    ers = EntityReportSettings.new(:project, project_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:custodian, custodian_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:creator, creator_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:fond, fond_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:unit, unit_available_attributes_info, false)
    @report_settings.entity_add(ers)

    # ----------------
    @report_settings.initialize_entities_selected_attribute_names(params, cookies)

=begin
    @project_fields = [
      "project_type",
      "display_date",
      "description"
    ]

    @fond_fields = [
      "preferred_event.full_display_date",
      "extent",
      "description",
      "abstract",
      "access_condition",
      "access_condition_note",
    ]

    @creator_fields = [
      "preferred_event.full_display_date",
      "history",
      "abstract"
    ]

    @custodian_fields = [
      "history",
      "holdings",
      "collecting_policies",
      "accessibility",
      "services",
      "headquarter_address"
    ]
=end
# Upgrade 2.0.0 inizio
=begin
    @project = Project.find(params[:id], :include => [:project_managers, :project_stakeholders])
    fonds = @project.fonds.roots.active.all(:include =>
        [:preferred_event, :other_names,
        [:custodians => [:preferred_name, :custodian_headquarter, :custodian_other_buildings, :sources]],
        [:creators => [:preferred_event, :preferred_name, :other_names, :sources]], :sources]
    )
=end
    @project = Project.includes([:project_managers, :project_stakeholders, :project_urls]).find(params[:id])
    fonds = @project.fonds.roots.active.includes(
        [:other_names, :fond_langs, :fond_owners, :fond_urls, :fond_identifiers, :fond_editors, :preferred_event, :sources,
          [:custodians => [:preferred_name, :other_names, :custodian_contacts, :custodian_urls, :custodian_identifiers, :custodian_headquarter, :custodian_other_buildings, :sources, :custodian_editors]],
          [:creators => [:preferred_name, :preferred_event, :other_names, :creator_legal_statuses, :creator_urls, :creator_identifiers, :creator_activities, :sources, :creator_editors]],
          [:units => [:preferred_event, :unit_damages, :unit_other_reference_numbers, :unit_langs, :unit_urls, :unit_identifiers, :sources, :unit_editors, :iccd_description, :iccd_tech_spec, :iccd_authors, :iccd_subjects, :iccd_damages]]
        ]
    )
# Upgrade 2.0.0 fine
=begin
    @custodians = []
    @fonds = Hash.new {|h,k| h[k] = []}
    @creators = Hash.new {|h,k| h[k] = []}
    @sources = []
    fonds.each do |fond|
      fond.sources.each do |source|
        @sources.push(source)
      end
      fond.custodians.each do |custodian|
        custodian.sources.each do |source|
          @sources.push(source)
        end
        @custodians.push(custodian)
        @fonds[custodian.id].push(fond)
        fond.creators.each do |creator|
          @creators[fond.id].push(creator)
          creator.sources.each do |source|
            @sources.push(source)
          end
        end
      end
    end
    @custodians = @custodians.uniq.sort{|a,b| a.display_name <=> b.display_name}
    @sources = @sources.uniq.sort{|a,b| a.short_title <=> b.short_title}
    @fonds.each do |key, value|
      @fonds[key] = value.uniq
    end
    @creators.each do |key, value|
      @creators[key] = value.uniq
    end
=end
    @custodians = []
    fonds.each do |fond|
      fond.custodians.each do |custodian|
        @custodians.push(custodian)
      end
    end
    @custodians = @custodians.uniq.sort{|a,b| a.display_name <=> b.display_name}

    respond_to do |format|
      format.html
      format.pdf do
        filename = pdf_init("project.html")
        render :json => {:file => "#{filename}.pdf"}
      end
      format.rtf do
        filename = "project-#{Time.now.strftime('%Y%m%d%H%M%S')}"
        @builder = RtfBuilder.new
        @builder.target_id = params[:id]
        @builder.dest_file = "#{Rails.root}/public/downloads/#{filename}.rtf"
        @builder.build_project_rtf_file(params, cookies)
        render :json => {:file => "#{filename}.rtf"}
      end
    end
  end

  def custodian
    extend ReportSupport

    # ----------------
    @report_settings = ReportSettings.new(nil, "custodian", "Report per conservatore", "custodian", nil)

    ers = EntityReportSettings.new(:custodian, custodian_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:project, project_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:creator, creator_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:fond, fond_available_attributes_info, false)
    @report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:unit, unit_available_attributes_info, false)
    @report_settings.entity_add(ers)

    # ----------------
    @report_settings.initialize_entities_selected_attribute_names(params, cookies)

    @custodian = Custodian.includes([:preferred_name, :other_names, :custodian_contacts, :custodian_urls, :custodian_identifiers, :custodian_headquarter, :custodian_other_buildings, :sources, :custodian_editors]).find(params[:id])
    @fonds = @custodian.fonds.roots.active.includes(
        [:other_names, :fond_langs, :fond_owners, :fond_urls, :fond_identifiers, :fond_editors, :preferred_event, :sources,
          [:projects => [:project_managers, :project_stakeholders, :project_urls]],
          [:creators => [:preferred_name, :preferred_event, :other_names, :creator_legal_statuses, :creator_urls, :creator_identifiers, :creator_activities, :sources, :creator_editors]],
          [:units => [:preferred_event, :unit_damages, :unit_other_reference_numbers, :unit_langs, :unit_urls, :unit_identifiers, :sources, :unit_editors, :iccd_description, :iccd_tech_spec, :iccd_authors, :iccd_subjects, :iccd_damages]]
        ]
    )	
    @projects = []
    @fonds.each do |fond|
      fond.projects.each do |project|
        @projects.push(project)
      end
    end
    @projects = @projects.uniq

    respond_to do |format|
      format.html
      format.pdf do
        filename = pdf_init("custodian.html")
        render :json => {:file => "#{filename}.pdf"}
      end
      format.rtf do
        filename = "custodian-#{Time.now.strftime('%Y%m%d%H%M%S')}"
        @builder = RtfBuilder.new
        @builder.target_id = params[:id]
        @builder.dest_file = "#{Rails.root}/public/downloads/#{filename}.rtf"
        @builder.build_custodian_rtf_file(params, cookies)
        render :json => {:file => "#{filename}.rtf"}
      end
    end
  end

  def download
    file = "#{Rails.root}/public/downloads/#{params[:file]}"
    send_file(file)
  end

  private

  def units_list(action)
# Upgrade 2.0.0 inizio
#    @fond = Fond.find(params[:id], :select => "id, ancestry, name")
    @fond = Fond.select("id, ancestry, name").find(params[:id])
# Upgrade 2.0.0 fine
    @display_sequence_numbers = Unit.display_sequence_numbers_of(@fond.root)
    params[:order] ||= "sequence_number"
    params[:mode] ||= "full"
    params[:subtree] ||= "1"

# Upgrade 2.0.0 inizio
=begin
    options = {
      :conditions => "sequence_number IS NOT NULL",
      :include => [:preferred_event],
      :order => "units.#{params[:order]}"
    }

    if params[:subtree] == "1"
      @subtree_ids = @fond.subtree.active.all(:select => "id").map(&:id)
      options.merge!({:conditions => {:fond_id => @subtree_ids}})
    else
      options.merge!({:conditions => {:fond_id => @fond.id}})
    end

    @units_count = Unit.count(options)

    options.merge!({:limit => LIMIT_FOR_PREVIEW}) if params[:mode] == "preview"

    @units = Unit.all(options)
=end
    conditionParam = "sequence_number IS NOT NULL"  # è inutile, viene poi riassegnato sempre
    includeParam = [:preferred_event]
    orderParam = "units.#{params[:order]}"

    if params[:subtree] == "1"
      @subtree_ids = @fond.subtree.active.select("id").map(&:id)
      conditionParam = "#{:fond_id} IN (#{@subtree_ids.join(',')})"
    else
      conditionParam = "#{:fond_id} = #{@fond.id}"
    end

    @units_count = Unit.where(conditionParam).includes(includeParam).count()

    if params[:mode] == "preview"
      @units = Unit.where(conditionParam).includes(includeParam).order(orderParam).limit(LIMIT_FOR_PREVIEW)
    else
      @units = Unit.where(conditionParam).includes(includeParam).order(orderParam)
    end
# Upgrade 2.0.0 fine

    filename = "#{File.basename(action,'.*')}-#{Time.now.strftime('%Y%m%d%H%M%S')}"
    respond_to do |format|
      format.html
      format.pdf do
        filename = pdf_init(action)
        render :json => {:file => "#{filename}.pdf"}
      end
      format.csv do
        File.open("#{Rails.root}/public/downloads/#{filename}.csv", 'w') do |f|
          f.write(Unit.to_csv(@units, @fond.root.name, @display_sequence_numbers))
        end
        render :json => {:file => "#{filename}.csv"}
      end
      format.xls do
        File.open("#{Rails.root}/public/downloads/#{filename}.xls", 'w') do |f|
          f.write(render_to_string)
        end
        render :json => {:file => "#{filename}.xls"}
      end

    end
  end

  def pdf_init(action)
# Upgrade 2.0.0 inizio
=begin
    options = {
      :margin_top    => '2.5cm',
      :margin_right  => '2cm',
      :margin_bottom => '2.5cm',
      :margin_left   => '2cm',
      :footer_font_size => 8,
      :footer_spacing => 15,
      :footer_center => "[page] di [toPage]"
    }

    if action == "labels.html"
      options = {
        :margin_top    => '0.25cm',
        :margin_right  => '0cm',
        :margin_bottom => '0cm',
        :margin_left   => '0cm',
      }
    end

    prefix = File.basename(action, '.*')

    unless ["labels", "inventory", "project", "custodian"].include? prefix
      options.merge!({:orientation => 'Landscape', :dpi => '150'})
    else
      options.merge!({:dpi => '300'})
    end

    filename = "#{prefix}-#{Time.now.strftime('%Y%m%d%H%M%S')}"
    html = render_to_string(:action => action)
    kit = PDFKit.new(html, options)
    kit.stylesheets << "#{Rails.root}/public/stylesheets/reports-print.css"
    kit.to_file("#{Rails.root}/public/downloads/#{filename}.pdf")
    filename
=end
    if action == "labels.html"
      options =
        {
          :margin_top    => '0.25cm',
          :margin_right  => '0cm',
          :margin_bottom => '0cm',
          :margin_left   => '0cm',
        }
    else
      options = 
        {
          :margin_top    => '2.5cm',
          :margin_right  => '2cm',
          :margin_bottom => '2.5cm',
          :margin_left   => '2cm',
          :footer_font_size => 8,
          :footer_spacing => 15,
          :footer_center => '"[page] di [toPage]"'
        }
    end

    prefix = File.basename(action, '.*')

    unless ["labels", "inventory", "project", "custodian"].include? prefix
      options.merge!({:orientation => 'Landscape', :dpi => '150'})
    else
      options.merge!({:dpi => '300'})
    end

    filename = "#{prefix}-#{Time.now.strftime('%Y%m%d%H%M%S')}"
    html = render_to_string(:action => action, :layout => false)
    kit = PDFKitWrapper.new(html, options)
    kit.stylesheets << "#{Rails.root}/public/stylesheets/reports-print.css"
    kit.to_file("#{Rails.root}/public/downloads/#{filename}.pdf")
    filename
# Upgrade 2.0.0 fine
  end
end
