# Upgrade 2.0.0 inizio

require 'rtfwriter'

class RtfBuilder < ActiveRecord::Base
	CCstylesheetArchimistaLabel = "archimista_label"
	CCstylesheetArchimistaSectionHeader = "archimista_section_header"
	CCstylesheetArchimistaProject = "archimista_project"
	CCstylesheetArchimistaFond = "archimista_fond"
	CCstylesheetArchimistaCustodian = "archimista_custodian"
	CCstylesheetArchimistaCreator = "archimista_creator"
	CCstylesheetArchimistaUnit = "archimista_unit"
	CCstylesheetUnitSequenceNumber = "unit_sequence_number"
	CCstylesheetSeparator = "separator"

  # See: http://railscasts.com/episodes/193-tableless-model
  # See: http://codetunes.com/2008/07/20/tableless-models-in-rails
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :dest_file, :string
  column :target_id, :integer
  attr_accessor :dest_file, :target_id

  def build_fond_rtf_file(params, cookies)
    extend ReportSupport

    rw = RtfWriter.new

    # ----------------
    report_settings = ReportSettings.new(rw, "inventory", "Inventario di complesso archivistico", "inventory", nil)

    ers = EntityReportSettings.new(:project, project_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:custodian, custodian_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:creator, creator_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:fond, fond_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:unit, unit_available_attributes_info, false)
    report_settings.entity_add(ers)

    # ----------------
    stylesheets, stylesheet_codes = prv_build_rtf_stylesheets_info(report_settings, GCrwStylePredefinedCount)

    report_settings.initialize_entities_selected_attribute_names(params, cookies)
    report_settings.rtf_stylesheet_codes = stylesheet_codes
    report_settings.rtf_stylesheet_code_archimista_label = report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaLabel)

    separator_styleindex = report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetSeparator)

    # ----------------
    fonds = Fond.subtree_of(self.target_id).active.
      includes([
        :other_names, :fond_langs, :fond_owners, :fond_urls, :fond_identifiers, :fond_editors, :preferred_event, :sources,
        [:projects => [:project_managers, :project_stakeholders, :project_urls]],
        [:units => [:preferred_event, :unit_damages, :unit_other_reference_numbers, :unit_langs, :unit_urls, :unit_identifiers, :sources, :unit_editors, :iccd_description, :iccd_tech_spec, :iccd_authors, :iccd_subjects, :iccd_damages]],
        [:creators => [:preferred_name, :preferred_event, :other_names, :creator_legal_statuses, :creator_urls, :creator_identifiers, :creator_activities, :sources, :creator_editors]],
        [:custodians =>  [:preferred_name, :other_names, :custodian_contacts, :custodian_urls, :custodian_identifiers, :custodian_headquarter, :custodian_other_buildings, :sources, :custodian_editors]]
      ]).
      order("sequence_number")

    root_fond = fonds.first
    display_sequence_numbers = Unit.display_sequence_numbers_of(root_fond)

    # ----------------
    rw.FileCreate(self.dest_file)
    rw.writeFileHead(stylesheets)

    prv_write_header_and_footer(rw, root_fond.name)

    title = []
    title.push(root_fond.name)
    title.push(root_fond.preferred_event.full_display_date) if root_fond.preferred_event.present?
    prv_title_page(rw, title.join("\n"))
    rw.writeNewPage

    # ----------------
    fond_index = 0
    fond_count = fonds.size

    fonds.each do |fond|
      prv_h1(rw, fond.name, report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaFond))
      rw.writeNewLine

      if fond.projects.present?
        rw.writeLineSeparator(separator_styleindex)
        prv_write_projects_info(rw, report_settings, fond.projects)
      end

      if fond.custodians.present?
        rw.writeLineSeparator(separator_styleindex)
        prv_write_custodians_info(rw, report_settings, fond.custodians)
      end

      if fond.creators.present?
        rw.writeLineSeparator(separator_styleindex)
        prv_write_creators_info(rw, report_settings, fond.creators)
      end

      make_rtf(rw, report_settings, :fond, fond)

      if fond.units.present?
        rw.writeLineSeparator(separator_styleindex)
        prv_write_units_info(rw, report_settings, fond.units, display_sequence_numbers, separator_styleindex)
      end
      
      if fond_index < fond_count - 1 then rw.writeLineSeparator(separator_styleindex) end
      fond_index += 1
    end

    # ----------------
    rw.writeFileTail
    rw.FileClose
  end

  def build_custodian_rtf_file(params, cookies)
    extend ReportSupport

    rw = RtfWriter.new

    # ----------------
    report_settings = ReportSettings.new(rw, "custodian", "Report per conservatore", "custodian", nil)

    ers = EntityReportSettings.new(:custodian, custodian_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:project, project_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:creator, creator_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:fond, fond_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:unit, unit_available_attributes_info, false)
    report_settings.entity_add(ers)

    # ----------------
    stylesheets, stylesheet_codes = prv_build_rtf_stylesheets_info(report_settings, GCrwStylePredefinedCount)

    report_settings.initialize_entities_selected_attribute_names(params, cookies)
    report_settings.rtf_stylesheet_codes = stylesheet_codes
    report_settings.rtf_stylesheet_code_archimista_label = report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaLabel)

    separator_styleindex = report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetSeparator)

    # ----------------
    custodian = Custodian.includes([:preferred_name, :other_names, :custodian_contacts, :custodian_urls, :custodian_identifiers, :custodian_headquarter, :custodian_other_buildings, :sources, :custodian_editors]).find(self.target_id)
    fonds = custodian.fonds.roots.active.includes(
        [:other_names, :fond_langs, :fond_owners, :fond_urls, :fond_identifiers, :fond_editors, :preferred_event, :sources,
          [:projects => [:project_managers, :project_stakeholders, :project_urls]],
          [:creators => [:preferred_name, :preferred_event, :other_names, :creator_legal_statuses, :creator_urls, :creator_identifiers, :creator_activities, :sources, :creator_editors]],
          [:units => [:preferred_event, :unit_damages, :unit_other_reference_numbers, :unit_langs, :unit_urls, :unit_identifiers, :sources, :unit_editors, :iccd_description, :iccd_tech_spec, :iccd_authors, :iccd_subjects, :iccd_damages]]
        ]
    )	
    projects = []
    fonds.each do |fond|
      fond.projects.each do |project|
        projects.push(project)
      end
    end
    projects = projects.uniq

    # ----------------
    rw.FileCreate(self.dest_file)
    rw.writeFileHead(stylesheets)

    prv_write_header_and_footer(rw, custodian.display_name)

    # ----------------
    prv_title_page(rw, custodian.display_name)
    rw.writeNewPage

    # ----------------
    prv_h1(rw, custodian.display_name, report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaCustodian))
    rw.writeNewLine
		make_rtf(rw, report_settings, :custodian, custodian)

    # ----------------
    if projects.present?
      rw.writeLineSeparator(separator_styleindex)
      prv_write_projects_info(rw, report_settings, projects)
    end

    # ----------------
		if fonds.size > 0
      rw.writeLineSeparator(separator_styleindex)
      prv_write_fonds_info(rw, report_settings, fonds, separator_styleindex)
		end

    # ----------------
    rw.writeFileTail
    rw.FileClose
  end

  def build_project_rtf_file(params, cookies)
    extend ReportSupport

    rw = RtfWriter.new

    # ----------------
    report_settings = ReportSettings.new(rw, "project", "report per progetto", "project", nil)

    ers = EntityReportSettings.new(:project, project_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:custodian, custodian_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:creator, creator_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:fond, fond_available_attributes_info, false)
    report_settings.entity_add(ers)

    ers = EntityReportSettings.new(:unit, unit_available_attributes_info, false)
    report_settings.entity_add(ers)

    # ----------------
    stylesheets, stylesheet_codes = prv_build_rtf_stylesheets_info(report_settings, GCrwStylePredefinedCount)

    report_settings.initialize_entities_selected_attribute_names(params, cookies)
    report_settings.rtf_stylesheet_codes = stylesheet_codes
    report_settings.rtf_stylesheet_code_archimista_label = report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaLabel)

    separator_styleindex = report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetSeparator)

    # ----------------
    project = Project.includes([:project_managers, :project_stakeholders, :project_urls]).find(self.target_id)
    fonds = project.fonds.roots.active.includes(
        [:other_names, :fond_langs, :fond_owners, :fond_urls, :fond_identifiers, :fond_editors, :preferred_event, :sources,
          [:custodians => [:preferred_name, :other_names, :custodian_contacts, :custodian_urls, :custodian_identifiers, :custodian_headquarter, :custodian_other_buildings, :sources, :custodian_editors]],
          [:creators => [:preferred_name, :preferred_event, :other_names, :creator_legal_statuses, :creator_urls, :creator_identifiers, :creator_activities, :sources, :creator_editors]],
          [:units => [:preferred_event, :unit_damages, :unit_other_reference_numbers, :unit_langs, :unit_urls, :unit_identifiers, :sources, :unit_editors, :iccd_description, :iccd_tech_spec, :iccd_authors, :iccd_subjects, :iccd_damages]]
        ]
    )
    custodians = []
    fonds.each do |fond|
      fond.custodians.each do |custodian|
        custodians.push(custodian)
      end
    end
    custodians = custodians.uniq.sort{|a,b| a.display_name <=> b.display_name}

    # ----------------
    rw.FileCreate(self.dest_file)
    rw.writeFileHead(stylesheets)

    prv_write_header_and_footer(rw, project.name)

    # ----------------
    title = []
    title.push(project.name)
    title.push(project.display_date)
    prv_title_page(rw, title.join("\n"))
    rw.writeNewPage
        
    # ----------------
    prv_h1(rw, project.name, report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaProject))
    rw.writeNewLine
		make_rtf(rw, report_settings, :project, project)

    # ----------------
    if custodians.size > 0
      rw.writeLineSeparator(separator_styleindex)

      custodian_index = 0
      custodian_count = custodians.size
      custodians.each do |custodian|
        prv_h2(rw, Custodian.model_name.human())
        rw.writeNewLine
        prv_h3(rw, custodian.display_name, report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaCustodian))
        make_rtf(rw, report_settings, :custodian, custodian)

        # ----------------
        if custodian.fonds.size > 0
          rw.writeLineSeparator(separator_styleindex)
          prv_write_fonds_info(rw, report_settings, custodian.fonds, separator_styleindex)
        end
        
        if custodian_index < custodian_count - 1 then rw.writeLineSeparator(separator_styleindex) end
        custodian_index += 1
      end
    end

    rw.writeFileTail
    rw.FileClose
  end

  private

  def prv_write_header_and_footer(rw, header_text)
    rw.writeRaw("\\facingp\\titlepg")
    rw.writeHeader(header_text, nil, GCrwFontNameArial, 10, nil, nil, nil, GCrwTextAlignmentLeft, nil, nil, nil, GCrwHeaderFooterPageLeft)
    rw.writeHeader(header_text, nil, GCrwFontNameArial, 10, nil, nil, nil, GCrwTextAlignmentRight, nil, nil, nil, GCrwHeaderFooterPageRight)
    rw.writeFooter("pag. %PAGE% di %NUMPAGES%", nil, GCrwFontNameArial, 10, nil, nil, nil, GCrwTextAlignmentLeft, nil, nil, nil, GCrwHeaderFooterPageLeft)
    rw.writeFooter("pag. %PAGE% di %NUMPAGES%", nil, GCrwFontNameArial, 10, nil, nil, nil, GCrwTextAlignmentRight, nil, nil, nil, GCrwHeaderFooterPageRight)
  end

  def prv_title_page(rw, s)
    rw.writeParagraph(s, GCrwStyleHeading, nil, 18, GCrwFontBoldEnabled, nil, nil, GCrwTextAlignmentCenter, nil, nil, nil)
  end

  def prv_h1(rw, s, styleIndex = nil)
    if styleIndex.nil? then styleIndex = GCrwStyleHeading1 end
    rw.writeParagraph(s, styleIndex, nil, 16, GCrwFontBoldEnabled, nil, nil, GCrwTextAlignmentJustified, nil, nil, nil)
  end

  def prv_h2(rw, s, styleIndex = nil)
    if styleIndex.nil? then styleIndex = GCrwStyleHeading2 end
    rw.writeParagraph(s, styleIndex, nil, 14, GCrwFontBoldEnabled, nil, nil, GCrwTextAlignmentJustified, nil, nil, nil)
  end

  def prv_h3(rw, s, styleIndex = nil)
    if styleIndex.nil? then styleIndex = GCrwStyleHeading3 end
    rw.writeParagraph(s, styleIndex, nil, 12, GCrwFontBoldEnabled, nil, nil, GCrwTextAlignmentJustified, nil, nil, nil)
  end

  def prv_build_rtf_stylesheets_info(report_settings, start_code)
		stylesheets = []
		stylesheet_codes = Hash.new()

		code = start_code
    stylesheets << "{\\s#{code}\\widctlpar \\f1\\fs20 \\sbasedon0\\snext#{code} #{CCstylesheetArchimistaLabel};}"
		stylesheet_codes.store("#{CCstylesheetArchimistaLabel}", code)
		code += 1

    stylesheets << "{\\s#{code}\\widctlpar \\f1\\fs20 \\sbasedon0\\snext#{code} #{CCstylesheetArchimistaSectionHeader};}"
		stylesheet_codes.store("#{CCstylesheetArchimistaSectionHeader}", code)
		code += 1

    stylesheets << "{\\s#{code}\\widctlpar \\f1\\fs20 \\sbasedon0\\snext#{code} #{CCstylesheetArchimistaProject};}"
		stylesheet_codes.store("#{CCstylesheetArchimistaProject}", code)
		code += 1

    stylesheets << "{\\s#{code}\\widctlpar \\f1\\fs20 \\sbasedon0\\snext#{code} #{CCstylesheetArchimistaFond};}"
		stylesheet_codes.store("#{CCstylesheetArchimistaFond}", code)
		code += 1

    stylesheets << "{\\s#{code}\\widctlpar \\f1\\fs20 \\sbasedon0\\snext#{code} #{CCstylesheetArchimistaCustodian};}"
		stylesheet_codes.store("#{CCstylesheetArchimistaCustodian}", code)
		code += 1

    stylesheets << "{\\s#{code}\\widctlpar \\f1\\fs20 \\sbasedon0\\snext#{code} #{CCstylesheetArchimistaCreator};}"
		stylesheet_codes.store("#{CCstylesheetArchimistaCreator}", code)
		code += 1

    stylesheets << "{\\s#{code}\\widctlpar \\f1\\fs20 \\sbasedon0\\snext#{code} #{CCstylesheetArchimistaUnit};}"
		stylesheet_codes.store("#{CCstylesheetArchimistaUnit}", code)
		code += 1

    stylesheets << "{\\s#{code}\\widctlpar \\f1\\fs20 \\sbasedon0\\snext#{code} #{CCstylesheetUnitSequenceNumber};}"
		stylesheet_codes.store("#{CCstylesheetUnitSequenceNumber}", code)
		code += 1

    stylesheets << "{\\s#{code}\\widctlpar \\f1\\fs4 \\sbasedon0\\snext#{code} #{CCstylesheetSeparator};}"
		stylesheet_codes.store("#{CCstylesheetSeparator}", code)
		code += 1

    stylesheet_codes_key_prev = ""
		report_settings.entities.each do |ers|
			ers.available_attributes_info.each do |key, ai|
        stylesheet_codes_key = report_settings.make_attribute_rtf_stylesheet_codes_key(ers.entity_name.to_s, ai.name)
				
        if stylesheet_codes_key != stylesheet_codes_key_prev
          stylesheets << "{\\s#{code}\\widctlpar \\f0\\fs20\\lang1040 \\sbasedon0\\snext#{code} #{stylesheet_codes_key};}"
          stylesheet_codes.store("#{stylesheet_codes_key}", code)
          code = code + 1

          stylesheet_codes_key_prev = stylesheet_codes_key
        end
			end
		end
    return stylesheets, stylesheet_codes
  end

  def prv_write_projects_info(rw, report_settings, projects)
    prv_h2(rw, Project.model_name.human({:count => projects.size}))
    rw.writeNewLine
    projects.each do |project|
      prv_h3(rw, project.display_name, report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaProject))
      rw.writeNewLine
      make_rtf(rw, report_settings, :project, project)
    end
  end

  def prv_write_custodians_info(rw, report_settings, custodians)
    prv_h2(rw, Custodian.model_name.human({:count => custodians.size}))
    rw.writeNewLine
    custodians.each do |custodian|
      prv_h3(rw, custodian.display_name, report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaCustodian))
      rw.writeNewLine
      make_rtf(rw, report_settings, :custodian, custodian)
    end
  end

  def prv_write_creators_info(rw, report_settings, creators)
    prv_h2(rw, Creator.model_name.human({:count => creators.size}))
    rw.writeNewLine
    creators_sorted = creators.sort{|a,b| a.display_name <=> b.display_name}
    creators_sorted.each do |creator|
      prv_h3(rw, creator.display_name, report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaCreator))
      rw.writeNewLine
      make_rtf(rw, report_settings, :creator, creator)
    end
  end

  def prv_write_units_info(rw, report_settings, units, display_sequence_numbers, separator_styleindex)
    prv_h2(rw, Unit.model_name.human({:count => units.size}))
    rw.writeNewLine
    units.each do |u|
      rtf_print_field_value(rw, report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetUnitSequenceNumber), u.display_sequence_number_from_hash(display_sequence_numbers))
      rw.writeLineSeparator(separator_styleindex)
      prv_h3(rw, u.formatted_title, report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaUnit))
      rw.writeNewLine
      make_rtf(rw, report_settings, :unit, u)
    end
  end

  def prv_write_fond_and_units_info(rw, report_settings, fond, separator_styleindex)
    if fond.creators.present?
      rw.writeLineSeparator(separator_styleindex)
      prv_write_creators_info(rw, report_settings, fond.creators)
    end

    rw.writeLineSeparator(separator_styleindex)
    prv_h3(rw, fond.name, report_settings.get_attribute_rtf_stylesheet_code(CCstylesheetArchimistaFond))
    rw.writeNewLine
    make_rtf(rw, report_settings, :fond, fond)

    if fond.units.present?
      display_sequence_numbers = Unit.display_sequence_numbers_of(fond)

      rw.writeLineSeparator(separator_styleindex)
      prv_write_units_info(rw, report_settings, fond.units, display_sequence_numbers, separator_styleindex)
    end
  end

  def prv_write_fonds_info(rw, report_settings, fonds, separator_styleindex)
    prv_h2(rw, Fond.model_name.human({:count => fonds.size}))
    rw.writeNewLine   
    fonds.each do |fond|
      prv_write_fond_and_units_info(rw, report_settings, fond, separator_styleindex)
    end
  end
end

# Upgrade 2.0.0 fine
