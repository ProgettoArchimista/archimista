module ReportSupport
  
  HTMLUseUnorderedListTag = true
  RTFListItemTag = "- "

  def fond_available_attributes_info
    extend ApplicationHelper

    attributes_template = [
      # descrizione
      { :name => "fond_type", :is_default => true },
      { :name => "name" },
      { :name => "other_names.group", :name_tag => "other_names", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.other_names.present? then prv_html_rtf_other_names_callback(report_settings, entity_sym, ai.name_caption, entity_obj.other_names) else "" end } },
      { :name => "events.group", :name_tag => "date_event", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_events_callback(report_settings, entity_sym, entity_obj, ai) }, :is_default => true },
      { :name => "length", :is_default => true },
# Upgrade 2.2.0 inizio
# aggiunto name_tag
      { :name => "extent", :name_tag => "fond_extent", :is_default => true },
# Upgrade 2.2.0 fine
      { :name => "abstract", :is_default => true },
      { :name => "description", :is_default => true, :name_tag => "fond_description" },
      { :name => "history", :is_default => true },
      { :name => "arrangement_note", :is_default => true },
      # altre informazioni
      { :name => "fond_langs.code", :name_tag => "fond_langs", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.fond_langs.present? then prv_html_rtf_langs_callback(report_settings, entity_sym, ai.name_caption, entity_obj.fond_langs) else "" end } },
      { :name => "fond_owners.owner", :name_tag => "owners", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_fond_owners_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "related_materials", :is_default => true },
      { :name => "note", :is_default => true, :name_tag => "fond_note" },
      { :name => "fond_urls.group", :name_tag => "fond_urls", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.fond_urls.present? then prv_html_rtf_urls_callback(report_settings, entity_sym, ai.name_caption, entity_obj.fond_urls) else "" end } },
      { :name => "fond_identifiers.group", :name_tag => "fond_identifiers", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.fond_identifiers.present? then prv_html_rtf_identifiers_callback(report_settings, entity_sym, ai.name_caption, entity_obj.fond_identifiers) else "" end } },
      # accesso
      { :name => "access_condition", :is_default => true },
      { :name => "access_condition_note", :is_default => true },
      { :name => "use_condition", :is_default => true },
      { :name => "use_condition_note", :is_default => true },
      { :name => "preservation", :is_default => true },
      { :name => "preservation_note", :is_default => true },
      # relazioni
      { :name => "creators.group", :name_tag => "creators", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_creators_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "custodians.group", :name_tag => "custodians", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_custodians_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "projects.group", :name_tag => "projects", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.projects.present? then prv_html_rtf_projects_callback(report_settings, entity_sym, Project.model_name.human({:count => entity_obj.projects.size}), entity_obj.projects) else "" end } },
      { :name => "document_forms.group", :name_tag => "document_forms", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.document_forms.present? then prv_html_rtf_document_forms_callback(report_settings, entity_sym, DocumentForm.model_name.human({:count => entity_obj.document_forms.size}), entity_obj.document_forms) else "" end } },
      # fonti
      { :name => "sources.group", :name_tag => "sources_area", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_sources_callback(report_settings, entity_sym, entity_obj, ai) }, :is_default => true },
      # compilatori
      { :name => "fond_editors.group", :name_tag => "fond_editors", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.fond_editors.present? then prv_html_rtf_editors_callback(report_settings, entity_sym, ai.name_caption, entity_obj.fond_editors) else "" end } },
      # xxxx
      { :name => "units_count", :name_caption => "Numero unità archivistiche", :is_default => true }
    ]
    return prv_make_available_attributes_info(attributes_template)
  end
  
  def custodian_available_attributes_info
    attributes_template = [
      # identificazione
      { :name => "legal_status", :is_value_translation => true, :is_default => true },
      { :name => "custodian_type.custodian_type", :name_tag => "custodian_macro_type", :is_default => true },
      { :name => "preferred_name.group", :name_tag => "preferred_name", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_preferred_name_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "other_names.group", :name_tag => "other_names", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.other_names.present? then prv_html_rtf_other_names_callback(report_settings, entity_sym, ai.name_caption, entity_obj.other_names) else "" end } },
      { :name => "history", :name_tag => "custodian_history", :is_default => true },
      { :name => "custodian_contacts.group", :name_tag => "contacts", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_custodian_contacts_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "contact_person", :name_tag => "contact_person", :is_default => true },
      { :name => "owner", :name_tag => "custodian_owners", :is_default => true, :is_multi_instance => true },
      { :name => "custodian_urls.group", :name_tag => "custodian_urls", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.custodian_urls.present? then prv_html_rtf_urls_callback(report_settings, entity_sym, ai.name_caption, entity_obj.custodian_urls) else "" end } },
      { :name => "custodian_identifiers.group", :name_tag => "custodian_identifiers", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.custodian_identifiers.present? then prv_html_rtf_identifiers_callback(report_settings, entity_sym, ai.name_caption, entity_obj.custodian_identifiers) else "" end } },
      # descrizione
      { :name => "holdings", :is_default => true },
      { :name => "collecting_policies", :is_default => true },
      { :name => "administrative_structure", :is_default => true },
      # accesso
      { :name => "accessibility", :is_default => true },
      { :name => "services", :is_default => true },
      # sedi
      { :name => "custodian_headquarter.name", :group_caption => "Sede legale", :group_tag => "registered_office", :name_tag => "building_name" },
      { :name => "custodian_headquarter.custodian_building_type", :group_caption => "Sede legale", :group_tag => "registered_office", :name_tag => "building_type" },
      { :name => "custodian_headquarter.address", :group_caption => "Sede legale", :group_tag => "registered_office", :name_tag => "building_address" },
      { :name => "custodian_headquarter.city", :group_caption => "Sede legale", :group_tag => "registered_office", :name_tag => "city" },
      { :name => "custodian_headquarter.postcode", :group_caption => "Sede legale", :group_tag => "registered_office", :name_tag => "postcode" },
      { :name => "custodian_headquarter.country", :group_caption => "Sede legale", :group_tag => "registered_office", :name_tag => "country" },
      { :name => "custodian_headquarter.description", :group_caption => "Sede legale", :group_tag => "registered_office", :name_tag => "building_description" },
      # -----
      { :name => "custodian_other_buildings.name", :group_caption => "Altre sedi", :group_tag => "custodian_other_buildings", :name_tag => "building_name", :is_multi_instance => true },
      { :name => "custodian_other_buildings.custodian_building_type", :group_caption => "Altre sedi", :group_tag => "custodian_other_buildings", :name_tag => "building_type", :is_multi_instance => true },
      { :name => "custodian_other_buildings.address", :group_caption => "Altre sedi", :group_tag => "custodian_other_buildings", :name_tag => "building_address", :is_multi_instance => true },
      { :name => "custodian_other_buildings.city", :group_caption => "Altre sedi", :group_tag => "custodian_other_buildings", :name_tag => "city", :is_multi_instance => true },
      { :name => "custodian_other_buildings.postcode", :group_caption => "Altre sedi", :group_tag => "custodian_other_buildings", :name_tag => "postcode", :is_multi_instance => true },
      { :name => "custodian_other_buildings.country", :group_caption => "Altre sedi", :group_tag => "custodian_other_buildings", :name_tag => "country", :is_multi_instance => true },
      { :name => "custodian_other_buildings.description", :group_caption => "Altre sedi", :group_tag => "custodian_other_buildings", :name_tag => "building_description", :is_multi_instance => true },
      # relazioni
      { :name => "fonds.group", :name_tag => "fonds", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_fonds_callback(report_settings, entity_sym, entity_obj, ai) } },
      # fonti
      { :name => "sources.group", :name_tag => "sources_area", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_sources_callback(report_settings, entity_sym, entity_obj, ai) }, :is_default => true },
      # compilatori
      { :name => "custodian_editors.group", :name_tag => "custodian_editors", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.custodian_editors.present? then prv_html_rtf_editors_callback(report_settings, entity_sym, ai.name_caption, entity_obj.custodian_editors) else "" end } }
    ]
    return prv_make_available_attributes_info(attributes_template)
  end
  
  def creator_available_attributes_info
    attributes_template = [
      # identificazione
      { :name => "creator_type", :is_value_translation => true, :is_default => true },
      { :name => "creator_corporate_type.corporate_type", :name_tag => "creator_corporate_type", :is_default => true },
      { :name => "preferred_name.group", :name_tag => "preferred_name", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_preferred_name_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "other_names.group", :name_tag => "other_names", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.other_names.present? then prv_html_rtf_other_names_callback(report_settings, entity_sym, ai.name_caption, entity_obj.other_names) else "" end } },
      { :name => "events.group", :name_tag => "date_event", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_events_callback(report_settings, entity_sym, entity_obj, ai) }, :is_default => true },
      { :name => "creator_legal_statuses.group", :name_tag => "creator_legal_statuses", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_creator_legal_statuses_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "residence", :is_default => true },
      { :name => "creator_urls.group", :name_tag => "creator_urls", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.creator_urls.present? then prv_html_rtf_urls_callback(report_settings, entity_sym, ai.name_caption, entity_obj.creator_urls) else "" end } },
      { :name => "creator_identifiers.group", :name_tag => "creator_identifiers", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.creator_identifiers.present? then prv_html_rtf_identifiers_callback(report_settings, entity_sym, ai.name_caption, entity_obj.creator_identifiers) else "" end } },
      # descrizione
      { :name => "abstract", :is_default => true },
      { :name => "history", :name_tag => "creator_history", :is_default => true },
      { :name => "note", :name_tag => "creator_note", :is_default => true },
      { :name => "creator_activities.group", :name_tag => "creator_activities", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_creator_activities_callback(report_settings, entity_sym, entity_obj, ai) } },
      # relazioni
      { :name => "fonds.group", :name_tag => "fonds", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_fonds_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "institutions.group", :name_tag => "institutions", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_institutions_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "linked_creators.group", :name_tag => "linked_creators", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_linked_creators_callback(report_settings, entity_sym, entity_obj, ai) } },
      # fonti
      { :name => "sources.group", :name_tag => "sources_area", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_sources_callback(report_settings, entity_sym, entity_obj, ai) }, :is_default => true },
      # compilatori
      { :name => "creator_editors.group", :name_tag => "creator_editors", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.creator_editors.present? then prv_html_rtf_editors_callback(report_settings, entity_sym, ai.name_caption, entity_obj.creator_editors) else "" end } }
    ]
    return prv_make_available_attributes_info(attributes_template)
  end

  def unit_available_attributes_info
    attributes_template = [
      # descrizione
      { :name => "unit_type" },
# Upgrade 2.2.0 inizio
#      { :name => "title.group", :name_tag => "title", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_unit_title_callback(report_settings, entity_sym, entity_obj, ai) }	, :is_default => true },
      { :name => "title.group", :name_tag => "title", :name_caption_list_note => " (N.B.: viene inserito sempre come identificativo dell'unità)", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_unit_title_callback(report_settings, entity_sym, entity_obj, ai) } },
# Upgrade 2.2.0 fine
      { :name => "events.group", :name_tag => "date_event", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_events_callback(report_settings, entity_sym, entity_obj, ai) }, :is_default => true },
      { :name => "content", :is_default => true },
# Upgrade 2.2.0 inizio
      { :name => "extent", :name_tag => "unit_extent" },
# Upgrade 2.2.0 fine
      { :name => "tmp_reference_number", :is_default => true },
      { :name => "tmp_reference_string", :is_default => true },
      { :name => "folder_number" },
      { :name => "file_number" },
      { :name => "reference_number", :is_default => true },
      { :name => "arrangement_note" },
      # descrizione fisica
      { :name => "physical_type" },
      { :name => "medium" },
      { :name => "related_materials" },
      { :name => "physical_description" },
      { :name => "preservation", :is_default => true },
      { :name => "preservation_note", :is_default => true },
      { :name => "unit_damages.group", :name_tag => "unit_damages", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_unit_damages_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "restoration" },
      { :name => "note", :name_tag => "unit_note" },
      { :name => "physical_container.group", :name_tag => "physical_container", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_unit_physical_container_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "unit_other_reference_numbers.group", :name_tag => "unit_other_reference_numbers", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_unit_other_reference_numbers_callback(report_settings, entity_sym, entity_obj, ai) } },
      # accesso
      { :name => "unit_langs.code", :name_tag => "unit_langs", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.unit_langs.present? then prv_html_rtf_langs_callback(report_settings, entity_sym, ai.name_caption, entity_obj.unit_langs) else "" end } },
      { :name => "access_condition" },
      { :name => "access_condition_note" },
      { :name => "use_condition" },
      { :name => "use_condition_note" },
      { :name => "unit_urls.group", :name_tag => "unit_urls", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.unit_urls.present? then prv_html_rtf_urls_callback(report_settings, entity_sym, ai.name_caption, entity_obj.unit_urls) else "" end } },
      { :name => "unit_identifiers.group", :name_tag => "unit_identifiers", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.unit_identifiers.present? then prv_html_rtf_identifiers_callback(report_settings, entity_sym, ai.name_caption, entity_obj.unit_identifiers) else "" end } },
      # fonti
      { :name => "sources.group", :name_tag => "sources_area", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_sources_callback(report_settings, entity_sym, entity_obj, ai) }, :is_default => true },
      # compilatori
      { :name => "unit_editors.group", :name_tag => "unit_editors", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.unit_editors.present? then prv_html_rtf_editors_callback(report_settings, entity_sym, ai.name_caption, entity_obj.unit_editors) else "" end } },

# Upgrade 2.1.0 inizio
=begin
      # schede speciali - identificazione
      { :name => "tsk", :name_caption => "TSK (tipologia scheda)" },
      { :name => "iccd_description.ogtd", :name_caption => "OGTD/OGTT (definizione dell'oggetto)" },
      { :name => "iccd_description.ogts", :name_caption => "OGTS (forma specifica dell'oggetto)" },
      { :name => "iccd_description.esc", :name_caption => "ESC (ente schedatore)" },
      { :name => "iccd_subjects.group", :name_caption => "SGTI (identificazione)", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_unit_iccd_subjects_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "iccd_authors.group", :name_caption => "AU (autori)", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_unit_iccd_authors_callback(report_settings, entity_sym, entity_obj, ai) } },
      # schede speciali - descrizione - manca BDM.DESO
      { :name => "iccd_description.sgtd", :name_caption => "SGTD/DESS (indicazioni sul soggetto/descrizione del soggetto)" },
      # schede speciali - localizzazione
      { :name => "iccd_description.pvc", :name_caption => "PVCC / PVCP (Comune Provincia)" },
      { :name => "iccd_description.ldcn", :name_caption => "LDCN (Denominazione collocazione)" },
      { :name => "iccd_description.ldcu", :name_caption => "LDCU (Denominazione spazio viabilistico)" },
      { :name => "iccd_description.ldcm", :name_caption => "LDCM (Denominazione raccolta)" },
      # schede speciali - dati tecnici
      { :name => "iccd_tech_spec.misu", :name_caption => "MISU (unita' di misura)" },
      { :name => "iccd_tech_spec.misa", :name_caption => "MISA (altezza)" },
      { :name => "iccd_tech_spec.misl", :name_caption => "MISL (larghezza)" },
      { :name => "iccd_tech_spec.miss", :name_caption => "MISS (spessore)" },
      { :name => "iccd_tech_spec.mtx", :name_caption => "MTX (indicazione colore)" },
      { :name => "iccd_tech_spec.mtc", :name_caption => "MTC (materia e tecnica)" },
      { :name => "iccd_tech_spec.mtcm", :name_caption => "MTCM (materia)" },
      { :name => "iccd_tech_spec.mtct", :name_caption => "MTCT (tecnica)" },
      { :name => "iccd_damages.group", :name_caption => "STCS (stato di conservazione specifico)", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_unit_iccd_damages_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "iccd_description.utf", :name_caption => "UTF (funzione)" },
      { :name => "iccd_description.uto", :name_caption => "UTO (occasione)" }
=end

      # schede speciali - identificazione
      { :name => "sc2_tsk", :name_caption => "Scheda speciale" },
      { :name => "sc2_textual_elements.group", :name_tag => "sc2_textual_elements", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_sc2_textual_elements_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "sc2_visual_elements.group", :name_tag => "sc2_visual_elements", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_sc2_visual_elements_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "sc2.sgti", :name_caption => "Soggetto" },
      { :name => "sc2_authors.group", :name_tag => "sc2_authors", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_sc2_authors_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "sc2_commissions.group", :name_tag => "sc2_commissions", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_sc2_commissions_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "sc2.cmmr", :name_caption => "Numero di commessa" },
      { :name => "sc2.lrc", :name_caption => "Luogo della ripresa" },
      { :name => "sc2.lrd", :name_caption => "Data della ripresa" },
      { :name => "sc2_techniques.group", :name_tag => "sc2_techniques", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_sc2_techniques_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "sc2.mtce", :name_caption => "Esecuzione" },
      { :name => "sc2_scales.group", :name_tag => "sc2_scales", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_sc2_scales_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "sc2.sdtt", :name_caption => "Tipo di rappresentazione" },
      { :name => "sc2.sdts", :name_caption => "Rappresentazione tematica" },
      { :name => "sc2.dpgf", :name_caption => "Numero tavola" },
      { :name => "sc2.misa", :name_caption => "Altezza" },
      { :name => "sc2.misl", :name_caption => "Larghezza" },
      { :name => "sc2.ort", :name_caption => "Orientamento" }
# Upgrade 2.1.0 fine
    ]
    return prv_make_available_attributes_info(attributes_template)
  end

  def project_available_attributes_info
    attributes_template = [
      # identificazione
      { :name => "name" },
      { :name => "project_type", :is_default => true },
      { :name => "display_date", :is_default => true },
      { :name => "status" },
      { :name => "description", :is_default => true },
      { :name => "note", :name_tag => "project_note" },
      { :name => "project_urls.group", :name_tag => "project_urls", :callback => proc { |report_settings, entity_sym, entity_obj, ai| if entity_obj.project_urls.present? then prv_html_rtf_urls_callback(report_settings, entity_sym, ai.name_caption, entity_obj.project_urls) else "" end } },
      # responsabilità
      { :name => "project_managers.group", :name_tag => "project_managers", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_project_managers_callback(report_settings, entity_sym, entity_obj, ai) } },
      { :name => "project_stakeholders.group", :name_tag => "project_stakeholders", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_project_stakeholders_callback(report_settings, entity_sym, entity_obj, ai) } },    
      # relazioni
      { :name => "fonds.group", :name_tag => "fonds", :callback => proc { |report_settings, entity_sym, entity_obj, ai| prv_html_rtf_fonds_callback(report_settings, entity_sym, entity_obj, ai) } },
			
    ]
    return prv_make_available_attributes_info(attributes_template)
  end

  def make_html(report_settings, entity_sym, entity_obj)
    op_html = ""

    ers = report_settings.entity_search_by_name(entity_sym)
    if ers.has_any_selected_attributes?

      packed_selected_attribute_names = prv_pack_selected_attribute_names(ers)

      packed_selected_attribute_names.each do |packed_names_set|
        packed_names = packed_names_set.split('/')
        ref_attribute_name = packed_names[0]

        methods = ref_attribute_name.split('.')
        if ers.available_attributes_info[ref_attribute_name].is_multi_instance
          instances = entity_obj.send(methods[0].to_sym)
          if !instances.nil?
            op_html = op_html + "<div>"

            group_caption_printed = false

            instances.each_with_index do |instance, instance_index|
              instance_caption_printed = false
              for fld_index in 0 .. packed_names.length - 1
                methods = packed_names[fld_index].split('.')
                value = instance.send(methods[1].to_sym).to_s
                if !value.nil? && value != ""
                  ai = ers.available_attributes_info[packed_names[fld_index]]
                  if ai.callback.nil?
                    if !ers.dont_use_fld_captions
                      if !group_caption_printed && !ai.group_caption.nil?
                        op_html = op_html + prv_html_print_group_caption(ai, "")
                        op_html = op_html + prv_html_get_list_open_tag
                        group_caption_printed = true
                      end

                      caption_postfix = prv_make_caption_postfix(ai.group_tag, packed_names.length, instance_index, instances.length)
                      if !instance_caption_printed && !ai.group_caption.nil?
                        op_html = op_html + prv_html_get_list_item_open_tag
                        op_html = op_html + "<div>"

                        op_html = op_html + prv_html_print_group_caption(ai, caption_postfix)
                        instance_caption_printed = true
                      end
                      if instance_caption_printed then caption_postfix = "" end
                    else
                      caption_postfix = ""
                    end

                    text = instance.send(methods[1].to_sym).to_s
                    op_html = op_html + prv_html_print_field(ers.dont_use_fld_captions, ai, caption_postfix, text)
                  else
                    callback_html = ai.callback.call(report_settings, entity_sym, entity_obj, ai)
                    if !callback_html.nil?
                      op_html = op_html + callback_html
                    end
                  end
                end
              end
              if instance_caption_printed
                op_html = op_html + "</div>"
                op_html = op_html + prv_html_get_list_item_close_tag
              end
            end
            if group_caption_printed
              op_html = op_html + prv_html_get_list_close_tag
            end
          
            op_html = op_html + "</div>"
          end
        else
          ai = ers.available_attributes_info[ref_attribute_name]
          if ai.callback.nil?
            if entity_obj.send(methods[0].to_sym).present? && entity_obj.send(methods[0].to_sym) != 0
              if ref_attribute_name.include?('.')
                text = entity_obj.send(methods[0].to_sym).send(methods[1].to_sym).to_s
              else
                text = entity_obj.send(methods[0].to_sym).to_s
              end
              if !text.nil? && text != ""
                op_html = op_html + "<div>"
                op_html = op_html + prv_html_print_field(ers.dont_use_fld_captions, ai, "", text)
                op_html = op_html + "</div>"
              end
            end
          else
            callback_html = ai.callback.call(report_settings, entity_sym, entity_obj, ai)
            if !callback_html.nil? && callback_html != ""
              op_html = op_html + "<div>"
              op_html = op_html + callback_html
              op_html = op_html + "</div>"
            end
          end
        end

      end
    end
    return op_html
  end

  def make_rtf(rw, report_settings, entity_sym, entity_obj)
    ers = report_settings.entity_search_by_name(entity_sym)
    if ers.has_any_selected_attributes?

      packed_selected_attribute_names = prv_pack_selected_attribute_names(ers)

      packed_selected_attribute_names.each do |packed_names_set|
        packed_names = packed_names_set.split('/')
        ref_attribute_name = packed_names[0]

        methods = ref_attribute_name.split('.')
        if ers.available_attributes_info[ref_attribute_name].is_multi_instance
          instances = entity_obj.send(methods[0].to_sym)
          if !instances.nil?
#            op_rtf = op_rtf + "<div>"

            group_caption_printed = false

            instances.each_with_index do |instance, instance_index|
              instance_caption_printed = false
              for fld_index in 0 .. packed_names.length - 1
                methods = packed_names[fld_index].split('.')
                value = instance.send(methods[1].to_sym).to_s
                if !value.nil? && value != ""
                  ai = ers.available_attributes_info[packed_names[fld_index]]
                  if ai.callback.nil?
                    if !ers.dont_use_fld_captions
                      if !group_caption_printed && !ai.group_caption.nil?
                        prv_rtf_print_group_caption(rw, report_settings.rtf_stylesheet_code_archimista_label, ai, "")
#                        op_rtf = op_rtf + prv_rtf_get_list_open_tag
                        group_caption_printed = true
                      end

                      caption_postfix = prv_make_caption_postfix(ai.group_tag, packed_names.length, instance_index, instances.length)
                      if !instance_caption_printed && !ai.group_caption.nil?
#                        op_rtf = op_rtf + prv_rtf_get_list_item_open_tag
#                        op_rtf = op_rtf + "<div>"

                        prv_rtf_print_group_caption(rw, report_settings.rtf_stylesheet_code_archimista_label, ai, caption_postfix)
                        instance_caption_printed = true
                      end
                      if instance_caption_printed then caption_postfix = "" end
                    else
                      caption_postfix = ""
                    end

                    text = instance.send(methods[1].to_sym).to_s
                    stylesheet_codes_key = report_settings.make_attribute_rtf_stylesheet_codes_key(ers.entity_name.to_s, packed_names[fld_index])
                    prv_rtf_print_field(rw, report_settings.rtf_stylesheet_code_archimista_label, report_settings.get_attribute_rtf_stylesheet_code(stylesheet_codes_key), ers.entity_name, ers.dont_use_fld_captions, ai, caption_postfix, text)
                  else
                    ai.callback.call(report_settings, entity_sym, entity_obj, ai)
                  end
                end
              end
              if instance_caption_printed
#                op_rtf = op_rtf + "</div>"
#                op_rtf = op_rtf + prv_rtf_get_list_item_close_tag
              end
            end
            if group_caption_printed
 #             op_rtf = op_rtf + prv_rtf_get_list_close_tag
            end
          
 #           op_rtf = op_rtf + "</div>"
          end
        else
          ai = ers.available_attributes_info[ref_attribute_name]
          if ai.callback.nil?
            if entity_obj.send(methods[0].to_sym).present? && entity_obj.send(methods[0].to_sym) != 0
              if ref_attribute_name.include?('.')
                text = entity_obj.send(methods[0].to_sym).send(methods[1].to_sym).to_s
              else
                text = entity_obj.send(methods[0].to_sym).to_s
              end
              if !text.nil? && text != ""
                stylesheet_codes_key = report_settings.make_attribute_rtf_stylesheet_codes_key(ers.entity_name.to_s, ref_attribute_name)
                prv_rtf_print_field(rw, report_settings.rtf_stylesheet_code_archimista_label, report_settings.get_attribute_rtf_stylesheet_code(stylesheet_codes_key), ers.entity_name, ers.dont_use_fld_captions, ai, "", text)
              end
            end
          else
            ai.callback.call(report_settings, entity_sym, entity_obj, ai)
          end
        end

      end
    end
  end

# -------------------------------
  def rtf_print_field_caption(rw, rtf_stylesheet_index, caption)
    rw.writeParagraph(caption, rtf_stylesheet_index, nil, 10, GCrwFontBoldEnabled, nil, nil, GCrwTextAlignmentJustified, nil, nil, nil)
  end

  def rtf_print_field_value(rw, rtf_stylesheet_index, text)
    rw.writeParagraph(text, rtf_stylesheet_index, nil, 10, nil, nil, nil, GCrwTextAlignmentJustified, nil, nil, nil)
  end

private

# -------------------------------
  def prv_make_available_attributes_info(attributes_template)
    available_attributes_info = Hash.new()

    attributes_template.each do |attr_info|
      name = attr_info[:name]
      name_caption = attr_info[:name_caption]
# Upgrade 2.2.0 inizio
      name_caption_list_note = attr_info[:name_caption_list_note]
# Upgrade 2.2.0 fine
      group_tag = attr_info[:group_tag]
      group_caption = attr_info[:group_caption]
      name_tag = attr_info[:name_tag]
      is_value_translation = attr_info[:is_value_translation]
      is_default = attr_info[:is_default]
      is_multi_instance = attr_info[:is_multi_instance]
      callback = attr_info[:callback]

      if name_caption.nil?
        if name_tag.nil? then name_tag = name end
        name_caption = prv_translate(name_tag)
      end
      if group_caption.nil?
        if group_tag.nil?
          group_caption = nil
        else
          group_caption = prv_translate(group_tag)
        end
      end

      if is_value_translation.nil? then is_value_translation = false end
      if is_default.nil? then is_default = false end
      if is_multi_instance.nil? then is_multi_instance = false end

# Upgrade 2.2.0 inizio
#      ai = AttributeInfo.new(name, group_tag, name_caption, group_caption, is_value_translation, is_default, is_multi_instance, callback)
      ai = AttributeInfo.new(name, group_tag, name_caption, group_caption, name_caption_list_note, is_value_translation, is_default, is_multi_instance, callback)
# Upgrade 2.2.0 fine
      available_attributes_info[name] = ai
    end
    return available_attributes_info
  end

# -------------------------------
  def prv_pack_selected_attribute_names(ers)
    packed_selected_attribute_names = []
    attribute_index_current = -1
    for attribute_index in 0 .. (ers.selected_attribute_names.length - 1)
      attribute_name = ers.selected_attribute_names[attribute_index]
      if attribute_index > attribute_index_current
        methods = attribute_name.split('.')
        if ers.available_attributes_info[attribute_name].is_multi_instance
          if ers.available_attributes_info[attribute_name].group_tag.nil?
            packed_selected_attribute_names << attribute_name
            attribute_index_current = attribute_index
          else
            attribute_index_current = attribute_index
            group_tag = ers.available_attributes_info[attribute_name].group_tag
            packed_names_set = ""
            for i in attribute_index .. (ers.selected_attribute_names.length - 1)
              tgt_attribute_name = ers.selected_attribute_names[i]
              if group_tag == ers.available_attributes_info[tgt_attribute_name].group_tag
                if packed_names_set != "" then packed_names_set = packed_names_set + "/" end
                packed_names_set = packed_names_set + tgt_attribute_name
                attribute_index_current = i
              else
                break
              end
            end
            packed_selected_attribute_names << packed_names_set
          end
        else
          packed_selected_attribute_names << attribute_name
          attribute_index_current = attribute_index
        end
      end
    end
    return packed_selected_attribute_names
  end

# -------------------------------
  def prv_make_caption_postfix(group_tag, group_items_count, instance_index, instance_count)
    if group_tag.nil?
      if group_items_count > 1
        caption_postfix = " [" + (instance_index + 1).to_s + "/" + instance_count.to_s + "]"
      else
        caption_postfix = ""
      end
    else
      caption_postfix = " [" + (instance_index + 1).to_s + "/" + instance_count.to_s + "]"
    end
    return caption_postfix
  end

# -------------------------------
  def prv_vocabulary_remap(is_html, vocabulary_spec, ip_value, is_value_translation)
    op_value = ip_value
    rec = Term.for_select_options.select {|v| v.vocabulary_name == "#{vocabulary_spec}"} .select {|a| a.term_value == "#{op_value}"}
    if !rec.nil?
      op_value = rec[0].term_key.to_s
      if is_value_translation
        if is_html
          op_value = t(op_value).to_s
        else
          op_value = prv_translate(op_value)
        end
      end
    end
    return op_value
  end

# -------------------------------
  def prv_lang_remap(is_html, lang_code, op_lang_spec, is_value_translation)
    op_value = lang_code
    rec = Lang.where(:code => "#{lang_code}")
    if !rec.nil?
      op_value = rec[0].send(op_lang_spec).to_s
      if is_value_translation
        if is_html
          op_value = t(op_value).to_s
        else
          op_value = prv_translate(op_value)
        end
      end
    end
    return op_value
  end
  
# -------------------------------
  def prv_html_print_group_caption(ai, caption_postfix)
    op_html = "<p class=\"fldcaption\">"
    op_html = op_html + "<strong class=\"field-header\">" + ai.group_caption + caption_postfix + "</strong>"
    op_html = op_html + "</p>"
    return op_html
  end
  
  def prv_rtf_print_group_caption(rw, rtf_stylesheet_index, ai, caption_postfix)
    rw.writeParagraph(ai.group_caption + caption_postfix, rtf_stylesheet_index, nil, nil, GCrwFontBoldEnabled, nil, nil, GCrwTextAlignmentJustified, nil, nil, nil)
  end

# -------------------------------
  def prv_html_print_field(dont_use_fld_captions, ai, caption_postfix, text)
    if ai.is_value_translation then text = t(text) end

    op_html = ""
    if !dont_use_fld_captions
      op_html = op_html + "<p class=\"fldcaption\">"
      op_html = op_html + "<strong class=\"field-header\">" + ai.name_caption + caption_postfix + "</strong>"
      op_html = op_html + "</p>"
    end
    op_html = op_html + textilize_with_entities(text)
    return op_html
  end

  def prv_rtf_print_field(rw, rtf_caption_stylesheet_index, rtf_value_stylesheet_index, entity_name, dont_use_fld_captions, ai, caption_postfix, text)
    if ai.is_value_translation then
      text = prv_translate(text)
    end

    if !dont_use_fld_captions
      rtf_print_field_caption(rw, rtf_caption_stylesheet_index, ai.name_caption + caption_postfix)
    end
    rtf_print_field_value(rw, rtf_value_stylesheet_index, text)
    rw.writeNewLine(nil, nil, 8)
  end

# -------------------------------
  def prv_translate(ip_tag)
    return I18n.translate(ip_tag)
  end

  def prv_localize(*args)
    return I18n.localize(*args)
  end

# -------------------------------
  def prv_html_get_list_open_tag
    if HTMLUseUnorderedListTag
      op_html = "<ul>"
    else
      op_html = ""
    end
    return op_html
  end
  def prv_html_get_list_close_tag
    if HTMLUseUnorderedListTag
      op_html = "</ul>"
    else
      op_html = ""
    end
    return op_html
  end
  def prv_html_get_list_item_open_tag
    if HTMLUseUnorderedListTag
      op_html = "<li>"
    else
      op_html = "<p>"
    end
    return op_html
  end
  def prv_html_get_list_item_close_tag
    if HTMLUseUnorderedListTag
      op_html = "</li>"
    else
      op_html = "</p>"
    end
    return op_html
  end

# -------------------------------
# Upgrade 2.2.0 inizio
=begin
  def prv_html_rtf_items_concat(report_settings, ers, caption, rtf_stylesheet_key, items, fld_names, separator, fld_prefixes, fld_postfixes, fld_value_transformations)
    op_html = ""
    if !items.nil?
      is_html = report_settings.rtf_rw.nil?

      if !ers.dont_use_fld_captions
        if !caption.nil?
          if is_html
            op_html = op_html + "<p class=\"fldcaption\">"
            op_html = op_html + "<strong class=\"field-header\">" + caption + "</strong>"
            op_html = op_html + "</p>"
          else
            rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, caption)
          end
        end
      end

      if is_html
        op_html = op_html + prv_html_get_list_open_tag
      end

      items.each do |item_info|
        if !item_info.send(fld_names[0].to_sym).nil?
          wrk_value = ""
          for i in 0 .. fld_names.length - 1
            if item_info.respond_to?(fld_names[i].to_sym)
              value = item_info.send(fld_names[i].to_sym)
              if !value.nil? && value != ""
                if !separator.nil? && wrk_value != "" then wrk_value = wrk_value + separator end             
                if fld_value_transformations[i] != ""
                  transform_info = fld_value_transformations[i].split("/")
                  case transform_info[0]
                    when "translate"
                      value = prv_translate(value)
                    when "dateLongFormat"
                      value = prv_localize(value, :format => :long)
                    when "vocRemap"
                      value = prv_vocabulary_remap(is_html, transform_info[1], value, false)
                    when "vocRemapAndTranslate"
                      value = prv_vocabulary_remap(is_html, transform_info[1], value, true)
                    when "langRemap"
                      value = prv_lang_remap(is_html, value, "#{I18n.locale}_name".to_sym, false)
                    when "langRemapAndTranslate"
                      value = prv_lang_remap(is_html, value, "#{I18n.locale}_name".to_sym, true)
                  end
                end
                wrk_value = wrk_value + fld_prefixes[i] + value.to_s + fld_postfixes[i]
              end
            end
          end

          if is_html
            op_html = op_html + prv_html_get_list_item_open_tag + wrk_value + prv_html_get_list_item_close_tag
          else
            rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)
            rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, RTFListItemTag + wrk_value)
          end
        end
      end
      if is_html
        op_html = op_html + prv_html_get_list_close_tag        
      else
        report_settings.rtf_rw.writeNewLine(nil, nil, 8)
      end

      if is_html
        return op_html
      else
        return ""
      end
    else
      return ""
    end
  end
=end
  def prv_html_rtf_items_concat(report_settings, ers, caption, rtf_stylesheet_key, items, fld_names, separator, fld_prefixes, fld_postfixes, fld_value_transformations)
    settings =
    {
      :l1_fld_names => fld_names,
      :l1_fld_separator => separator,
      :l1_fld_prefixes => fld_prefixes,
      :l1_fld_postfixes => fld_postfixes,
      :l1_fld_value_transformations => fld_value_transformations,
      :l1_item_key_fldname => "id",
    
      :l2_caption => "",
      :l2_fld_names => [],
      :l2_fld_separator => [],
      :l2_fld_prefixes => [],
      :l2_fld_postfixes => [],
      :l2_fld_value_transformations => [],
      :l2_foreign_key_fldname => "",
      :l2_inst_separator => "",
      
      :l1vsl2_separator => "",
      :l2_position => ""
    }     
    op_html = prv_html_rtf_items_concat_with_subtable(report_settings, ers, caption, rtf_stylesheet_key, items, nil, settings)
    return op_html
  end

  def prv_html_rtf_items_concat_with_subtable(report_settings, ers, caption, rtf_stylesheet_key, l1_items, l2_items, settings)
    l1_fld_names = settings[:l1_fld_names]; if l1_fld_names.nil? then l1_fld_names = [] end
    l1_fld_separator = settings[:l1_fld_separator]; if l1_fld_separator.nil? then l1_fld_separator = "" end
    l1_fld_prefixes = settings[:l1_fld_prefixes]; if l1_fld_prefixes.nil? then l1_fld_prefixes = [] end
    l1_fld_postfixes = settings[:l1_fld_postfixes]; if l1_fld_postfixes.nil? then l1_fld_postfixes = [] end
    l1_fld_value_transformations = settings[:l1_fld_value_transformations]; if l1_fld_value_transformations.nil? then l1_fld_value_transformations = [] end
    l1_item_key_fldname = settings[:l1_item_key_fldname]; if l1_item_key_fldname.nil? then l1_item_key_fldname = "" end
  
    l2_caption = settings[:l2_caption]; if l2_caption.nil? then l2_caption = "" end
    l2_fld_names = settings[:l2_fld_names]; if l2_fld_names.nil? then l2_fld_names = [] end
    l2_fld_separator = settings[:l2_fld_separator]; if l2_fld_separator.nil? then l2_fld_separator = "" end
    l2_fld_prefixes = settings[:l2_fld_prefixes]; if l2_fld_prefixes.nil? then l2_fld_prefixes = [] end
    l2_fld_postfixes = settings[:l2_fld_postfixes]; if l2_fld_postfixes.nil? then l2_fld_postfixes = [] end
    l2_fld_value_transformations = settings[:l2_fld_value_transformations]; if l2_fld_value_transformations.nil? then l2_fld_value_transformations = [] end
    l2_foreign_key_fldname = settings[:l2_foreign_key_fldname]; if l2_foreign_key_fldname.nil? then l2_foreign_key_fldname = "" end
    l2_inst_separator = settings[:l2_inst_separator]; if l2_inst_separator.nil? then l2_inst_separator = "" end
    
    l1vsl2_separator = settings[:l1vsl2_separator]; if l1vsl2_separator.nil? then l1vsl2_separator = "" end
    l2_position = settings[:l2_position]; if l2_position.nil? then l2_position = "" end

    op_html = ""
    if !l1_items.nil?
      is_html = report_settings.rtf_rw.nil?

      if !ers.dont_use_fld_captions
        if !caption.nil?
          if is_html
            op_html = op_html + "<p class=\"fldcaption\">"
            op_html = op_html + "<strong class=\"field-header\">" + caption + "</strong>"
            op_html = op_html + "</p>"
          else
            rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, caption)
          end
        end
      end

      if is_html
        op_html = op_html + prv_html_get_list_open_tag
      end

      l1_items.each do |l1_item|
        if !l1_item.send(l1_fld_names[0].to_sym).nil?      
          l1_item_value = prv_html_rtf_fld_values_concat(is_html, l1_item, l1_fld_names, l1_fld_separator, l1_fld_prefixes, l1_fld_postfixes, l1_fld_value_transformations)

          l2_items_value = ""
          if !l2_items.nil? then
            l1_id = l1_item.send(l1_item_key_fldname.to_sym)

            l2_items.each do |l2_item|
              l2_id = l2_item.send(l2_foreign_key_fldname.to_sym)
              if (l2_id == l1_id)
                l2_item_value = prv_html_rtf_fld_values_concat(is_html, l2_item, l2_fld_names, l2_fld_separator, l2_fld_prefixes, l2_fld_postfixes, l2_fld_value_transformations)
                if (l2_item_value != "")
                  if !l2_inst_separator.nil? && l2_items_value != "" then l2_items_value = l2_items_value + l2_inst_separator end
                  l2_items_value = l2_items_value + l2_item_value
                end
              end
            end
            if (l2_items_value != "" && l2_caption != "")
              l2_items_value = l2_caption + l2_items_value
            end
          end
          if (l2_items_value != "")
            if (l1_item_value != "")
              case l2_position
                when "before"
                  l1_item_value = l2_items_value + l1vsl2_separator + l1_item_value
                when "after"
                  l1_item_value = l1_item_value + l1vsl2_separator + l2_items_value
              end
            else
              l1_item_value = l2_items_value
            end
          end
          
          if is_html
            op_html = op_html + prv_html_get_list_item_open_tag + l1_item_value + prv_html_get_list_item_close_tag
          else
            rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)
            rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, RTFListItemTag + l1_item_value)
          end
        end
      end
      if is_html
        op_html = op_html + prv_html_get_list_close_tag        
      else
        report_settings.rtf_rw.writeNewLine(nil, nil, 8)
      end

      if is_html
        return op_html
      else
        return ""
      end
    else
      return ""
    end
  end
  
  def prv_html_rtf_fld_values_concat(is_html, item, fld_names, fld_separator, fld_prefixes, fld_postfixes, fld_value_transformations)
    item_value = ""
    for i in 0 .. fld_names.length - 1
      if item.respond_to?(fld_names[i].to_sym)
        value = item.send(fld_names[i].to_sym)
        if !value.nil? && value != ""
          if !fld_separator.nil? && item_value != "" then item_value = item_value + fld_separator end         
          if fld_value_transformations[i] != ""
            transform_info = fld_value_transformations[i].split("/")
            case transform_info[0]
              when "translate"
                value = prv_translate(value)
              when "dateLongFormat"
                value = prv_localize(value, :format => :long)
              when "vocRemap"
                value = prv_vocabulary_remap(is_html, transform_info[1], value, false)
              when "vocRemapAndTranslate"
                value = prv_vocabulary_remap(is_html, transform_info[1], value, true)
              when "langRemap"
                value = prv_lang_remap(is_html, value, "#{I18n.locale}_name".to_sym, false)
              when "langRemapAndTranslate"
                value = prv_lang_remap(is_html, value, "#{I18n.locale}_name".to_sym, true)
            end
          end
          item_value = item_value + fld_prefixes[i] + value.to_s + fld_postfixes[i]
        end
      end
    end
    return item_value
  end
# Upgrade 2.2.0 fine

# -------------------------------
  def prv_html_rtf_other_names_callback(report_settings, entity_sym, caption, other_names)
    ers = report_settings.entity_search_by_name(entity_sym)
    rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "other_names")
    case ers.entity_name.to_s
      when "fond"
        op_html = prv_html_rtf_items_concat(report_settings, ers, caption, rtf_stylesheet_key, other_names, ["name", "note"], " ", ["", "["], ["", "]"], ["", ""])
      else
        op_html = prv_html_rtf_items_concat(report_settings, ers, caption, rtf_stylesheet_key, other_names, ["name", "qualifier", "note"], " ", ["", "(", "["], ["", ")", "]"], ["", "translate", ""])
    end
    return op_html
  end
  
# -------------------------------
  def prv_html_rtf_langs_callback(report_settings, entity_sym, caption, langs)
    ers = report_settings.entity_search_by_name(entity_sym)
    rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, entity_sym.to_s + "_langs")
    op_html = prv_html_rtf_items_concat(report_settings, ers, caption, rtf_stylesheet_key, langs, ["code"], " ", [""], [""], ["langRemap"])
    return op_html
  end
  
# -------------------------------
  def prv_html_rtf_urls_callback(report_settings, entity_sym, caption, urls)
    ers = report_settings.entity_search_by_name(entity_sym)
    rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, entity_sym.to_s + "_urls")
    op_html = prv_html_rtf_items_concat(report_settings, ers, caption, rtf_stylesheet_key, urls, ["url", "note"], " ", ["", "["], ["", "]"], ["", ""])
    return op_html
  end

# -------------------------------
  def prv_html_rtf_identifiers_callback(report_settings, entity_sym, caption, identifiers)
    ers = report_settings.entity_search_by_name(entity_sym)
    rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, entity_sym.to_s + "_identifiers")
    op_html = prv_html_rtf_items_concat(report_settings, ers, caption, rtf_stylesheet_key, identifiers, ["identifier", "identifier_source", "note"], " ", ["", "(", "["], ["", ")", "]"], ["", "", ""])
    return op_html
  end

# -------------------------------
  def prv_html_rtf_editors_callback(report_settings, entity_sym, caption, editors)
    ers = report_settings.entity_search_by_name(entity_sym)
    rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, entity_sym.to_s + "_editors")
    op_html = prv_html_rtf_items_concat(report_settings, ers, caption, rtf_stylesheet_key, editors, ["name", "qualifier", "editing_type", "edited_at"], "", ["", " (", ", ", ", "], ["", ")", "", ""], ["", "", "", "dateLongFormat"])
    return op_html
  end

# -------------------------------
  def prv_html_rtf_sources_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.sources.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      if report_settings.rtf_rw.nil?
        op_html = ""
        if !ers.dont_use_fld_captions
          op_html = op_html + "<p class=\"fldcaption\">"
          op_html = op_html + "<strong class=\"field-header\">" + Source.model_name.human({:count => entity_obj.sources.size}) + "</strong>"
          op_html = op_html + "</p>"
        end

        op_html = op_html + prv_html_get_list_open_tag
        entity_obj.sources.each do |source|
          op_html = op_html + prv_html_get_list_item_open_tag
          op_html = op_html + "[<em>" + source.short_title + "</em>]"
          op_html = op_html + " " + formatted_source(source, false, false)
          op_html = op_html + prv_html_get_list_item_close_tag
        end
        op_html = op_html + prv_html_get_list_close_tag
        return op_html
      else
        if !ers.dont_use_fld_captions
          rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, Source.model_name.human({:count => entity_obj.sources.size}))
        end

        rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "sources")
        rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)

        entity_obj.sources.each do |source|
          s = formatted_source(source, false, true)
          s = s.gsub("<em>", "\\i" + GCrwFontItalicEnabled.to_s + " ")
          s = s.gsub("</em>", "\\i" + GCrwFontItalicDisabled.to_s + " ")

          report_settings.rtf_rw.writeText("[", rtf_stylesheet_index, nil, 10, nil, nil, nil, GCrwTextAlignmentJustified, nil, nil, nil)
          report_settings.rtf_rw.writeText(source.short_title, nil, nil, 10, nil, GCrwFontItalicEnabled, nil, nil, nil, nil, nil)
          report_settings.rtf_rw.writeText("]", nil, nil, 10, nil, nil, nil, nil, nil, nil, nil)
          report_settings.rtf_rw.writeParagraph(" " + s, nil, nil, 10, nil, nil, nil, nil, nil, nil, nil)
          report_settings.rtf_rw.writeNewLine(nil, nil, 8)
        end

        return ""
      end
    else
      return ""
    end
  end

# -------------------------------
  def prv_html_rtf_events_callback(report_settings, entity_sym, entity_obj, ai)
    if report_settings.rtf_rw.nil?
      op_html = ""
      if entity_obj.events.present?
        ers = report_settings.entity_search_by_name(entity_sym)
        if !ers.dont_use_fld_captions
          op_html = op_html + "<p class=\"fldcaption\">"
          op_html = op_html + "<strong class=\"field-header\">" + ai.name_caption + "</strong>"
          op_html = op_html + "</p>"
        end

        entity_obj.events.each do |event|
          op_html = op_html + event.full_display_date_with_place
          if !event.note.nil? && event.note != ""
            op_html = op_html + " [" + event.note + "]"
          end
        end
      end
      return op_html
    else
      if entity_obj.events.present?
        ers = report_settings.entity_search_by_name(entity_sym)
        if !ers.dont_use_fld_captions
          rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, ai.name_caption)
        end

        rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "events")
        rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)

        entity_obj.events.each do |event|
          s = event.full_display_date_with_place
          if !event.note.nil? && event.note != ""
            s = s + " [" + event.note + "]"
          end
          rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, s)
        end
        report_settings.rtf_rw.writeNewLine(nil, nil, 8)
      end
      return ""
    end
  end

# -------------------------------
  def prv_html_rtf_fond_owners_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.fond_owners.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "fond_owners")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.fond_owners, ["owner"], " ", [""], [""], [""])
    else
      op_html = ""
    end
    return op_html
  end

# -------------------------------
  def prv_html_rtf_creators_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.creators.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      if report_settings.rtf_rw.nil?
        op_html = ""
        if !ers.dont_use_fld_captions
          op_html = op_html + "<p class=\"fldcaption\">"
          op_html = op_html + "<strong class=\"field-header\">" + Creator.model_name.human({:count => entity_obj.creators.size}) + "</strong>"
          op_html = op_html + "</p>"
        end

        op_html = op_html + prv_html_get_list_open_tag
        entity_obj.creators.each do |creator|
          op_html = op_html + prv_html_get_list_item_open_tag
          op_html = op_html + creator.preferred_name.name
					if creator.preferred_event
						op_html = op_html + " " + creator.preferred_event.full_display_date.to_s
					end
          op_html = op_html + prv_html_get_list_item_close_tag
        end
        op_html = op_html + prv_html_get_list_close_tag
        return op_html
      else
        if !ers.dont_use_fld_captions
          rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, Creator.model_name.human({:count => entity_obj.creators.size}))
        end

        rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "creators")
        rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)

        entity_obj.creators.each do |creator|
          s = creator.preferred_name.name
					if creator.preferred_event
						s = s + " " + creator.preferred_event.full_display_date.to_s
					end
          rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, RTFListItemTag + s)
        end
        report_settings.rtf_rw.writeNewLine(nil, nil, 8)

        return ""
      end
    else
      return ""
    end
  end

# -------------------------------
  def prv_html_rtf_fonds_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.fonds.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      if report_settings.rtf_rw.nil?
        op_html = ""
        if !ers.dont_use_fld_captions
          op_html = op_html + "<p class=\"fldcaption\">"
          op_html = op_html + "<strong class=\"field-header\">" + Fond.model_name.human({:count => entity_obj.fonds.size}) + "</strong>"
          op_html = op_html + "</p>"
        end

        op_html = op_html + prv_html_get_list_open_tag
        entity_obj.fonds.each do |fond|
          op_html = op_html + prv_html_get_list_item_open_tag
          op_html = op_html + fond.name
					if fond.preferred_event
						op_html = op_html + " " + fond.preferred_event.full_display_date.to_s
					end
          op_html = op_html + prv_html_get_list_item_close_tag
        end
        op_html = op_html + prv_html_get_list_close_tag
        return op_html
      else
        if !ers.dont_use_fld_captions
          rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, Fond.model_name.human({:count => entity_obj.fonds.size}))
        end

        rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "fonds")
        rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)

        entity_obj.fonds.each do |fond|
          s = fond.name
					if fond.preferred_event
						s = s + " " + fond.preferred_event.full_display_date.to_s
					end
          rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, RTFListItemTag + s)
        end
        report_settings.rtf_rw.writeNewLine(nil, nil, 8)

        return ""
      end
    else
      return ""
    end
  end

# -------------------------------
  def prv_html_rtf_custodians_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.custodians.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      if report_settings.rtf_rw.nil?
        op_html = ""
        if !ers.dont_use_fld_captions
          op_html = op_html + "<p class=\"fldcaption\">"
          op_html = op_html + "<strong class=\"field-header\">" + Custodian.model_name.human({:count => entity_obj.custodians.size}) + "</strong>"
          op_html = op_html + "</p>"
        end

        op_html = op_html + prv_html_get_list_open_tag
        entity_obj.custodians.each do |custodian|
          op_html = op_html + prv_html_get_list_item_open_tag
          op_html = op_html + custodian.preferred_name.name
          op_html = op_html + prv_html_get_list_item_close_tag
        end
        op_html = op_html + prv_html_get_list_close_tag
        return op_html
      else
        if !ers.dont_use_fld_captions
          rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, Custodian.model_name.human({:count => entity_obj.custodians.size}))
        end

        rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "custodians")
        rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)

        entity_obj.custodians.each do |custodian|
          rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, RTFListItemTag + custodian.preferred_name.name)
        end
        report_settings.rtf_rw.writeNewLine(nil, nil, 8)

        return ""
      end
    else
      return ""
    end
  end

# -------------------------------
  def prv_html_rtf_projects_callback(report_settings, entity_sym, caption, projects)
    ers = report_settings.entity_search_by_name(entity_sym)
    rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "projects")
    op_html = prv_html_rtf_items_concat(report_settings, ers, caption, rtf_stylesheet_key, projects, ["name", "display_date"], " ", ["", ""], ["", ""], ["", ""])
    return op_html
  end

# -------------------------------
  def prv_html_rtf_document_forms_callback(report_settings, entity_sym, caption, document_forms)
    ers = report_settings.entity_search_by_name(entity_sym)
    rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "document_forms")
    op_html = prv_html_rtf_items_concat(report_settings, ers, caption, rtf_stylesheet_key, document_forms, ["name"], " ", [""], [""], [""])
    return op_html
  end
	
# -------------------------------
  def prv_html_rtf_preferred_name_callback(report_settings, entity_sym, entity_obj, ai)
		value = entity_obj.preferred_name.name
		if !entity_obj.preferred_name.note.nil? && entity_obj.preferred_name.note != ""
			value = value + " [" + entity_obj.preferred_name.note + "]"
		end

		ers = report_settings.entity_search_by_name(entity_sym)
		if report_settings.rtf_rw.nil?
			op_html = ""
			if !ers.dont_use_fld_captions
				op_html = op_html + "<p class=\"fldcaption\">"
				op_html = op_html + "<strong class=\"field-header\">" + t("preferred_name") + "</strong>"
				op_html = op_html + "</p>"
			end
			op_html = op_html + "<p>"
			op_html = op_html + value
			op_html = op_html + "</p>"
			return op_html
		else
			if !ers.dont_use_fld_captions
				rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, prv_translate("preferred_name"))
			end
			rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "preferred_name")
			rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)

			rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, value)
			report_settings.rtf_rw.writeNewLine(nil, nil, 8)
			return ""
		end
  end

  def prv_html_rtf_custodian_contacts_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.custodian_contacts.present?
      contacts = Array.new
      entity_obj.custodian_contacts.each do |contact|
        contacts.push("#{Custodian.human_attribute_name(contact.contact_type)}: #{contact.contact}")
      end
      value = contacts.join(', ')

      ers = report_settings.entity_search_by_name(entity_sym)
      if report_settings.rtf_rw.nil?
        op_html = ""
        if !ers.dont_use_fld_captions
          op_html = op_html + "<p class=\"fldcaption\">"
          op_html = op_html + "<strong class=\"field-header\">" + t("contacts") + "</strong>"
          op_html = op_html + "</p>"
        end
        op_html = op_html + "<p>"
        op_html = op_html + value
        op_html = op_html + "</p>"
        return op_html
      else
        if !ers.dont_use_fld_captions
          rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, prv_translate("contacts"))
        end
        rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "custodian_contacts")
        rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)

        rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, value)
        report_settings.rtf_rw.writeNewLine(nil, nil, 8)
        return ""
      end
    else
      return ""
    end
  end

# -------------------------------
  def prv_html_rtf_creator_legal_statuses_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.creator_legal_statuses.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "creator_legal_statuses")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.creator_legal_statuses, ["legal_status", "note"], " ", ["", "["], ["", "]"], ["vocRemapAndTranslate/creator_legal_statuses.legal_status", ""])
    else
      op_html = ""
    end
    return op_html
  end

# -------------------------------
  def prv_html_rtf_creator_activities_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.creator_activities.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "creator_activities")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.creator_activities, ["activity", "note"], " ", ["", "["], ["", "]"], ["", ""])
    else
      op_html = ""
    end
    return op_html
  end

# -------------------------------
  def prv_html_rtf_institutions_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.institutions.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "institutions")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.institutions, ["name"], " ", [""], [""], [""])
    else
      op_html = ""
    end
    return op_html
  end

# -------------------------------
  def prv_html_rtf_linked_creators_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.rel_creator_creators.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      if report_settings.rtf_rw.nil?
        op_html = ""
        if !ers.dont_use_fld_captions
          op_html = op_html + "<p class=\"fldcaption\">"
          op_html = op_html + "<strong class=\"field-header\">" + ai.name_caption + "</strong>"
          op_html = op_html + "</p>"
        end

        op_html = op_html + prv_html_get_list_open_tag
        entity_obj.rel_creator_creators.each do |rel|
          op_html = op_html + prv_html_get_list_item_open_tag
          op_html = op_html + "(" + (rel.creator_association_type ? rel.creator_association_type.association_type : "legacy data: qualifica non presente") + ")"
          op_html = op_html + " " + rel.related_creator.preferred_name.name
					if rel.related_creator.preferred_event
						op_html = op_html + " " + rel.related_creator.preferred_event.full_display_date.to_s
					end
          op_html = op_html + prv_html_get_list_item_close_tag
        end
        op_html = op_html + prv_html_get_list_close_tag
        return op_html
      else
        if !ers.dont_use_fld_captions
          rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, ai.name_caption)
        end

        rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "fonds")
        rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)

        entity_obj.rel_creator_creators.each do |rel|
          s = "(" + (rel.creator_association_type ? rel.creator_association_type.association_type : "legacy data: qualifica non presente") + ")"
          s = s + " " + rel.related_creator.preferred_name.name
					if rel.related_creator.preferred_event
						s = s + " " + rel.related_creator.preferred_event.full_display_date.to_s
					end
          rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, RTFListItemTag + s)
        end
        report_settings.rtf_rw.writeNewLine(nil, nil, 8)

        return ""
      end
    else
      return ""
    end

  end

# -------------------------------
  def prv_html_rtf_unit_title_callback(report_settings, entity_sym, entity_obj, ai)
    value = entity_obj.title
    if entity_obj.given_title
      value = value + " [attribuito]"
    end

    ers = report_settings.entity_search_by_name(entity_sym)
    if report_settings.rtf_rw.nil?
      op_html = ""
      if !ers.dont_use_fld_captions
        op_html = op_html + "<p class=\"fldcaption\">"
        op_html = op_html + "<strong class=\"field-header\">" + ai.name_caption + "</strong>"
        op_html = op_html + "</p>"
      end
      op_html = op_html + "<p>"
      op_html = op_html + value
      op_html = op_html + "</p>"
      return op_html
    else
      if !ers.dont_use_fld_captions
        rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, ai.name_caption)
      end
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "title")
      rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)

      rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, value)
      report_settings.rtf_rw.writeNewLine(nil, nil, 8)

      return ""
    end
  end

# -------------------------------
  def prv_html_rtf_unit_damages_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.unit_damages.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "unit_damages")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.unit_damages, ["code"], " ", [""], [""], [""])
    else
      op_html = ""
    end
    return op_html
  end

# -------------------------------
  def prv_html_rtf_unit_physical_container_callback(report_settings, entity_sym, entity_obj, ai)
    value1 = ""
    value2 = ""
    value3 = ""

    ers = report_settings.entity_search_by_name(entity_sym)
    if report_settings.rtf_rw.nil?
      if !entity_obj.physical_container_type.nil? && entity_obj.physical_container_type != ""
        value1 = t("physical_container_type") + ": " + entity_obj.physical_container_type
      end
      if !entity_obj.physical_container_title.nil? && entity_obj.physical_container_title != ""
        value2 = t("physical_container_title") + ": " + entity_obj.physical_container_title
      end
      if !entity_obj.physical_container_number.nil? && entity_obj.physical_container_number != ""
        value3 = t("physical_container_number") + ": " + entity_obj.physical_container_number
      end

      value_html = value1
      if value2 != ""
        if value_html != "" then value_html = value_html + "<br />" end
        value_html = value_html + value2
      end
      if value3 != ""
        if value_html != "" then value_html = value_html + "<br />" end
        value_html = value_html + value3
      end

      if value_html != ""
        op_html = ""
        if !ers.dont_use_fld_captions
          op_html = op_html + "<p class=\"fldcaption\">"
          op_html = op_html + "<strong class=\"field-header\">" + ai.name_caption + "</strong>"
          op_html = op_html + "</p>"
        end
        op_html = op_html + "<p>"
        op_html = op_html + value_html
        op_html = op_html + "</p>"
      end
      return op_html
    else
      if !entity_obj.physical_container_type.nil? && entity_obj.physical_container_type != ""
        value1 = prv_translate("physical_container_type") + ": " + entity_obj.physical_container_type
      end
      if !entity_obj.physical_container_title.nil? && entity_obj.physical_container_title != ""
        value2 = prv_translate("physical_container_title") + ": " + entity_obj.physical_container_title
      end
      if !entity_obj.physical_container_number.nil? && entity_obj.physical_container_number != ""
        value3 = prv_translate("physical_container_number") + ": " + entity_obj.physical_container_number
      end

      if value1 != "" || value2 != "" || value3 != ""
        if !ers.dont_use_fld_captions
          rtf_print_field_caption(report_settings.rtf_rw, report_settings.rtf_stylesheet_code_archimista_label, ai.name_caption)
        end

        rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "physical_container")
				rtf_stylesheet_index = report_settings.get_attribute_rtf_stylesheet_code(rtf_stylesheet_key)

        if value1 != ""
          rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, value1)
        end
        if value2 != ""
          rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, value2)
        end
        if value3 != ""
          rtf_print_field_value(report_settings.rtf_rw, rtf_stylesheet_index, value3)
        end
        report_settings.rtf_rw.writeNewLine(nil, nil, 8)
      end

      return ""
    end
  end

# -------------------------------
  def prv_html_rtf_unit_other_reference_numbers_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.unit_other_reference_numbers.present? then
      ers = report_settings.entity_search_by_name(entity_sym)
      if report_settings.rtf_rw.nil?
        note_fld_caption = t("note")
      else
        note_fld_caption = prv_translate("note")
      end
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "unit_other_reference_numbers")

      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.unit_other_reference_numbers, ["other_reference_number", "qualifier", "note"], " ", ["", "(", "| " + note_fld_caption + ": "], ["", ")", ""], ["", "", ""])
    else
      op_html = ""
    end
    return op_html
  end

# -------------------------------
  def prv_html_rtf_unit_iccd_subjects_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.iccd_subjects.present? then
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "iccd_subjects")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.iccd_subjects, ["sgti"], " ", [""], [""], [""])
    else
      op_html = ""
    end
    return op_html
  end

# -------------------------------
  def prv_html_rtf_unit_iccd_authors_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.iccd_authors.present? then
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "iccd_authors")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.iccd_authors, ["autn", "autm", "autk"], " ", ["AUFN (autore): ", ", AUFM (attribuzione): ", ", AUFK (qualifica): "], ["", "", ""], ["", "", ""])
    else
      op_html = ""
    end
    return op_html
  end

# -------------------------------
  def prv_html_rtf_unit_iccd_damages_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.iccd_damages.present? then
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "iccd_damages")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.iccd_damages, ["stcs"], " ", [""], [""], [""])
    else
      op_html = ""
    end
    return op_html
  end

# Upgrade 2.1.0 inizio
# -------------------------------
  def prv_html_rtf_sc2_textual_elements_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.sc2_textual_elements.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "sc2_textual_elements")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.sc2_textual_elements, ["isri"], " ", [""], [""], [""])
    else
      op_html = ""
    end
    return op_html
  end

  def prv_html_rtf_sc2_visual_elements_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.sc2_visual_elements.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "sc2_visual_elements")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.sc2_visual_elements, ["stmd"], " ", [""], [""], [""])
    else
      op_html = ""
    end
    return op_html
  end

# -------------------------------
  def prv_html_rtf_sc2_authors_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.sc2_authors.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "sc2_authors")
      
# Upgrade 2.2.0 inizio
#      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.sc2_authors, ["autn", "auta", "autr"], " ", ["", "", " ("], ["", "", ")"], ["", "", ""])
      settings =
      {
        :l1_fld_names => ["autn", "auta", "autr"],
        :l1_fld_separator => " ",
        :l1_fld_prefixes => ["", "", " ("],
        :l1_fld_postfixes => ["", "", ")"],
        :l1_fld_value_transformations => ["", "", ""],
        :l1_item_key_fldname => "id",
      
        :l2_caption => prv_translate("sc2_attribution_reasons") + ": ",
        :l2_fld_names => ["autm"],
        :l2_fld_separator => " ",
        :l2_fld_prefixes => [""],
        :l2_fld_postfixes => [""],
        :l2_fld_value_transformations => [""],
        :l2_foreign_key_fldname => "sc2_author_id",
        :l2_inst_separator => ", ",
        
        :l1vsl2_separator => " - ",
        :l2_position => "after"
      }     
      op_html = prv_html_rtf_items_concat_with_subtable(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.sc2_authors, entity_obj.sc2_attribution_reasons, settings)
# Upgrade 2.2.0 fine
    else
      op_html = ""
    end
    return op_html
  end

  def prv_html_rtf_sc2_commissions_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.sc2_commissions.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "sc2_commissions")
# Upgrade 2.2.0 inizio
#      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.sc2_commissions, ["cmmc"], " ", [""], [""], [""])
      settings =
      {
        :l1_fld_names => ["cmmc"],
        :l1_fld_separator => " ",
        :l1_fld_prefixes => [""],
        :l1_fld_postfixes => [""],
        :l1_fld_value_transformations => [""],
        :l1_item_key_fldname => "id",
      
        :l2_caption => prv_translate("sc2_commission_names") + ": ",
        :l2_fld_names => ["cmmn"],
        :l2_fld_separator => " ",
        :l2_fld_prefixes => [""],
        :l2_fld_postfixes => [""],
        :l2_fld_value_transformations => [""],
        :l2_foreign_key_fldname => "sc2_commission_id",
        :l2_inst_separator => ", ",
        
        :l1vsl2_separator => " - ",
        :l2_position => "before"
      }     
      op_html = prv_html_rtf_items_concat_with_subtable(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.sc2_commissions, entity_obj.sc2_commission_names, settings)
# Upgrade 2.2.0 fine
    else
      op_html = ""
    end
    return op_html
  end

  def prv_html_rtf_sc2_techniques_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.sc2_techniques.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "sc2_techniques")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.sc2_techniques, ["mtct"], " ", [""], [""], [""])
    else
      op_html = ""
    end
    return op_html
  end

  def prv_html_rtf_sc2_scales_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.sc2_scales.present?
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "sc2_scales")
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.sc2_scales, ["sca"], " ", [""], [""], [""])
    else
      op_html = ""
    end
    return op_html
  end
# Upgrade 2.1.0 fine

# -------------------------------
  def prv_html_rtf_project_managers_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.project_managers.present? then
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "project_managers")
# Upgrade 2.1.0 inizio
#      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.project_managers, ["credit_name", "qualifier"], " ", ["", " ["], ["", "]"], ["", ""])
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.project_managers, ["name", "qualifier"], " ", ["", " ["], ["", "]"], ["", ""])
# Upgrade 2.1.0 fine
    else
      op_html = ""
    end
    return op_html
  end

# -------------------------------
  def prv_html_rtf_project_stakeholders_callback(report_settings, entity_sym, entity_obj, ai)
    if entity_obj.project_stakeholders.present? then
      ers = report_settings.entity_search_by_name(entity_sym)
      rtf_stylesheet_key = report_settings.make_attribute_rtf_stylesheet_codes_key(entity_sym.to_s, "project_stakeholders")
# Upgrade 2.1.0 inizio
#      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.project_stakeholders, ["credit_name", "qualifier"], " ", ["", " ["], ["", "]"], ["", ""])
      op_html = prv_html_rtf_items_concat(report_settings, ers, ai.name_caption, rtf_stylesheet_key, entity_obj.project_stakeholders, ["name", "qualifier"], " ", ["", " ["], ["", "]"], ["", ""])
# Upgrade 2.1.0 fine
    else
      op_html = ""
    end
    return op_html
  end
end
