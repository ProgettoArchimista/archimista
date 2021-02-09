class Import < ActiveRecord::Base
  require 'csv'
  require 'nokogiri'
  require 'open-uri'
  require 'zip'
  require 'active_support'
  
  # INIZIO - require richiesti per l'import batch
  require File.join(File.dirname(__FILE__), ".", "fond.rb")
  require File.join(File.dirname(__FILE__), ".", "creator_event.rb")
  require File.join(File.dirname(__FILE__), ".", "creator.rb")
  require File.join(File.dirname(__FILE__), ".", "fond_lang.rb")
  require File.join(File.dirname(__FILE__), ".", "rel_custodian_fond.rb")
  require File.join(File.dirname(__FILE__), ".", "rel_fond_source.rb")
  require File.join(File.dirname(__FILE__), ".", "digital_object.rb")
  require File.join(File.dirname(__FILE__), ".", "source.rb")
  require File.join(File.dirname(__FILE__), ".", "source_url.rb")
  require File.join(File.dirname(__FILE__), ".", "creator_corporate_type.rb")
  require File.join(File.dirname(__FILE__), ".", "rel_creator_fond.rb")
  require File.join(File.dirname(__FILE__), ".", "creator_url.rb")
  require File.join(File.dirname(__FILE__), ".", "creator_editor.rb")
  require File.join(File.dirname(__FILE__), ".", "creator_name.rb")
  require File.join(File.dirname(__FILE__), ".", "creator_legal_status.rb")
  require File.join(File.dirname(__FILE__), ".", "rel_creator_source.rb")
  require File.join(File.dirname(__FILE__), ".", "rel_creator_institution.rb")
  require File.join(File.dirname(__FILE__), ".", "institution.rb")
  require File.join(File.dirname(__FILE__), ".", "institution_editor.rb")
  require File.join(File.dirname(__FILE__), ".", "custodian.rb")
  require File.join(File.dirname(__FILE__), ".", "custodian_type.rb")
  require File.join(File.dirname(__FILE__), ".", "custodian_name.rb")
  require File.join(File.dirname(__FILE__), ".", "custodian_url.rb")
  require File.join(File.dirname(__FILE__), ".", "rel_custodian_source.rb")
  require File.join(File.dirname(__FILE__), ".", "custodian_identifier.rb")
  require File.join(File.dirname(__FILE__), ".", "custodian_building.rb")
  require File.join(File.dirname(__FILE__), ".", "custodian_contact.rb")
  require File.join(File.dirname(__FILE__), ".", "custodian_editor.rb")
  require File.join(File.dirname(__FILE__), ".", "source_type.rb")
  require File.join(File.dirname(__FILE__), ".", "unit_identifier.rb")
  require File.join(File.dirname(__FILE__), ".", "sc2.rb")
  require File.join(File.dirname(__FILE__), ".", "unit_editor.rb")
  require File.join(File.dirname(__FILE__), ".", "heading.rb")
  require File.join(File.dirname(__FILE__), ".", "rel_unit_heading.rb")
  
  require File.join(File.dirname(__FILE__), ".", "unit_url.rb")
  require File.join(File.dirname(__FILE__), ".", "unit_event.rb")
  require File.join(File.dirname(__FILE__), ".", "anagraphic.rb")
  require File.join(File.dirname(__FILE__), ".", "rel_unit_anagraphic.rb")
  require File.join(File.dirname(__FILE__), ".", "anag_identifier.rb")
  require File.join(File.dirname(__FILE__), ".", "fond_editor.rb")
  require File.join(File.dirname(__FILE__), ".", "fond_name.rb")
  require File.join(File.dirname(__FILE__), ".", "fond_event.rb")
  require File.join(File.dirname(__FILE__), ".", "fond_identifier.rb")
  require File.join(File.dirname(__FILE__), ".", "creator_identifier.rb")
  require File.join(File.dirname(__FILE__), ".", "document_form.rb")
  require File.join(File.dirname(__FILE__), ".", "rel_fond_document_form.rb")
  require File.join(File.dirname(__FILE__), ".", "term.rb")
  require File.join(File.dirname(__FILE__), ".", "vocabulary.rb")
  require File.join(File.dirname(__FILE__), ".", "sc2_scale.rb")
  require File.join(File.dirname(__FILE__), ".", "sc2_technique.rb")
  require File.join(File.dirname(__FILE__), ".", "sc2_textual_element.rb")
  require File.join(File.dirname(__FILE__), ".", "sc2_visual_element.rb")
  require File.join(File.dirname(__FILE__), ".", "sc2_author.rb")
  require File.join(File.dirname(__FILE__), ".", "sc2_attribution_reason.rb")
  require File.join(File.dirname(__FILE__), ".", "fe_context.rb")
  require File.join(File.dirname(__FILE__), ".", "fe_identification.rb")
  # FINE - require richiesti per l'import batch
  
  # Upgrade 2.1.0 inizio
  extend Sc2Restore
  # Upgrade 2.1.0 fine

  attr_accessor :imported_file_version, :does_source_have_fonds
  # Upgrade 2.2.0 inizio
  attr_accessor :ref_fond_id, :ref_root_fond_id, :is_icar_import, :is_batch_import, :batch_import_filename
  # Upgrade 2.2.0 fine

  TMP_IMPORTS = "#{Rails.root}/tmp/imports"
  # Upgrade 3.0.0 inizio  
  PUBLIC_IMPORTS = "#{Rails.root}/public/imports"
  # Upgrade 3.0.0 fine  
  DIGITAL_FOLDER_PATH = "#{Rails.root}/public/digital_objects"

  belongs_to :user
  belongs_to :importable, :polymorphic => true

  @is_batch_import = false

  begin
    has_attached_file :data, :path => ":rails_root/public/imports/:id/:basename.:extension"
  rescue
    @is_batch_import = true
  end

  before_create :sanitize_file_name
  
  begin
    validates_attachment_presence :data
    do_not_validate_attachment_file_type :data
  rescue
    # caso del batch import
    # do_nothing
  end
  
  def ar_connection
    # Upgrade 2.0.0 inizio
    #ActiveRecord::Base.connection
    self.class.connection
    # Upgrade 2.0.0 fine
  end

  def adapter
    ar_connection.adapter_name.downcase
  end

  def xml_data_file
    PUBLIC_IMPORTS + "/#{self.id}/#{self.data_file_name}"
  end

  # Upgrade 3.0.0 inizio  
  def csv_data_file
    PUBLIC_IMPORTS + "/#{self.id}/#{self.data_file_name}"
  end
  # Upgrade 3.0.0 fine

  def data_file
    TMP_IMPORTS + "/#{self.id}_data.json"
  end

  def metadata_file
    TMP_IMPORTS + "/#{self.id}_metadata.json"
  end

  def delete_tmp_files
    File.delete(data_file) if File.exists?(data_file)
    File.delete(metadata_file) if File.exists?(metadata_file)
  end

  def delete_tmp_zip_files
    @extracted_files.each do |efd|
      File.delete(efd) if File.exists?(efd)
    end
    File.delete(TMP_IMPORTS + "/data.json") if File.exists?(TMP_IMPORTS + "/data.json")
  end

  def delete_digital_folder(folder)
    if Dir.exists?(DIGITAL_FOLDER_PATH + "/" + folder)
      FileUtils.remove_dir(DIGITAL_FOLDER_PATH + "/" + folder)
    end
  end

  def db_has_subunits?
    Unit.exists?(["db_source = ? AND ancestry_depth > 0", self.identifier])
  end

  def db_has_digital_objects?
    DigitalObject.exists?(["db_source = ?", self.identifier])
  end

  def is_institution_importable_type?
    return (importable_type == "Institution")
  end

  def is_creator_importable_type?
    return (importable_type == "Creator")
  end

  def is_anagraphic_importable_type?
    return (importable_type == "Anagraphic")
  end

  def is_custodian_importable_type?
    return (importable_type == "Custodian")
  end

  def is_source_importable_type?
    return (importable_type == "Source")
  end

  # Upgrade 2.2.0 inizio
  def is_unit_importable_type?
    return (importable_type == "Unit")
  end

  def is_unit_aef_file?
    return is_unit_importable_type?
  end

  # Upgrade 3.0.0 inizio
  # modificata nella 3.1.1 con l'utilizzo della gemma csv
  def import_csv_file(user, ability)
    begin
      unit_aef_import_units_count = 0
      rebuild_sequence = false

      ActiveRecord::Base.transaction do
        model = nil
        prev_model = nil
        object = nil
        prev_line = ""
        headers = nil
        elem_count = 0
        separator = ""
        date_time = DateTime.now
        sequence_number = nil

        CSV.foreach(csv_data_file) do |row|
          if prev_line.blank? and (!row.blank? or !row.all?(&:blank?))
            pos_last = -1
            elem = row[0].split('_')
            elem.each do |e|
              if e.last == "s"
                pos_last += 1
                break
              else
                pos_last += 1
              end
            end
            key = (elem[0..pos_last].join('_'))[0..-2]
            key = key.to_s
            model = key.camelize.constantize
            headers = []
            row.each do |elem|
              if !elem.nil?
                headers.push(elem.gsub!(key + 's_', ''))
              end
            end
            prev_line = "not_blank"
          else
            if row.all?(&:blank?)
              prev_line = ""
            else
              values = row.map! { |value| value.nil? ? '' : value }
              zipped = headers.zip(values)
              ipdata = Hash[zipped]
              object = model.new(ipdata)
              object.db_source = self.identifier
              if object.has_attribute? 'group_id'
                object.group_id = if user.is_multi_group_user?() then
                                    ability.target_group_id
                                  else
                                    user.rel_user_groups[0].group_id
                                  end
              end
              if (self.is_unit_aef_file?)
                if (model.to_s == "Unit")
                  object.fond_id = self.ref_fond_id
                  object.root_fond_id = prv_get_ref_root_fond_id
                  rebuild_sequence = true

                  if sequence_number.nil?
                    sequence_number = Unit.where(:root_fond_id => object.root_fond_id).maximum(:sequence_number)
                  end
                  sequence_number = sequence_number + 1
                  object.sequence_number = sequence_number

                  unit_aef_import_units_count += 1
                end
              end
              object.created_by = user.id if object.has_attribute? 'created_by'
              object.updated_by = user.id if object.has_attribute? 'updated_by'
              if object.created_at.nil?
                object.created_at = date_time
              end
              if object.updated_at.nil?
                object.updated_at = date_time
              end

              object.sneaky_save!

              if model != prev_model && !prev_model.nil?
                prev_object = prev_model.new
                set_lacking_field_values(prev_object)
              end
              prev_model = model
            end
          end
        end
      end
      update_statements(unit_aef_import_units_count)

      if rebuild_sequence
        Fond.find(prv_get_ref_root_fond_id).rebuild_external_sequence
      end
    rescue Exception => e
      Rails.logger.info "import_csv_file errore: " + e.message.to_s
      return false
    ensure
    end
  end
  # Upgrade 3.0.0 fine

  def import_unit_from_path document, user_id, group_id
    Rails.logger.info "Import unita' INIZIATO da import.rb"

    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    unit_component = document.xpath("did/unitid")

    unit = Unit.new

    unit.db_source = self.identifier
    unit.created_by = user_id
    unit.updated_by = user_id
    unit.created_at = datetime
    unit.updated_at = datetime

    case document.xpath("@level").text
    #fpu when "list"
    #  unit.unit_type = "registro o altra unità rilegata"
    when "file"
      case document.xpath("@otherlevel").text
      when "registro"
        unit.unit_type = "registro o altra unità rilegata"
      when "fascicolopersonale"
        unit.unit_type = "fascicolo o altra unità complessa"
        unit.file_type = "fascicolo personale"
      when "cartografiastorica"
        unit.unit_type = "unità documentaria"
        unit.sc2_tsk = "CARS"
      when "disegnoartistico"
        unit.unit_type = "unità documentaria"
        unit.sc2_tsk = "D"
      when "disegnotecnico"
        unit.unit_type = "unità documentaria"
        unit.sc2_tsk = "DT"
      when "fotografia"
        unit.unit_type = "unità documentaria"
        unit.sc2_tsk = "F"
      when "stampa"
        unit.unit_type = "unità documentaria"
        unit.sc2_tsk = "S"
      else
        unit.unit_type = "fascicolo o altra unità complessa"
      end
    when  "item"
      unit.unit_type = "unità documentaria"
    end


    unit.legacy_id = unit_component.xpath("@identifier").text

    if unit_component.xpath("../../accessrestrict/p").present?
      terms = Term.where(vocabulary_id: Vocabulary.where(name: "units.access_condition").first.id).select(:term_key)
      condition = unit_component.xpath("../../accessrestrict/p").text.squish
      if terms.include? condition.downcase
        unit.access_condition = condition.downcase
      else
        unit.access_condition_note = condition.gsub(/\t/, '')
      end
    end
    if unit_component.xpath("../../userestrict/p").present?
      terms = Term.where(vocabulary_id: Vocabulary.where(name: "units.use_condition").first.id).select(:term_key)
      condition = unit_component.xpath("../../userestrict/p").text.squish
      if terms.include? condition.downcase
        unit.use_condition = condition.downcase
      else
        unit.use_condition_note = condition.gsub(/\t/, '')
      end
    end

    unit.ancestry = nil
    unit.ancestry_depth = 0
    if (unit.ancestry.present?)
      unit.ancestry_depth = Unit.find(unit.ancestry).ancestry_depth + 1
    end
    unit.arrangement_note = unit_component.xpath("../processinfo[@localtype='noteDellArchivista']/p").text.squish
    unit.content = unit_component.xpath("../../scopecontent/p").text.squish
    unit.extent = unit_component.xpath("../physdescstructured/quantity").text
    unit.physical_type = unit_component.xpath("../physdescstructured/unittype").text
    unit.file_number = unit_component.xpath("../unitid[@localtype='numFascicolo']").text
    unit.folder_number = unit_component.xpath("../unitid[@localtype='busta']").text
    unit.medium = unit_component.xpath("../physdescstructured/physfacet[@localtype='Supporto']").text
    unit.physical_container_number = unit_component.xpath("../container/@containerid").text
    unit.physical_container_title = unit_component.xpath("../container").text
    unit.physical_container_type = unit_component.xpath("../container/@localtype").text
    unit.physical_description = unit_component.xpath("../physdescstructured/descriptivenote").text.squish
    unit.preservation_note = unit_component.xpath("../physdescstructured/phystech").text.squish
    unit.reference_number = unit_component.xpath("../unitid[@localtype='segnaturaAttuale']").text
    unit.title = unit_component.xpath("../unittitle[@localtype='denominazione']").text.squish
    unit.given_title = unit_component.xpath("../unittitle[@localtype='titoloAttribuito']").text.squish
    unit.tmp_reference_number = unit_component.xpath("../unitid[@localtype='segnaturaProvvisoriaNumero']").text
    unit.tmp_reference_string = unit_component.xpath("../unitid[@localtype='segnaturaProvvisoriaTesto']").text

    unit.fond_id = nil
    if (unit.fond_id.present?)
      unit.root_fond_id = Fond.find(unit.fond_id).root.id
    end
    Rails.logger.info "Salvataggio unita'"
    unit.sneaky_save

    unit_component.xpath("../unitid").each do |unitid|
      if unitid.xpath("@identifier").present?
        unit_identifier = UnitIdentifier.new
        unit_identifier.unit_id = unit.id
        unit_identifier.identifier = unitid.text
        unit_identifier.note = "Identificativo di sistema"
        unit_identifier.db_source = self.identifier
        unit_identifier.save!
      end
    end

    if unit_component.xpath("../unitid[@localtype='classificazione']").present? ||
        unit_component.xpath("../unitid[@localtype='fascicolo']").present? ||
        unit_component.xpath("../unitid[@localtype='subfascicolo']").present?
      fe_context = FeContext.new
      fe_context.unit_id = unit.id
      fe_context.classification = unit_component.xpath("../unitid[@localtype='classificazione']").text
      fe_context.number = unit_component.xpath("../unitid[@localtype='fascicolo']").text
      fe_context.sub_number = unit_component.xpath("../unitid[@localtype='subfascicolo']").text
      fe_context.save!
    end

    if unit_component.xpath("../unitid[@localtype='classe']").present? ||
        unit_component.xpath("../unitid[@localtype='codice']").present? ||
        unit_component.xpath("../unitid[@localtype='categoria']").present? ||
        unit_component.xpath("../unitid[@localtype='anno']").present?
      fe_identifications = FeIdentification.new
      fe_identifications.unit_id = unit.id
      fe_identifications.identification_class = unit_component.xpath("../unitid[@localtype='classe']").text
      fe_identifications.code = unit_component.xpath("../unitid[@localtype='codice']").text
      fe_identifications.category = unit_component.xpath("../unitid[@localtype='categoria']").text
      fe_identifications.file_year = unit_component.xpath("../unitid[@localtype='anno']").text
      fe_identifications.save!
    end

    if unit_component.xpath("../physdescstructured").present? ||
        unit_component.xpath("../../odd[@localtype='NumeroTavola']/p").present? ||
        unit_component.xpath("../../controlaccess/subject[@localtype='Soggetto']").present?
      sc2 = Sc2.new
      sc2.unit_id = unit.id
      sc2.mtce = unit_component.xpath("../physdescstructured/physfacet[@localtype='Esecuzione']").text
      sc2.sdtt = unit_component.xpath("../physdescstructured/physfacet[@localtype='Tiporappresentazione']").text
      sc2.misa = unit_component.xpath("../physdescstructured/physfacet[@localtype='altezza']").text
      sc2.misl = unit_component.xpath("../physdescstructured/physfacet[@localtype='larghezza']").text
      sc2.lrc = unit_component.xpath("../physdescstructured/descriptivenote/p/geoname[@localtype='Luogorappresentazione']/part").text
      sc2.dpgf = unit_component.xpath("../../odd[@localtype='NumeroTavola']/p").text
      sc2.sgti = unit_component.xpath("../../controlaccess/subject[@localtype='Soggetto']/part").text
      sc2.save!
    end

    if unit_component.xpath("../physdescstructured/physfacet[@localtype='Scala']").present?
      sc2_scales = Sc2Scale.new
      sc2_scales.unit_id = unit.id
      sc2_scales.sca = unit_component.xpath("../physdescstructured/physfacet[@localtype='Scala']").text
      sc2_scales.save!
    end

    if unit_component.xpath("../physdescstructured/physfacet[@localtype='Tecnica']").present?
      sc2_techniques = Sc2Technique.new
      sc2_techniques.unit_id = unit.id
      sc2_techniques.mtct = unit_component.xpath("../physdescstructured/physfacet[@localtype='Tecnica']").text
      sc2_techniques.save!
    end

    if unit_component.xpath("../../odd[@localtype='ElementiTestuali']/p").present?
      sc2_textual_element = Sc2TextualElement.new
      sc2_textual_element.unit_id = unit.id
      sc2_textual_element.isri = unit_component.xpath("../../odd[@localtype='ElementiTestuali']/p").text.squish
      sc2_textual_element.save!
    end

    if unit_component.xpath("../../odd[@localtype='ElementiFigurati']/p").present?
      sc2_visual_elements = Sc2VisualElement.new
      sc2_visual_elements.unit_id = unit.id
      sc2_visual_elements.stmd = unit_component.xpath("../../odd[@localtype='ElementiFigurati']/p").text.squish
      sc2_visual_elements.save!
    end

    if unit_component.xpath("../../controlaccess/name[@localtype='Autore']").present?
      sc2_authors = Sc2Author.new
      sc2_authors.autr = unit_component.xpath("../../controlaccess/name[@localtype='Autore']/part[@localtype='Ruolo']").text
      sc2_authors.autn = unit_component.xpath("../../controlaccess/name[@localtype='Autore']/part[@localtype='Autore']").text
      sc2_authors.auta = unit_component.xpath("../../controlaccess/name[@localtype='Autore']/part[@localtype='DatiAnagrafici']").text
      sc2_authors.save!

      if unit_component.xpath("../../controlaccess/name[@localtype='Autore']/part[@localtype='Attribuzione']").present?
        sc2_attribution_reasons = Sc2AttributionReason.new
        sc2_attribution_reasons.sc2_author_id = sc2_authors.id
        sc2_attribution_reasons.autm = unit_component.xpath("../../controlaccess/name[@localtype='Autore']/part[@localtype='Attribuzione']").text
        sc2_attribution_reasons.save!
      end
    end

    #if unit_component.xpath("../../controlaccess/name[@localtype='Committente']").present?
    #  sc2_commission = Sc2Commission.new
    #  sc2_commission.unit_id = unit.id
    #  sc2_commission.cmmc
    #end
    if unit_component.xpath("../../processinfo[@localtype='compilatori']/processinfo").present?
      unit_component.xpath("../../processinfo[@localtype='compilatori']/processinfo").each do |pi|
        editor = UnitEditor.new
        editor.unit_id = unit.id
        editor.name = pi.xpath("p/persname/part[@localtype='compilatore']").text
        tipo_intervento = pi.xpath("p/persname/part[@localtype='tipoIntervento']").text
        if tipo_intervento == "inserimento" || tipo_intervento == "created"
          editor.editing_type = "inserimento dati"
        elsif tipo_intervento == "modifica" || tipo_intervento == "updated"
          editor.editing_type = "aggiornamento scheda"
        end
        editor.qualifier = pi.xpath("p/persname/part[@localtype='qualifica']").text
        editor.edited_at = pi.xpath("p/date[@localtype='dataIntervento']").text
        editor.save!
      end
    else
      if unit_component.xpath("/ead/control/maintenancehistory/maintenanceevent").present?
        unit_component.xpath("/ead/control/maintenancehistory/maintenanceevent").each do |maintenance_event|
          editor = UnitEditor.new
          editor.unit_id = unit.id
          editor.name = maintenance_event.xpath("agent").text.squish
          editor.editing_type = import_editing_type(maintenance_event.xpath("eventtype/@value").text)
          if maintenance_event.xpath("eventdatetime").present?
            editor.edited_at = maintenance_event.xpath("eventdatetime").text.squish
          end
          editor.qualifier = import_agent_type(maintenance_event.xpath("agenttype/@value").text)
          editor.save
        end
      end
    end

    if unit_component.xpath("../../controlaccess/persname").present?
      unit_component.xpath("../../controlaccess/persname").each do |heading|
        headingObj = get_heading_obj(heading, 'Persona')
        save_heading(headingObj, unit.id)
      end
    end

    if unit_component.xpath("../../controlaccess/famname").present?
      unit_component.xpath("../../controlaccess/famname").each do |heading|
        headingObj = get_heading_obj(heading, 'Famiglia')
        save_heading(headingObj, unit.id)
      end
    end

    if unit_component.xpath("../../controlaccess/corpname").present?
      unit_component.xpath("../../controlaccess/corpname").each do |heading|
        headingObj = get_heading_obj(heading, 'Ente')
        save_heading(headingObj, unit.id)
      end
    end

    if unit_component.xpath("../../controlaccess/geogname").present?
      unit_component.xpath("../../controlaccess/geogname").each do |heading|
        headingObj = get_heading_obj(heading, 'Toponimo')
        save_heading(headingObj, unit.id)
      end
    end

    if unit_component.xpath("../../controlaccess/subject").present?
      unit_component.xpath("../../controlaccess/subject").each do |heading|
        headingObj = get_heading_obj(heading, 'Altro')
        save_heading(headingObj, unit.id)
      end
    end

    if unit_component.xpath("../../controlaccess/genreform").present?
      unit_component.xpath("../../controlaccess/genreform").each do |heading|
        headingObj = get_heading_obj(heading, 'Tipologia documentaria')
        save_heading(headingObj, unit.id)
      end
    end

    if unit_component.xpath("../../relations/relation[@otherrelationtype='URL']").present?
      unit_component.xpath("../../relation/relationtype[@otherrelationtype='URL']").each do |url|
        unit_url = UnitUrl.new
        unit_url.id = unit.id
        unit_url.url = url.xpath('@href').text
        unit_url.note = url.xpath('relationentry').text
        unit_url.save!
      end
    end

    if unit_component.xpath("../unitdatestructured").present?
      date = unit_component.xpath("../unitdatestructured")
      unit_event = UnitEvent.new
      unit_event.unit_id = unit.id
      if date.xpath("dateset").present?
        import_dateset date.xpath("dateset").first, unit_event, datetime
      else
        import_dateset date, unit_event, datetime
      end
    end

    if unit_component.xpath("../../relations/relation[@otherrelationtype='INDICE']/relationentry[@localtype='identificativo']").present?
      unit_component.xpath("../../relations/relation[@otherrelationtype='INDICE']/relationentry[@localtype='identificativo']").each do |anagraphic_id|
        anagraphic = Anagraphic.where(db_source: self.identifier, legacy_id: anagraphic_id.text[3..10].to_i.to_s)
        if anagraphic.present?
          rel_unit_anag = RelUnitAnagraphic.new
          rel_unit_anag.db_source = self.identifier
          rel_unit_anag.unit_id = unit.id
          rel_unit_anag.anagraphic_id = anagraphic.first.id
          rel_unit_anag.legacy_unit_id = unit.legacy_id
          rel_unit_anag.legacy_anagraphic_id = anagraphic.first.legacy_id
          rel_unit_anag.save
        end
      end
    end
    if unit_component.xpath("../../did/dao").present?
      unit_component.xpath("../../did/dao").each do |digital_obj|
        digital_object = DigitalObject.new
        digital_object.attachable_type = 'Unit'
        digital_object.attachable_id = unit.id
        digital_object.db_source = self.identifier
        digital_object.legacy_id = digital_obj.xpath('@id').text
        href = digital_obj.xpath('@href').text.split('/')
        
        #if href.last == ""
        #  href.pop
        #end
        #digital_object.asset_file_name = href.pop #esclude il nome del file .jpg dopo aver eliminato la stringa vuota dovuta all'eventuale fine dell'url con uno slash
        #digital_object.access_token = href.last
        digital_object.access_token = href.first
        digital_object.asset_file_name = href.last

        digital_object.asset_content_type = digital_obj.xpath("@linkrole").text
        digital_object.title = "importato senza titolo"
        digital_object.created_by = user_id
        digital_object.updated_by = user_id
        digital_object.group_id = group_id
        digital_object.asset_updated_at = datetime
        digital_object.save!
        Rails.logger.info "Oggetto digitale #{digital_object.id} aggiunto all'unità #{digital_object.attachable_id}"
      end
    end


    Rails.logger.info "Unita' salvata, id: #{unit.id}"
    self.importable_id = unit.id
    return unit
  end

  def save_heading (headingObj, unit_id)
    rel_unit_heading = RelUnitHeading.new
    unless headingObj.id?
      headingObj.save!
    end
    rel_unit_heading.heading_id = headingObj.id
    rel_unit_heading.unit_id = unit_id
    rel_unit_heading.save!
  end

  def get_heading_obj (heading_xml, heading_type)
    heading_name = []
    heading_name.push(heading_xml.xpath('part[@localtype="cognome"]').text)
    heading_name.push(heading_xml.xpath('part[@localtype="nome"]').text)
    heading_name.push(heading_xml.xpath('part[not(@*)]').text)
    name = heading_name.join(' ').squish

    headingObj = Heading.find_by(name: name) #il nome deve essere unico
    if headingObj.nil?
      headingObj = Heading.new
      headingObj.heading_type = heading_type
      headingObj.name = name
      headingObj.dates = heading_xml.xpath("part[@localtype='estremiCronologici']").text
      headingObj.qualifier = heading_xml.xpath("part[@localtype='qualifica']").text
    end

    headingObj
  end

  def import_unit_hierarchy (unit_xpath, root_fond_id, fond_id, user_id, group_id, ancestry)
    fond = Fond.find(fond_id)
    unit_just_saved = Unit.find (import_unit_from_path unit_xpath, user_id, group_id).id
    unit_just_saved.ancestry = ancestry
    unit_just_saved.fond_id = fond_id
    unit_just_saved.root_fond_id = root_fond_id
    Rails.logger.info "unita' #{unit_just_saved.id} del complesso #{fond_id} con root: #{root_fond_id}"
    unit_just_saved.ancestry_depth = 0
    if ancestry != nil
      unit_just_saved.ancestry_depth = ancestry.split('/').size
    end
    fond.units_count = fond.units.count
    unit_just_saved.sequence_number = fond.units.count + 1
    unit_just_saved.sneaky_update
    fond.sneaky_update
    if unit_xpath.xpath('c').present?
      unit_xpath.xpath('c').each do |subunit|
          if ancestry != nil
            import_unit_hierarchy subunit, root_fond_id, fond_id, user_id, group_id, (ancestry + '/' + unit_just_saved.id.to_s)
          else
            import_unit_hierarchy subunit, root_fond_id, fond_id, user_id, group_id, unit_just_saved.id.to_s
          end
      end
    end
    Rails.logger.info "Unita` #{unit_xpath.xpath('did/unitid/@identifier').text} salvata."
    return
  end

  #fond_root: ead/archdesc o ..dsc/c
  #ancestry: rappresenta una stringa contenente tutti i parent dell'entita` in considerazione
  def import_fond_hierarchy (fond_root, user_id, group_id, ancestry)
    #TODO da rendere una costante globale.
    fond_types = [
        "fonds",
        "recordgrp",
        "subfonds",
        "series",
        "subseries",
        "subsubseries",
        "otherlevel"
    ]
    #otherlevels = Term.where(id: Vocabulary.find_by(name: "fonds.fond_type").id).select(:term_value)

    def eredita_compilatori (fond_id, ancestry)
      if ancestry != ""
        
        fond_editor = FondEditor.find_by_fond_id(fond_id)
        
        if fond_editor.nil?
          parent_fond_id = ancestry.split("/")[-1].to_i

          FondEditor.where(fond_id: parent_fond_id).find_each do |parent_fond_editor|
            new_fond_editor = FondEditor.new
            new_fond_editor.fond_id = fond_id
            new_fond_editor.name = parent_fond_editor.name
            new_fond_editor.qualifier = parent_fond_editor.qualifier
            new_fond_editor.editing_type = parent_fond_editor.editing_type
            new_fond_editor.edited_at = parent_fond_editor.edited_at
            new_fond_editor.db_source = parent_fond_editor.db_source
            new_fond_editor.legacy_id = parent_fond_editor.legacy_id
            new_fond_editor.created_at = parent_fond_editor.created_at
            new_fond_editor.updated_at = parent_fond_editor.updated_at
            new_fond_editor.save!
          end
        end
      end
    end

    if ancestry == ''
      fond_just_saved = import_fond_from_path fond_root, user_id, group_id
      root_fond_id = fond_just_saved.id
      
      eredita_compilatori(fond_just_saved.id, ancestry)
      
      ancestry = fond_just_saved.id.to_s
      import_fond_control_field fond_root.xpath("../control"), root_fond_id

      if fond_root.xpath('dsc/c').present?
        Rails.logger.info "Importazione figli di primo livello del fondo."
        fond_root.xpath('dsc/c').each do |subfond|
          if fond_types.include? subfond.xpath("@level").text
            fond_just_saved = Fond.find (import_fond_from_path subfond, user_id, group_id).id
            fond_just_saved.ancestry = ancestry
            fond_just_saved.ancestry_depth = 1
            fond_just_saved.sneaky_update
            
            eredita_compilatori(fond_just_saved.id, ancestry)

            import_fond_hierarchy subfond, user_id, group_id, (ancestry + '/' + fond_just_saved.id.to_s)
          else
            import_unit_hierarchy subfond, ancestry.split('/').first.to_i, ancestry.split('/').last.to_i, user_id, group_id, nil
          end
        end
      end
      return root_fond_id
    else
      if fond_root.xpath('c').present?
        Rails.logger.info "Importazione figli del fondo di livelli successivi al primo."
        fond_root.xpath('c').each do |subfond|
          if fond_types.include? subfond.xpath("@level").text
            fond_just_saved = Fond.find (import_fond_from_path subfond, user_id, group_id).id
            fond_just_saved.ancestry = ancestry
            fond_just_saved.ancestry_depth = ancestry.split('/').size
            fond_just_saved.sneaky_update

            eredita_compilatori(fond_just_saved.id, ancestry)

            import_fond_hierarchy subfond, user_id, group_id, (ancestry + '/' + fond_just_saved.id.to_s)
          else
            import_unit_hierarchy subfond, ancestry.split('/').first.to_i, ancestry.split('/').last.to_i, user_id, group_id, nil
          end
        end
      end
    end
  end

  # dato un generico path xml importa i dati del complesso:
  # sara' /archdesc per il complesso principale e /c per tutti i figli.
  def import_fond_from_path path, user_id, group_id
    Rails.logger.info "import_fond_from_path"
    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    fond = Fond.new
    otherlevel_from_path = ""
    level_from_path = path.xpath("@level").text
    level = level_from_path
    if level_from_path == "otherlevel"
      otherlevel_from_path = path.xpath("@otherlevel").text
      level = otherlevel_from_path
    end
    fond.fond_type = import_level_type(level)

    if level_from_path == "otherlevel"
      if otherlevel_from_path == ""
        Rails.logger.warn "Fondo con @level = otherlevel, descrizione @otherlevel non indicata (campo obbligatorio)"
      else
        Rails.logger.info "Fondo con @level = #{level_from_path}, @otherlevel = #{otherlevel_from_path}, fond_type: #{fond.fond_type}"
      end
    else
      if level_from_path == ""
        Rails.logger.warn "Livello di descrizione del fondo non indicato (campo obbligatorio)"
      else
        Rails.logger.info "Fondo con @level = #{level_from_path}, fond_type: #{fond.fond_type}"
      end
    end

    path.xpath("did/unittitle").each do |title|
      if title.xpath('@localtype').text.downcase == "denominazione"
        fond.name = title.text
      end
    end

    # verra' utilizzato per ricostruire le relazioni presenti nel file icar-import se non presente dovra`
    # dare un'eccezione


    fond.legacy_id = path.xpath("did/unitid").text.squish

    fond.db_source = self.identifier
    fond.created_by = user_id
    fond.updated_by = user_id
    fond.group_id = group_id
    fond.created_at = datetime
    fond.updated_at = datetime

    if path.xpath("accessrestrict/p").present?
      terms = Term.where(vocabulary_id: Vocabulary.where(name: "fonds.access_condition").first.id).select(:term_key)
      condition = path.xpath("accessrestrict/p").first.text.squish
      if terms.include? condition.downcase
        fond.access_condition = condition.downcase
      else
        fond.access_condition_note = condition.downcase
      end
    end

    fond.published = false
    if path.xpath("processinfo/p").text.downcase == "pubblicata"
      fond.published = true
    end

    fond.history = path.xpath("custodhist/p").text.squish

    fond.extent = path.xpath("did/physdesc").text.squish

    path.xpath("did/physdescstructured").each do |pd|
      quantity = pd.xpath("quantity").text.squish
      unit_type = pd.xpath("unittype").text.squish

      if unit_type == "metri lineari"
        begin
          fond.length = Float(quantity)
        rescue
          Rails.logger.info "ead/did/physdescstructured/quantity NON numerico"
        end
      else
        if fond.extent != ""
          fond.extent += "\n"
        end
        fond.extent += quantity + " " + unit_type
      end
    end

    if path.xpath("did/physloc").present?
      Rails.logger.info "Fondo: #{fond.name.squish} - Trovato ma non importato il tag 'ead/did/physloc': #{path.xpath("did/physloc").text.squish}"
    end

    if path.xpath("did/didnote").present?
      Rails.logger.info "Fondo: #{fond.name.squish} - Trovato ma non importato il tag 'ead/did/didnote': #{path.xpath("did/didnote").text.squish}"
    end

    if path.xpath("acqinfo").present?
      Rails.logger.info "Fondo: #{fond.name.squish} - Trovato ma non importato il tag 'ead/acqinfo': #{path.xpath("acqinfo").text.squish}"
    end

    if path.xpath("separatedmaterial").present?
      Rails.logger.info "Fondo: #{fond.name.squish} - Trovato ma non importato il tag 'ead/separatedmaterial': #{path.xpath("separatedmaterial").text.squish}"
    end

    if path.xpath("bibliography").present?
      Rails.logger.info "Fondo: #{fond.name.squish} - Trovato ma non importato il tag 'ead/bibliography': #{path.xpath("bibliography").text.squish}"
    end

    fond.description = path.xpath("scopecontent/p").text.squish

    fond.arrangement_note = ""
    if path.xpath("arrangement/p").present?
      fond.arrangement_note += "Criteri di ordinamento: " + path.xpath("arrangement/p").text.squish + "\n"
    end

    fond.sneaky_save!

    self.importable_id = fond.id

    if path.xpath("processinfo/processinfo/p").present?
      path.xpath("processinfo[@localtype='compilatori']/processinfo[@localtype='compilatore']").each do |pi|
        editor = FondEditor.new
        editor.fond_id = fond.id
        editor.name = pi.xpath("p/persname/part[@localtype='compilatore']").text
        editor.qualifier = pi.xpath("p/persname/part[@localtype='qualifica']").text
        tipo_intervento = pi.xpath("p/persname/part[@localtype='tipoIntervento']").text
        if tipo_intervento == "inserimento" || tipo_intervento == "created"
          editor.editing_type = "inserimento dati"
        elsif tipo_intervento == "modifica" || tipo_intervento == "updated"
          editor.editing_type = "aggiornamento scheda"
        end
        if pi.xpath("p/date").text.present?
          editor.edited_at = Date.parse pi.xpath("p/date").text
        end
        editor.save!
      end
    else
      if path.xpath("../control/maintenancehistory/maintenanceevent").present?
        path.xpath("../control/maintenancehistory/maintenanceevent").each do |maintenance_event|
          editor = FondEditor.new
          editor.fond_id = fond.id
          editor.name = maintenance_event.xpath("agent").text.squish
          editor.editing_type = import_editing_type(maintenance_event.xpath("eventtype/@value").text)
          if maintenance_event.xpath("eventdatetime").present?
            editor.edited_at = maintenance_event.xpath("eventdatetime").text.squish
          end
          editor.qualifier = import_agent_type(maintenance_event.xpath("agenttype/@value").text)
          editor.db_source = self.identifier
          editor.save
        end
      end
    end

    if path.xpath("controlaccess/genreform").present?
      path.xpath("controlaccess/genreform").each do |fond_document|
        rel__f_d = RelFondDocumentForm.new
        rel__f_d.name = fond_document.xpath("part[@localtype='denominazione']").text.squish
        rel__f_d.description = fond_document.xpath("part[@localtype='descrizione']").text.squish
        rel__f_d.note = fond_document.xpath("part[@localtype='note']").text.squish
        if DocumentForm.where("document_forms.name = ?", rel__f_d.name).first.present?
          rel__f_d.document_form_id = DocumentForm.where("document_forms.name = ?", rel__f_d.name).first[:id]
          rel__f_d.fond_id = fond.id
          rel__f_d.save!
        else
          puts("Nessun DocumentForm trovato con il nome inserito. Non e' stato aggiunto alcun record del tipo 'RelFondDocumentForm'")
        end
      end
    end

    #altre denominazioni
    path.xpath("did/unittitle").each do |unittitle|
      if (unittitle.text != fond.name)
        fond_name = FondName.new
        fond_name.fond_id = fond.id
        fond_name.name = unittitle.text
        fond_name.created_at = datetime
        fond_name.updated_at = datetime
        fond_name.qualifier = "O"
        if unittitle.xpath("@localtype").text == "denominazioneParallela"
          fond_name.note = "Denominazione parallela;"
        end
        if unittitle.xpath("@lang").text.present?
          fond_name.note += " Codice lingua: " + unittitle.xpath("@lang").text
        end

        fond_name.save!
      end
    end

    if path.xpath("did/unitdatestructured/dateset").present?
      event = FondEvent.new
      event.fond_id = fond.id
      import_dateset(path.xpath("did/unitdatestructured/dateset").first, event, datetime)
    end

    if path.xpath("did/unitdatestructured/daterange").present?
      event = FondEvent.new
      event.fond_id = fond.id
      import_dateset(path.xpath("did/unitdatestructured").first, event, datetime)
    end

    # Salvataggio delle informazioni riguardanti le relazioni in campi "di fortuna".
    #if path.xpath("relations/relation").present? && !@is_icar_import
    #  if !fond.related_materials.present?
    #    fond.related_materials = ""
    #  end
    #  path.xpath("relations/relation").each do |relation|
    #    fond.related_materials +=
    #        "relation: {\n
    #         @relationtype: #{relation.xpath("@relationtype").text};\n
    #         @href: #{relation.xpath("@href").text};\n
    #         relationentry: #{relation.xpath("relationentry").text};\n
    #         relationentry/@localtype: #{relation.xpath("relationentry/@localtype").text};
    #          \n}\n"
    #  end
    #end

    # Import per il campo Archimista: Fondo > Altre informazioni > Documentazione collegata
    if path.xpath("relatedmaterials/archref/ref").present?
      if !fond.related_materials.present?
        fond.related_materials = ""
      end
      fond.related_materials += path.xpath("relatedmaterials/archref/ref").text.squish
    end

    source = path.xpath("did/unitid")
    if source.xpath("@identifier").present?
      fond_identifier = FondIdentifier.new
      fond_identifier.fond_id = fond.id
      fond_identifier.identifier = source.xpath("@identifier").text
      #fond_identifier.identifier_source = source.xpath("@localtype").text
      fond_identifier.db_source = self.identifier
      fond_identifier.note = "Identificativo di sistema"
      fond_identifier.save
    end

    # Produttori:
    #if path.xpath("did/origination/corpname").present?
    #  path.xpath("did/origination/corpname").each do |source|
    #    fond_identifier = FondIdentifier.new
    #    fond_identifier.fond_id = fond.id
    #    fond_identifier.identifier = source.xpath("@identifier").text
    #    fond_identifier.identifier_source = ""
    #    fond_identifier.db_source = self.identifier
    #    fond_identifier.note = source.xpath("part").text
    #    fond_identifier.save
    #  end
    #end
    #if path.xpath("did/origination/persname").present?
    #  path.xpath("did/origination/persname").each do |source|
    #    fond_identifier = FondIdentifier.new
    #    fond_identifier.fond_id = fond.id
    #    fond_identifier.identifier = source.xpath("@identifier").text
    #    fond_identifier.identifier_source = ""
    #    fond_identifier.db_source = self.identifier
    #    fond_identifier.note = source.xpath("part").text
    #    fond_identifier.save
    #  end
    #end
    #if path.xpath("did/origination/famname").present?
    #  path.xpath("did/origination/famname").each do |source|
    #    fond_identifier = FondIdentifier.new
    #    fond_identifier.fond_id = fond.id
    #    fond_identifier.identifier = source.xpath("@identifier").text
    #    fond_identifier.identifier_source = ""
    #    fond_identifier.db_source = self.identifier
    #    fond_identifier.note = source.xpath("part").text
    #    fond_identifier.save
    #  end
    #end

    def create_rel_creator_fond_from_origination(path, fond_id, fond_legacy_id, datetime)
      if path.xpath("@identifier").present?
        creator_legacy_id = path.xpath("@identifier").text
        creator_ids = Creator.where(legacy_id: creator_legacy_id).ids
        if creator_ids.present?
          rel_creator_fond = RelCreatorFond.new
          rel_creator_fond.creator_id = creator_ids.first
          rel_creator_fond.fond_id = fond_id
          rel_creator_fond.db_source = self.identifier
          rel_creator_fond.legacy_creator_id = creator_legacy_id
          rel_creator_fond.legacy_fond_id = fond_legacy_id
          rel_creator_fond.created_at = datetime
          rel_creator_fond.updated_at = datetime
          rel_creator_fond.save!
        end
      end
    end

    if path.xpath("did/origination").present?
      path.xpath("did/origination/persname").each do |creator_name|
        create_rel_creator_fond_from_origination(creator_name, fond.id, fond.legacy_id, datetime)
      end
      path.xpath("did/origination/corpname").each do |creator_name|
        create_rel_creator_fond_from_origination(creator_name, fond.id, fond.legacy_id, datetime)
      end
      path.xpath("did/origination/famname").each do |creator_name|
        create_rel_creator_fond_from_origination(creator_name, fond.id, fond.legacy_id, datetime)
      end
    end

    if path.xpath("relations/relation").present?
      path.xpath("relations/relation").each do |relation|
        if relation.xpath("@relationtype").text == "resourcerelation"
          rel_fond_source = RelFondSource.new
          source = Source.find_by(db_source: self.identifier, legacy_id: relation.xpath("@href").text)
          if source.present?
            Rails.logger.info "Risorsa fonte trovata '#{source.short_title}'"
            rel_fond_source.fond_id = fond.id
            rel_fond_source.source_id = source.id
            rel_fond_source.db_source = self.identifier
            rel_fond_source.legacy_source_id = source.legacy_id
            rel_fond_source.legacy_fond_id = fond.legacy_id
            rel_fond_source.save

            source_id = source.id
            source_legacy_id = source.legacy_id

            Rails.logger.info "Relazione (legacy) Fonte #{rel_fond_source.legacy_source_id} ->  Complesso #{rel_fond_source.legacy_fond_id} ricostruita."
          else
            Rails.logger.info "Risorsa fonte NON trovata '#{relation.xpath("@href").text}'"
            source_new = Source.new
            source_new.created_by = user_id
            source_new.updated_by = user_id
            source_new.group_id = group_id
            source_new.created_at = datetime
            source_new.updated_at = datetime
            source_new.db_source = self.identifier
            source_new.legacy_id = fond.legacy_id
            if relation.xpath("relationentry/@localtype").text == "strumentoRicercaInterno"
              source_new.source_type_code = 2 # strumento di corredo
            else
              source_new.source_type_code = 3 # fonte archivistica
            end
            title = relation.xpath("relationentry").text.squish
            source_new.title = title
            source_new.short_title = title.truncate(50, separator: /\s/)
            if Source.where("short_title = '#{source_new.short_title.gsub(/'/, "''")}'").present?
              source_new.sneaky_save
              source_new.short_title << " - #{source_new.id.to_s}"
            end
            source_new.save!
            
            source_id = source_new.id
            source_legacy_id = source_new.legacy_id

            fonte_url = relation.xpath("@href").text
            if fonte_url.present? && fonte_url != ""
              source_url = SourceUrl.new
              source_url.url = fonte_url
              source_url.source_id = source_new.id
              source_url.save!
            end
          
            Rails.logger.info "Risorsa fonte creata '#{source_new.title}'"
          end

          rel_fond_source.fond_id = fond.id
          rel_fond_source.source_id = source_id
          rel_fond_source.db_source = self.identifier
          rel_fond_source.legacy_source_id = source_legacy_id
          rel_fond_source.legacy_fond_id = fond.legacy_id
          rel_fond_source.save

          Rails.logger.info "Relazione (legacy) Fonte #{rel_fond_source.legacy_source_id} ->  Complesso #{rel_fond_source.legacy_fond_id} ricostruita."
        end

        if relation.xpath("@relationtype").text == "otherrelationtype"
          tipo = relation.xpath("@otherrelationtype").text
          title = relation.xpath("relationentry").text.squish

          if tipo == "BIBTEXT" || tipo == "BIBSBN" || tipo == "FONTETEXT" || tipo == "FONTEURI"
            if tipo == "BIBSBN" || tipo == "FONTEURI"
              fonte_url = relation.xpath("@href").text
              if fonte_url.present? && fonte_url != ""
                link = FondUrl .new
                link.db_source = self.identifier
                link.fond_id = fond.id
                link.url = fonte_url
                link.save
              end
            end

            if title.present? && title != ""
              source_by_title = Source.find_by_title(title)
              if source_by_title.nil?
                source = Source.new
                source.created_by = user_id
                source.updated_by = user_id
                source.group_id = group_id
                source.created_at = datetime
                source.updated_at = datetime
                source.db_source = self.identifier
                source.legacy_id = fond.legacy_id
                if tipo == "BIBTEXT" || tipo == "BIBSBN"
                  source.source_type_code = 1 # bibliografia
                elsif tipo == "FONTETEXT" || tipo == "FONTEURI"
                  source.source_type_code = 3 # fonte archivistica
                end
                source.title = title
                source.short_title = title.truncate(50, separator: /\s/)
                if Source.where("short_title = '#{source.short_title.gsub(/'/, "''")}'").present?
                  source.sneaky_save
                  source.short_title << " - #{source.id.to_s}"
                end
                source.save!
                if tipo == "BIBSBN" || tipo == "FONTEURI"
                  fonte_url = relation.xpath("@href").text
                  if fonte_url.present? && fonte_url != ""
                    source_url = SourceUrl.new
                    source_url.url = fonte_url
                    source_url.source_id = source.id
                    source_url.save!
                  end
                end
                source_id = source.id
              else
                source_id = source_by_title.id
              end
              rel_fond_source = RelFondSource.new
              rel_fond_source.fond_id = fond.id
              rel_fond_source.source_id = source_id
              rel_fond_source.save!
            end
          end
        end         
      end
    end


    Rails.logger.info "Salvataggio complesso importato da import.rb > import_fond_from_path"
    fond.save
    Rails.logger.info "Salvataggio complesso COMPLETATO da import.rb > import_fond_from_path"
    return fond
  end

  #Per importare le informazioni presenti nella sezione "control" presente solo per il fondo di root
  #path: xpath("ead/control")
  def import_fond_control_field(path, fond_id)
    if path.xpath("sources").present?
      path.xpath("sources/source").each do |source|
        fond_identifier = FondIdentifier.new
        fond_identifier.fond_id = fond_id
        fond_identifier.identifier = source.xpath("@id").text
        fond_identifier.identifier_source = source.xpath("@href").text
        fond_identifier.note = source.xpath("sourceentry").text
        fond_identifier.save
      end
    end
  end

  def import_icar_import(document, user_id, group_id)
    @is_icar_import = true

    # 0) import schede anagrafiche:
    document.xpath("//icar-import/listRecords/record/recordBody/eac-cpf").each do |anagraphic_root|
      if anagraphic_root.xpath("cpfDescription/identity/entityType").present?
        if anagraphic_root.xpath("cpfDescription/identity/entityType").text == "person" &&
            anagraphic_root.xpath("cpfDescription/identity/entityId/@localType").present?
          returned_bundle = import_anagraphic anagraphic_root.xpath(".."), user_id, group_id
        end
      end
    end

    # 5) import fonti relative ai vari complessi:
    document.xpath("//icar-import/listRecords/record/recordBody/ead").each do |document_source_root|
      if ((document_source_root.xpath("archdesc/did/*").size == 1) &&
          (document_source_root.xpath("archdesc/did/unittitle").text == "") &&
          !document_source_root.xpath("boolean(archdesc/dsc)"))
        returned_bundle = import_source document_source_root.xpath(".."), user_id, group_id

        #returned_bundle[:legacy_fond_ids].each do |legacy_fond_id|
        #  rel_fond_source = RelFondSource.new
        #  fond = Fond.where(db_source: self.identifier, legacy_id: legacy_fond_id)
        #  if fond.present?
        #    rel_fond_source.fond_id = fond.first.id
        #    rel_fond_source.source_id = returned_bundle[:source_id]
        #    rel_fond_source.db_source = self.identifier
        #    rel_fond_source.legacy_source_id = Source.find(rel_fond_source.source_id).legacy_id
        #    rel_fond_source.legacy_fond_id = legacy_fond_id
        #    rel_fond_source.save
        #    Rails.logger.info "Relazione (legacy) Fonte #{rel_fond_source.legacy_source_id} ->  Complesso #{rel_fond_source.legacy_fond_id} ricostruita."
        #  end
        #end

      end
    end

    # import produttori e creazione relaazioni con i complessi/fondi
    document.xpath("//icar-import/listRecords/record/recordBody/eac-cpf").each do |creator_root|
      if creator_root.xpath('cpfDescription/identity/@localType').text == 'soggettoProduttore'
        returned_bundle = import_creator creator_root.xpath(".."), user_id, group_id
        returned_bundle[:legacy_fond_ids].each do |legacy_fond_id|
          rel_creator_fond = RelCreatorFond.new
          rel_creator_fond.creator_id = returned_bundle[:creator_id]
          fond = Fond.where(db_source: self.identifier, legacy_id: legacy_fond_id)
          if fond.present?
            rel_creator_fond.fond_id = fond.first.id
            rel_creator_fond.db_source = self.identifier
            rel_creator_fond.legacy_creator_id = Creator.find(rel_creator_fond.creator_id).legacy_id
            rel_creator_fond.legacy_fond_id = legacy_fond_id
            rel_creator_fond.save
            Rails.logger.info "Relazione (legacy) Produttore #{rel_creator_fond.legacy_creator_id} -> Fondo #{legacy_fond_id} ricostruita."
          end
        end
      end
    end

    # 1.a) import complesso principale e relativi figli
    # 1.b) import unita' relative ai complessi e relazione unita`-scheda anagrafica:
    root_fond_id = nil
    _document_fond_root = document.xpath("//icar-import/listRecords/record/recordBody/ead/archdesc")
    _document_fond_root.each do |document_fond_root|
      if ((document_fond_root.xpath("did/*").size == 1) && (document_fond_root.xpath("did/unittitle").text == "") &&
          !document_fond_root.xpath("boolean(dsc)"))
        Rails.logger.info "Trovata fonte anziche` complesso"
      else
        root_fond_id = import_fond_hierarchy document_fond_root, user_id, group_id, ""
        fonds_to_upload = Fond.where(db_source: self.identifier)
        fonds_to_upload.each do |fond|
          fond.units_count = fond.units.count
          fond.sneaky_update
        end
      end
    end

    # 1.c) import oggetti digitali relativi alle unita':

    # 2) import conservatori relativi al SOLO complesso principale:
    document.xpath("//icar-import/listRecords/record/recordBody/scons").each do |custodian_root|
      rel_custodian_fond = RelCustodianFond.new
      rel_custodian_fond.custodian_id = (import_custodian custodian_root.xpath(".."), user_id, group_id)[:custodian_id]
      rel_custodian_fond.fond_id = root_fond_id
      rel_custodian_fond.db_source = self.identifier
      rel_custodian_fond.legacy_custodian_id = Custodian.find(rel_custodian_fond.custodian_id).legacy_id
      rel_custodian_fond.legacy_fond_id = Fond.find(root_fond_id).legacy_id
      rel_custodian_fond.save
      Rails.logger.info "Relazione (legacy) Conservatore #{rel_custodian_fond.legacy_custodian_id} -> Fondo #{rel_custodian_fond.legacy_fond_id} ricostruita."
    end

    # 4) import profili istituzionali relativi ai produttori:
    document.xpath("//icar-import/listRecords/record/recordBody/eac-cpf").each do |institution_root|
      if institution_root.xpath('cpfDescription/identity/@localType') && institution_root.xpath('cpfDescription/identity/@localType').text == 'profiloIstituzionale'
        returned_bundle = import_institution institution_root.xpath(".."), user_id, group_id
        returned_bundle[:legacy_creator_ids].each do |legacy_creator_id|
          rel_creator_institution = RelCreatorInstitution.new
          creator = Creator.where(db_source: self.identifier, legacy_id: legacy_creator_id)
          if creator.present?
            rel_creator_institution.institution_id = returned_bundle[:institution_id]
            rel_creator_institution.creator_id = creator.first.id
            rel_creator_institution.db_source = self.identifier
            rel_creator_institution.legacy_creator_id = legacy_creator_id
            rel_creator_institution.legacy_institution_id = Institution.find(rel_creator_institution.institution_id).legacy_id
            rel_creator_institution.save
            Rails.logger.info "Relazione (legacy) Produttore #{rel_creator_institution.legacy_creator_id} -> Profilo istituzionale #{rel_creator_institution.legacy_institution_id} ricostruita."
          end
        end
      end
    end

    self.importable_id = root_fond_id
    Rails.logger.info "ICAR-IMPORT relativo al complesso #{root_fond_id} completato -> Inizio salvataggio import "
  end

  #import profilo istituzionale
  #document Nokogiri::XML
  #user_id utente che effettua l'import
  #group_id gruppo dell'utente che effettua l'import
  def import_institution(document, user_id, group_id)
    institution = Institution.new
    if document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part").present?
      institution.name = document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part").first.text #denominazione
    elsif document.xpath("eac-cpf/cpfDescription/identity/nameEntryParallel/nameEntry/part").present?
      institution.name = document.xpath("eac-cpf/cpfDescription/identity/nameEntryParallel/nameEntry/part").first.text #denominazione
    end
    if document.xpath("eac-cpf/cpfDescription/description/biogHist/p").present?
      institution.description = document.xpath("eac-cpf/cpfDescription/description/biogHist/p").first.text.squish #descrizione
    end

    document.xpath("eac-cpf/cpfDescription/identity/nameEntryParallel/nameEntry").each do |nameEntry|
      attr_name = nameEntry.xpath("name(@*)").squish
      attr_value = nameEntry.xpath("@*").text.squish
      if (attr_name.include? "lang") && (attr_value != "ita")
        institution_description = institution.description.nil? ? "" : (institution.description + "\n")
        institution.description = institution_description + "Denominazione parallela: " + nameEntry.xpath("part").text.squish + " [codice lingua: #{attr_value}]"
      end
    end

    document.xpath("eac-cpf/cpfDescription/description/localDescription").each do |localDescription|
      if localDescription.xpath("@localType").text == "tipologiaEnte"
        term = localDescription.xpath("term")
        if term.present? && term.xpath("@vocabularySource").text == "http://dati.san.beniculturali.it/SAN/TesauroSAN/sottotipologia_ente"
          institution_description = institution.description.nil? ? "" : (institution.description + "\n")
          institution.description = institution_description + "Tipologia ente: " + term.text.squish
        end
      end
    end

    document.xpath("eac-cpf/cpfDescription/description/legalStatuses").each do |legalStatuses|
      term = legalStatuses.xpath("legalStatus/term")
      if term.present?
        institution_description = institution.description.nil? ? "" : (institution.description + "\n")
        institution.description = institution_description + "Condizione giuridica: " + term.text.squish
      end
    end

    date_range = document.xpath("eac-cpf/cpfDescription/description/existDates/dateRange")
    if date_range.present? && date_range.xpath("@localType").text == "data di esistenza"
      exist_date = "-"
      from_Date = date_range.xpath("fromDate")
      to_Date = date_range.xpath("toDate")
      if from_Date.present?
        exist_date = from_Date.text.squish + exist_date
      end
      if to_Date.present?
        exist_date = exist_date + to_Date.text.squish
      end
      if exist_date != "-"
        institution_description = institution.description.nil? ? "" : (institution.description + "\n")
        institution.description = institution_description + "Date di esistenza: " + exist_date
      end
    end

    # vale per: Sede, Giurisdizione, Ambito territoriale e altri tag place con figli placeRole e placeEntry presenti
    document.xpath("eac-cpf/cpfDescription/description/place").each do |place|
      placeRole = place.xpath("placeRole")
      placeEntry = place.xpath("placeEntry")
      if placeRole.present? && placeEntry.present?
        institution_description = institution.description.nil? ? "" : (institution.description + "\n")
        institution.description = institution_description + placeRole.text.squish.capitalize + ": " + placeEntry.text.squish
      end
    end

    document.xpath("eac-cpf/cpfDescription/relations").each do |relations|
      # Profilo istituzionale associato
      cpf_relation = relations.xpath("cpfRelation")
      if cpf_relation.present? && cpf_relation.xpath("@cpfRelationType").text == "associative"
        relation_entry = cpf_relation.xpath("relationEntry")
        if relation_entry.present? && relation_entry.xpath("@localType").text == "profiloIstituzionale"
          institution_description = institution.description.nil? ? "" : (institution.description + "\n")
          institution.description = institution_description + "Profilo istituzionale associato: " + relation_entry.text.squish
          end
      end
      
      # Contesto Storico istituzionale e Ambito territoriale
      relations.xpath("resourceRelation").each do |resourceRelation|
        if resourceRelation.xpath("@resourceRelationType").text == "other"
          relation_entry = resourceRelation.xpath("relationEntry")
          if relation_entry.present?
            case relation_entry.xpath("@localType").text
            when "ambitoTerritoriale"
              label = "Ambito territoriale: "
              value = relation_entry.text.squish
              institution_description = institution.description.nil? ? "" : (institution.description + "\n")
              institution.description = institution_description + label + value
            when "contestoStoricoIstituzionale"
              label = "Contesto storico istituzionale: "
              value = relation_entry.text.squish
              institution_description = institution.description.nil? ? "" : (institution.description + "\n")
              institution.description = institution_description + label + value
            end
          end
        end
      end
    end

    institution.legacy_id = document.xpath("eac-cpf/control/recordId").text
    institution.note = ""
    institution.created_by = user_id
    institution.updated_by = user_id
    institution.group_id = group_id
    institution.db_source = self.identifier
    institution.save!

    self.importable_id = institution.id

    #compilatori
    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    document.xpath("eac-cpf/control/maintenanceHistory/maintenanceEvent").each do |editor|
      event_type = editor.xpath("eventType").first.text
      event_datetime = ""
      if editor.xpath("eventDateTime").present?
        if editor.xpath("eventDateTime/@standardDateTime").present?
          event_datetime = editor.xpath("eventDateTime/@standardDateTime").first.text
        else
          event_datetime = editor.xpath("eventDateTime").first.text
        end

      end
      agent_type = import_agent_type(editor.xpath("agentType").first.text)
      agent = editor.xpath("agent").first.text
      event_description_present = editor.xpath("boolean(eventDescription)")

      if ((event_type == "created") && (event_datetime == "") && (agent_type == "human") && (agent == "") && !event_description_present)
        #ogni entità ha un evento di compilazione di default di questo tipo
        #  <maintenanceEvent>
        #    <eventType>created</eventType>
        #    <eventDateTime></eventDateTime>
        #    <agentType>human</agentType>
        #    <agent></agent>
        #  </maintenanceEvent>
        #nell'import è ignorato
        next
      else
        institution_editor = InstitutionEditor.new
        institution_editor.institution_id = institution.id
        institution_editor.name = agent
        institution_editor.editing_type = import_editing_type(event_type)
        institution_editor.qualifier = agent_type
        if !event_datetime.empty?
          institution_editor.edited_at = Date.parse(event_datetime)
        end
        institution_editor.created_at = datetime
        institution_editor.updated_at = datetime
        if event_description_present
          institution_editor.qualifier = editor.xpath("eventDescription").first.text
        end
        institution_editor.save!
      end
    end
    return_bundle = {institution_id: institution.id, legacy_creator_ids: Array.new}
    # ripristina eventuali relazioni con dei produttori
    if document.xpath("eac-cpf/cpfDescription/relations/cpfRelation/relationEntry[@localType='soggettoProduttore']").present?
      Rails.logger.info "Associazione profilo istituzionale #{institution.id} al produttore"
      document.xpath("eac-cpf/cpfDescription/relations/cpfRelation/relationEntry[@localType='soggettoProduttore']").each do |related_creator|
        return_bundle[:legacy_creator_ids].push related_creator.text
        Rails.logger.info "Associazione produttore con legacy_id #{related_creator.text}"
      end
    end
    return return_bundle
  end

  #import soggetto produttore
  #document Nokogiri::XML
  #user_id utente che effettua l'import
  #group_id gruppo dell'utente che effettua l'import
  def import_creator(document, user_id, group_id)
    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    creator = Creator.new

    localType = document.xpath("eac-cpf/cpfDescription/identity/entityType").first.text
    if (localType == "corporateBody")
      creator.creator_type = "C" #tipologia

      corporate_type = ""
      if document.xpath("eac-cpf/cpfDescription/description/localDescription/term").present?
        description = document.xpath("eac-cpf/cpfDescription/description/localDescription/term").first.text
        case description
        when "TesauroSAN/opera_pia-istituzione_ed_ente_assistenza_e_beneficenza_ospedale"
          corporate_type = "ente di assistenza e beneficenza"
        when "TesauroSAN/banca-istituto_di_credito-ente_assicurativo-ente_previdenziale"
          corporate_type = "ente di credito, assicurativo, previdenziale"
        when "TesauroSAN/accademia_ente_di_cultura"
          corporate_type = "ente di cultura, ricreativo, sportivo, turistico"
        when "TesauroSAN/ente_ricreativo-sportivo-turistico_sp"
          corporate_type = "ente di cultura, ricreativo, sportivo, turistico"
        when "TesauroSAN/scuola-ente_di_istruzione"
          corporate_type = "ente di istruzione e ricerca"
        when "TesauroSAN/universita-ente_di_ricerca"
          corporate_type = "ente di istruzione e ricerca"
        when "TesauroSAN/ente_culto_cattolico-associazione_cattolica"
          corporate_type = "ente e associazione della chiesa cattolica"
        when "TesauroSAN/ente_di_culto_acattolico-associazione_acattolica"
          corporate_type = "ente e associazione di culto acattolico"
        when "TesauroSAN/corporazione_religiosa"
          corporate_type = "ente ecclesiastico"
        when "TesauroSAN/ente_economico-impresa-studio_professionale_sp"
          corporate_type = "ente economico / impresa"
          #when "TesauroSAN/ente_territoriale_minore"
          #corporate_type = "ente funzionale territoriale"
        when "TesauroSAN/ente_territoriale_minore"
          corporate_type = "ente pubblico territoriale"
        when "TesauroSAN/ente_sanitario-ente_servizi_alla_persona"
          corporate_type = "ente sanitario"
        when "TesauroSAN/arte_ordine_collegio_associazione_di_categoria"
          corporate_type = "ordine professionale, associazione di categoria"
        when "TesauroSAN/organo_e_ufficio_statale_periferico_di_periodo_postunitario"
          corporate_type = "organo periferico dello stato"
        when "TesauroSAN/partito_e_movimento_politico-associazione_politica"
          corporate_type = "partito politico, organizzazione sindacale"
        when "TesauroSAN/organo_e_ufficio_statale_centrale_del_periodo_preunitario"
          corporate_type = "preunitario"
        when "TesauroSAN/regione-regione_a_statuto_speciale_sp"
          corporate_type = "regione"
          #when "TesauroSAN/statali"
          #corporate_type = "organo giudiziario"
        when "TesauroSAN/statali"
          corporate_type = "stato"

        when "opera_pia-istituzione_ed_ente_assistenza_e_beneficenza_ospedale"
          corporate_type = "ente di assistenza e beneficenza"
        when "banca-istituto_di_credito-ente_assicurativo-ente_previdenziale"
          corporate_type = "ente di credito, assicurativo, previdenziale"
        when "accademia_ente_di_cultura"
          corporate_type = "ente di cultura, ricreativo, sportivo, turistico"
        when "ente_ricreativo-sportivo-turistico_sp"
          corporate_type = "ente di cultura, ricreativo, sportivo, turistico"
        when "scuola-ente_di_istruzione"
          corporate_type = "ente di istruzione e ricerca"
        when "universita-ente_di_ricerca"
          corporate_type = "ente di istruzione e ricerca"
        when "ente_culto_cattolico-associazione_cattolica"
          corporate_type = "ente e associazione della chiesa cattolica"
        when "ente_di_culto_acattolico-associazione_acattolica"
          corporate_type = "ente e associazione di culto acattolico"
        when "corporazione_religiosa"
          corporate_type = "ente ecclesiastico"
        when "ente_economico-impresa-studio_professionale_sp"
          corporate_type = "ente economico / impresa"
          #when "ente_territoriale_minore"
          #corporate_type = "ente funzionale territoriale"
        when "ente_territoriale_minore"
          corporate_type = "ente pubblico territoriale"
        when "ente_sanitario-ente_servizi_alla_persona"
          corporate_type = "ente sanitario"
        when "arte_ordine_collegio_associazione_di_categoria"
          corporate_type = "ordine professionale, associazione di categoria"
        when "organo_e_ufficio_statale_periferico_di_periodo_postunitario"
          corporate_type = "organo periferico dello stato"
        when "partito_e_movimento_politico-associazione_politica"
          corporate_type = "partito politico, organizzazione sindacale"
        when "organo_e_ufficio_statale_centrale_del_periodo_preunitario"
          corporate_type = "preunitario"
        when "regione-regione_a_statuto_speciale_sp"
          corporate_type = "regione"
          #when "statali"
          #corporate_type = "organo giudiziario"
        when "statali"
          corporate_type = "stato"
        end

        corporate_type_from_db = CreatorCorporateType.select(:id).where(:corporate_type => corporate_type)
        if !corporate_type_from_db.empty?
          creator.creator_corporate_type_id = corporate_type_from_db.first.id
        end
      end
    elsif (localType == "person")
      creator.creator_type = "P"
    elsif (localType == "family")
      creator.creator_type = "F"
    end

    if document.xpath("eac-cpf/cpfDescription/description/biogHist/abstract").present?
      creator.abstract = document.xpath("eac-cpf/cpfDescription/description/biogHist/abstract").first.text.squish
    end

    if document.xpath("eac-cpf/cpfDescription/description/biogHist/p").present?
      creator.history = document.xpath("eac-cpf/cpfDescription/description/biogHist/p").first.text.squish
    end

    creator.legacy_id = document.xpath("eac-cpf/control/recordId").text
    creator.db_source = self.identifier
    creator.created_by = user_id
    creator.updated_by = user_id
    creator.group_id = group_id
    creator.created_at = datetime
    creator.updated_at = datetime
    creator.sneaky_save!
    self.importable_id = creator.id

    document.xpath("eac-cpf/cpfDescription/relations/resourceRelation").each do |resourceRelation|
      if resourceRelation.xpath("relationEntry/@localType").text == "URI"
        creator_url = CreatorUrl.new
        creator_url.creator_id = creator.id
        creator_url.url = resourceRelation.xpath("@href").text
        creator_url.note = resourceRelation.xpath("relationEntry").text
        creator_url.created_at = datetime
        creator_url.updated_at = datetime
        creator_url.save!
      end

      if resourceRelation.xpath("@resourceRelationType").text == "creatorOf" && resourceRelation.xpath("relationEntry/@localType").text == "complesso"
        creator_of_complesso = resourceRelation.xpath("relationEntry").text.squish
        if creator_of_complesso[0..3] != "http"
          fond_by_legacy_id = Fond.find_by_legacy_id(creator_of_complesso)
          if !fond_by_legacy_id.nil?
            rel_creator_fond = RelCreatorFond.new
            rel_creator_fond.legacy_creator_id = creator.legacy_id
            rel_creator_fond.legacy_fond_id = fond_by_legacy_id.legacy_id
            rel_creator_fond.creator_id = creator.id
            rel_creator_fond.fond_id = fond_by_legacy_id.id
            rel_creator_fond.created_at = datetime
            rel_creator_fond.updated_at = datetime
            rel_creator_fond.save!
          end
        end
      end

      if resourceRelation.xpath("relationEntry/@localType").text == "contestoStoricoIstituzionale"
        if resourceRelation.xpath("relationEntry").text[0..3] != "http"
          contesto_storico_istituzionale = "Contesto storico istituzionale: " + resourceRelation.xpath("relationEntry").text.squish
          if creator.history.nil?
            creator.history = contesto_storico_istituzionale
          else
            creator.history += ("\n" + contesto_storico_istituzionale)
          end
        else
          creator_url = CreatorUrl.new
          creator_url.creator_id = creator.id
          creator_url.url = resourceRelation.xpath("relationEntry").text.squish
          creator_url.note = "Contesto storico istituzionale"
          creator_url.created_at = datetime
          creator_url.updated_at = datetime
          creator_url.save!
        end
      end

      if resourceRelation.xpath("relationEntry/@localType").text == "ambitoTerritoriale"
        if resourceRelation.xpath("relationEntry").text[0..3] != "http"
          ambito_territoriale = "Ambito territoriale: " + resourceRelation.xpath("relationEntry").text.squish
          if creator.history.nil?
            creator.history = ambito_territoriale
          else
            creator.history += ("\n" + ambito_territoriale)
          end
        else
          creator_url = CreatorUrl.new
          creator_url.creator_id = creator.id
          creator_url.url = resourceRelation.xpath("relationEntry").text.squish
          creator_url.note = "Ambito territoriale"
          creator_url.created_at = datetime
          creator_url.updated_at = datetime
          creator_url.save!
        end
      end
    end

    if document.xpath("eac-cpf/control/recordId").present?
      creator_identifier = CreatorIdentifier.new
      creator_identifier.creator_id = creator.id
      creator_identifier.identifier = document.xpath("eac-cpf/control/recordId").text
      creator_identifier.identifier_source = CGI.unescape(document.xpath("eac-cpf/control/recordId/@localType").text)
      creator_identifier.note = "Identificativo di sistema"
      creator_identifier.created_at = datetime
      creator_identifier.updated_at = datetime
      creator_identifier.save!
    end

    document.xpath("eac-cpf/control/otherRecordId").each do |otherRecordId|
      creator_identifier = CreatorIdentifier.new
      creator_identifier.creator_id = creator.id
      creator_identifier.identifier = otherRecordId.text
      creator_identifier.identifier_source = CGI.unescape(otherRecordId.xpath("@localType").text)
      creator_identifier.created_at = datetime
      creator_identifier.updated_at = datetime
      creator_identifier.save!
    end

    document.xpath("eac-cpf/control/maintenanceHistory/maintenanceEvent").each do |editor|
      event_type = editor.xpath("eventType").first.text
      if editor.xpath("eventDateTime/@standardDateTime").present?
        date_format = 'YMD'
        event_datetime = editor.xpath("eventDateTime/@standardDateTime").first.text
        if event_datetime.size == 4
          dateFormat = 'Y'
          event_datetime << "-01-01"
        elsif event_datetime.size == 7
          date_format = 'YM'
          event_datetime << "-01"
        end
      else
        event_datetime = editor.xpath("eventDateTime").first.text
      end
      agent_type = import_agent_type(editor.xpath("agentType").first.text)
      agent = editor.xpath("agent").first.text
      event_description_present = editor.xpath("boolean(eventDescription)")

      if ((event_type == "created") && (event_datetime == "") && (agent_type == "human") && (agent == "") && !event_description_present)
        #ogni entità ha un evento di compilazione di default di questo tipo
        #  <maintenanceEvent>
        #    <eventType>created</eventType>
        #    <eventDateTime></eventDateTime>
        #    <agentType>human</agentType>
        #    <agent></agent>
        #  </maintenanceEvent>
        #nell'import è ignorato
        next
      else
        editor_model = CreatorEditor.new
        editor_model.creator_id = creator.id
        editor_model.name = agent
        editor_model.editing_type = import_editing_type(event_type)
        if !event_datetime.empty?
          editor_model.edited_at = Date.parse(event_datetime)
        end
        editor_model.created_at = datetime
        editor_model.updated_at = datetime
        editor_model.qualifier = agent_type
        #TODO creazione attributo per date_format.
        editor_model.save!
      end
    end

    if creator.is_corporate?
      if document.xpath("eac-cpf/cpfDescription/identity/nameEntryParallel").present?
        #denominazione principale e denominazioni parallele
        document.xpath("eac-cpf/cpfDescription/identity/nameEntryParallel/nameEntry").each do |nameEntry|
          nameEntry_part = nameEntry.xpath("part").first

          creator_name = CreatorName.new
          creator_name.creator_id = creator.id
          creator_name.name = nameEntry_part.text

          if CreatorName.where(creator_id: creator.id).present?
            #denominazione parallela
            creator_name.preferred = false
            creator_name.qualifier = "PA"
          else
            #denominazione principale (se e` la prima denominazione salvata).
            creator_name.preferred = true
            creator_name.qualifier = "A"
          end

          begin
            if nameEntry.xpath("@lang").present?
              lang = nameEntry.xpath("@lang").text
            elsif nameEntry.xpath("@xml:lang").present?
              lang = nameEntry.xpath("@xml:lang").text
            end
            if lang.present?
              creator_name.note = "codice lingua: " + lang
            end
          rescue
            Rails.logger.info "sigla della lingua non trovata"
            creator_name.note = "codice lingua: " + lang
          end

          creator_name.created_at = datetime
          creator_name.updated_at = datetime
          creator_name.save!
        end

        # altre denominazioni
        #document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part").each do |nameEntry|
        #  creator_name = CreatorName.new
        #  creator_name.creator_id = creator.id
        #  creator_name.name = nameEntry.text
        #  creator_name.preferred = false
        #  creator_name.qualifier = import_qualifer_type(nameEntry.xpath("@localType").text)
        #  creator_name.note = ""
        #  creator_name.created_at = datetime
        #  creator_name.updated_at = datetime
        #  creator_name.save!
        #end

      else
        #non sono presenti denominazioni parallele
        preferred_name_already_set = false
        document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part").each do |nameEntry|
          creator_name = CreatorName.new
          creator_name.creator_id = creator.id
          creator_name.name = nameEntry.text
          if (nameEntry.xpath("boolean(@localType)") || preferred_name_already_set)
            #altra denominazione
            creator_name.preferred = false
            creator_name.qualifier = import_qualifer_type(nameEntry.xpath("@localType").text)
          else
            #denominazione principale
            creator_name.preferred = true
            creator_name.qualifier = "A"
            preferred_name_already_set = true
          end

          creator_name.note = ""
          
          if nameEntry.xpath("../useDates/date").present?
            creator_name_date = nameEntry.xpath("../useDates/date").text.squish

            if creator_name_date != ""
              if !creator_name.name.nil?
                if creator_name.name != ""
                  creator_name.name += " "
                end
                creator_name.name += "(" + creator_name_date + ")" 
              else
                creator_name.name = "(" + creator_name_date + ")" 
              end
            end
          end

          creator_name.created_at = datetime
          creator_name.updated_at = datetime
          creator_name.save!
        end
      end

      document.xpath("eac-cpf/cpfDescription/description/legalStatuses/legalStatus").each do |legalStatus|
        legalStatus_text = legalStatus.xpath("term").text
        if legalStatus_text == "Pubblico"
          legalStatus_id = "PU"
        elsif legalStatus_text == "Privato"
          legalStatus_id = "PR"
        elsif legalStatus_text == "Ecclesiastico"
          legalStatus_id = "EC"
        else
          legalStatus_id = "NA"
        end

        creator_legal_status = CreatorLegalStatus.new
        creator_legal_status.creator_id = creator.id
        creator_legal_status.legal_status = legalStatus_id
        creator_legal_status.created_at = datetime
        creator_legal_status.updated_at = datetime
        creator_legal_status.save!
      end

      if document.xpath("eac-cpf/cpfDescription/description/existDates").present?
        event = CreatorEvent.new
        event.creator_id = creator.id
        import_dateset(document.xpath("eac-cpf/cpfDescription/description/existDates").first, event, datetime)

        event.save!
      end

      document.xpath("eac-cpf/cpfDescription/description/place").each do |place|
        placerole_voc_src = place.xpath("placeRole/@vocabularySource").text
        tipo_luogo_CPF_URL = "http://dati.san.beniculturali.it/SAN/TesauroSAN/Tipo_luogo_CPF"
        placerole_tag = place.xpath("placeRole").text
        if (placerole_voc_src != tipo_luogo_CPF_URL && placerole_tag == "Sede") ||
           (placerole_voc_src == tipo_luogo_CPF_URL && placerole_tag == "TesauroSAN/sede")
          creator.residence = place.xpath("placeEntry").text.squish
        end
      end
    elsif creator.is_person?
      firstnameFound = false
      lastnameFound = false

      creator_name = CreatorName.new
      creator_name.creator_id = creator.id
      if document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part[@localType='nome']").present?
        creator_name.first_name = document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part[@localType='nome']").first.text
        firstnameFound = true
      end

      if document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part[@localType='cognome']").present?
        creator_name.last_name = document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part[@localType='cognome']").first.text
        lastnameFound = true
      end

      if document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part[@localType='denominazione']").present? ||
          document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part[@localType='intestazione']").present?
        #denominazione principale
        if document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part[@localType='denominazione']").present?
          name = document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part[@localType='denominazione']").first.text
        else
          name = document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part[@localType='intestazione']").first.text
        end

        creator_name.name = name
        if name.include?(",")
          name_parts = name.split(",")
          if (!lastnameFound)
            creator_name.last_name = name_parts[0].strip
          end
          if (!firstnameFound)
            creator_name.first_name = name_parts[1].strip
          end
        else
          if (!lastnameFound)
            creator_name.last_name = name
          end
          if (!firstnameFound)
            creator_name.first_name = ""
          end
        end
      end

      if (!creator_name.name.empty?)
        creator_name.preferred = true
        creator_name.qualifier = "A"
        creator_name.note = ""
        creator_name.created_at = datetime
        creator_name.updated_at = datetime
        creator_name.save!
      end

      document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part").each do |nameEntry|
        if (nameEntry.xpath("boolean(@localType)"))
          if (nameEntry.xpath("@localType").text == "denominazione" ||
              #nameEntry.xpath("@localType").text == "intestazione" ||
              nameEntry.xpath("@localType").text == "cognome" ||
              nameEntry.xpath("@localType").text == "nome")
            next
          end

          creator_name = CreatorName.new
          creator_name.creator_id = creator.id

          name = nameEntry.text
          creator_name.name = name
          #altra denominazione
          creator_name.preferred = false
          creator_name.qualifier = "OT"

          case nameEntry.xpath("@localType").text.downcase
          when "intestazione"
            creator_name.qualifier = "IN"
          when "patronimico"
            creator_name.qualifier = "PT"
          when "soprannome"
            creator_name.qualifier = "SN"
          when "pseudonimo"
            creator_name.qualifier = "AL"
          when "alias"
            creator_name.qualifier = "AL"
          else
            creator_name.note = nameEntry.xpath("@localType").text.downcase
          end

          creator_name.created_at = datetime
          creator_name.updated_at = datetime
          creator_name.save!
        end
      end

      if (document.xpath("eac-cpf/cpfDescription/description/existDates").present? || document.xpath("eac-cpf/cpfDescription/description/place").present?)
        event = CreatorEvent.new
        event.creator_id = creator.id

        if document.xpath("eac-cpf/cpfDescription/description/existDates").present?
          import_dateset(document.xpath("eac-cpf/cpfDescription/description/existDates").first, event, datetime)
        end

        document.xpath("eac-cpf/cpfDescription/description/place").each do |place|
          if (place.xpath("placeRole").text == "TesauroSAN/luogo di nascita")
            event.start_date_place = place.xpath("placeEntry").text
          elsif (place.xpath("placeRole").text == "TesauroSAN/luogo di morte")
            event.end_date_place = place.xpath("placeEntry").text
          end
        end

        event.save!
      end
    elsif creator.is_family?
      document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part").each do |nameEntry|
        creator_name = CreatorName.new
        creator_name.creator_id = creator.id
        creator_name.name = nameEntry.text
        creator_name.note = ""
        if (nameEntry.xpath("boolean(@localType)"))
          #altra denominazione
          creator_name.preferred = false
          creator_name.qualifier = "OT"

          case nameEntry.xpath("@localType").text.downcase
          when "intestazione"
            creator_name.qualifier = "IN"
          when "patronimico"
            creator_name.qualifier = "PT"
          when "soprannome"
            creator_name.qualifier = "SN"
          when "pseudonimo"
            creator_name.qualifier = "AL"
          when "alias"
            creator_name.qualifier = "AL"
          else
            creator_name.note = nameEntry.xpath("@localType").text.downcase
          end
        else
          #denominazione principale
          creator_name.preferred = true
          creator_name.qualifier = "A"
        end
        creator_name.created_at = datetime
        creator_name.updated_at = datetime
        creator_name.save!
      end

      if document.xpath("eac-cpf/cpfDescription/description/existDates").present?
        event = CreatorEvent.new
        event.creator_id = creator.id
        import_dateset(document.xpath("eac-cpf/cpfDescription/description/existDates").first, event, datetime)

        event.save!
      end
    end

    # Extra "Tipo_luogo" per tutti i tipi di produttore
    document.xpath("eac-cpf/cpfDescription/description/place").each do |place|
      if place.xpath("placeRole/@vocabularySource").text == "http://dati.san.beniculturali.it/SAN/TesauroSAN/Tipo_luogo_CPF"
        creator_history = creator.history.nil? ? "" : (creator.history + "\n")
        placeRole_text = place.xpath("placeRole").text
        placEntry_label = placeRole_text.squish.capitalize + ": "
        if (placeRole_text != "sede" && placeRole_text != "TesauroSAN/sede") || creator.residence.nil?
          creator.history = creator_history + placEntry_label + place.xpath("placeEntry[count(@*)=0]").text.squish
        end
      end
    end

    if document.xpath("eac-cpf/cpfDescription/relations/cpfRelation").present? && !@is_icar_import
      Rails.logger.info "Sono presenti relazioni <cpfRelation> non ricostruibili per il produttore #{creator.id}"
      if !creator.note.present?
        #creator.note = ""
      end
      document.xpath("eac-cpf/cpfDescription/relations/cpfRelation").each do |relation|
        if relation.xpath("relationEntry").text[0..3] == "http"
          link = CreatorUrl.new
          link.db_source = self.identifier
          link.creator_id = creator.id
          link.url = relation.xpath("relationEntry").text
          link.note = relation.xpath("relationEntry/@localType").text
          link.save
        else
          #creator.note += "#{relation.xpath("relationEntry/@localType").text}: #{relation.xpath("relationEntry").text}\n;"
        end
      end
    end

    if document.xpath("eac-cpf/cpfDescription/relations/resourceRelation").present? && !@is_icar_import
      Rails.logger.info "Sono presenti relazioni <resourceRelation> non ricostruibili per il produttore #{creator.id}"

      document.xpath("eac-cpf/cpfDescription/relations/resourceRelation").each do |relation|
        if relation.xpath("relationEntry").text[0..3] == "http"
          note = relation.xpath("relationEntry/@localType").text
          if (note != "contestoStoricoIstituzionale" && note != "ambitoTerritoriale")
            link = CreatorUrl.new
            link.db_source = self.identifier
            link.creator_id = creator.id
            link.url = relation.xpath("relationEntry").text
            link.note = note
            link.save
          end
        end

        tipo = relation.xpath("relationEntry/@localType").text
        if tipo == "BIBTEXT" || tipo == "BIBSBN" || tipo == "FONTEURI" || tipo == "FONTETEXT"
          title = relation.xpath("relationEntry").text.squish

          if tipo == "BIBSBN" || tipo == "FONTEURI"
            source_url = relation.xpath("@href").text
            if source_url.present? && source_url != ""
              link = CreatorUrl.new
              link.db_source = self.identifier
              link.creator_id = creator.id
              link.url = source_url
              link.save
            end
          end

          if title.present? && title != ""
            source_by_title = Source.find_by_title(title)
            if source_by_title.nil?
              source = Source.new
              datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
              source.created_by = user_id
              source.updated_by = user_id
              source.group_id = group_id
              source.created_at = datetime
              source.updated_at = datetime
              source.db_source = self.identifier
              source.legacy_id = document.xpath("eac-cpf/control/recordId").text
              if tipo == "BIBTEXT" || tipo == "BIBSBN"
                  source.source_type_code = 1 # bibliografia
              elsif tipo == "FONTETEXT" || tipo == "FONTEURI"
                source.source_type_code = 3 # fonte archivistica
              end
              source.title = title
              source.short_title = title.truncate(50, separator: /\s/)
              if Source.where("short_title = '#{source.short_title.gsub(/'/, "''")}'").present?
                source.sneaky_save
                source.short_title << " - #{source.id.to_s}"
              end
              source.save!
              if tipo == "BIBSBN" || tipo == "FONTEURI"
                fonte_url = relation.xpath("@href").text
                if fonte_url.present? && fonte_url != ""
                  source_url = SourceUrl.new
                  source_url.url = fonte_url
                  source_url.source_id = source.id
                  source_url.save!
                end
              end
              source_id = source.id
            else
              source_id = source_by_title.id
            end
            rel_creator_source = RelCreatorSource.new
            rel_creator_source.creator_id = creator.id
            rel_creator_source.source_id = source_id
            rel_creator_source.save!
          end
        end
      end
    end

    creator.save!
    Rails.logger.info "Produttore #{creator.id} salvato"

    return_bundle = {creator_id: creator.id, legacy_fond_ids: Array.new}
    # ripristina eventuali relazioni con dei complessi
    if document.xpath("eac-cpf/cpfDescription/relations/resourceRelation/relationEntry[@localType='complesso']").present?
      Rails.logger.info "Associazione complessi al produttore #{creator.id}"
      document.xpath("eac-cpf/cpfDescription/relations/resourceRelation/relationEntry[@localType='complesso']").each do |related_fond|
        return_bundle[:legacy_fond_ids].push related_fond.text
        Rails.logger.info "Associazione complesso con legacy_id #{related_fond.text[3..10].to_i.to_s}"
      end
    end

    return return_bundle
  end

  #import scheda anagrafica
  #document Nokogiri::XML
  #user_id utente che effettua l'import
  #group_id gruppo dell'utente che effettua l'import
  def import_anagraphic(document, user_id, group_id)
    Rails.logger.info "import_anagraphic start"
    Rails.logger.info document
    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    anagraphic = Anagraphic.new

    document.xpath("eac-cpf/cpfDescription/identity/nameEntry/part").each do |nameEntry|
      if (nameEntry.xpath("@localType").text == "cognome")
        anagraphic.surname = nameEntry.text
      else
        anagraphic.name = nameEntry.text
      end
    end

    if document.xpath("eac-cpf/cpfDescription/description/existDates/dateRange/fromDate").present?
      anagraphic.start_date = document.xpath("eac-cpf/cpfDescription/description/existDates/dateRange/fromDate/@standardDate").first.text
    end

    if document.xpath("eac-cpf/cpfDescription/description/existDates/dateRange/toDate").present?
      anagraphic.end_date = document.xpath("eac-cpf/cpfDescription/description/existDates/dateRange/toDate/@standardDate").first.text
    end

    document.xpath("eac-cpf/cpfDescription/description/place").each do |place|
      if (place.xpath("placeRole").text == "TesauroSAN/luogo di nascita")
        anagraphic.start_date_place = place.xpath("placeEntry").text
      elsif (place.xpath("placeRole").text == "TesauroSAN/luogo di morte")
        anagraphic.end_date_place = place.xpath("placeEntry").text
      end
    end

    anagraphic.legacy_id = document.xpath("eac-cpf/control/recordId").text
    anagraphic.db_source = self.identifier
    anagraphic.group_id = group_id
    anagraphic.created_at = datetime
    anagraphic.updated_at = datetime
    anagraphic.sneaky_save!

    self.importable_id = anagraphic.id

    document.xpath("eac-cpf/control/otherRecordId").each do |otherRecordId|
      anag_identifier = AnagIdentifier.new
      anag_identifier.anagraphic_id = anagraphic.id
      anag_identifier.identifier = otherRecordId.text
      anag_identifier.qualifier = CGI.unescape(otherRecordId.xpath("@localType").text)
      anag_identifier.created_at = datetime
      anag_identifier.updated_at = datetime
      anag_identifier.save!
    end

    anagraphic.save
    return_bundle = {anagraphic_id: anagraphic.id}
    return return_bundle
  end

  #import soggetti conservatore
  #document Nokogiri::XML
  #user_id utente che effettua l'import
  #group_id gruppo dell'utente che effettua l'import
  def import_custodian(document, user_id, group_id)
    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    custodian = Custodian.new

    custodian_type = ""
    description = document.xpath("scons/tipologia").first.text
    case description
    when "TesauroSAN/archivio_di_Stato"
      custodian_type = "stato"
    when "TesauroSAN/regione-regione_a_statuto_speciale_conservatore"
      custodian_type = "regione"
    when "TesauroSAN/ente_territoriale"
      custodian_type = "ente pubblico territoriale"
    when "TesauroSAN/ente_diverso"
      custodian_type = "ente funzionale territoriale"
    when "TesauroSAN/ente_economico-impresa-studio_professionale_conservatore"
      custodian_type = "ente economico / impresa"
    when "TesauroSAN/istituto_di_credito"
      custodian_type = "ente di credito, assicurativo, previdenziale"
    when "TesauroSAN/ente_di_assistenza-beneficenza-previdenza-servizi_alla_persona"
      custodian_type = "ente di assistenza e beneficenza"
    when "TesauroSAN/ente_sanitario"
      custodian_type = "ente sanitario"
    when "TesauroSAN/ente_di_cultura-ente_di_ricerca"
      custodian_type = "ente di istruzione e ricerca"
    when "TesauroSAN/ente_ricreativo-sportivo-turistico_conservatore"
      custodian_type = "ente di cultura, ricreativo, sportivo, turistico"
    when "TesauroSAN/sindacato-organizzazione_sindacale_conservatore"
      custodian_type = "partito politico, organizzazione sindacale"
    when "TesauroSAN/arte-ordine-collegio-associazione_di_categoria"
      custodian_type = "ordine professionale, associazione di categoria"
    when "TesauroSAN/ente_e_associazione_di_culto_cattolico"
      custodian_type = "ente e associazione della chiesa cattolica"
    when "TesauroSAN/ente_e_associazione_di_culti_acattolici"
      custodian_type = "ente e associazione di culto acattolico"
    when "TesauroSAN/persona-famiglia"
      custodian_type = "persona o famiglia"

    when "archivio_di_Stato"
      custodian_type = "stato"
    when "regione-regione_a_statuto_speciale_conservatore"
      custodian_type = "regione"
    when "ente_territoriale"
      custodian_type = "ente pubblico territoriale"
    when "ente_diverso"
      custodian_type = "ente funzionale territoriale"
    when "ente_economico-impresa-studio_professionale_conservatore"
      custodian_type = "ente economico / impresa"
    when "istituto_di_credito"
      custodian_type = "ente di credito, assicurativo, previdenziale"
    when "ente_di_assistenza-beneficenza-previdenza-servizi_alla_persona"
      custodian_type = "ente di assistenza e beneficenza"
    when "ente_sanitario"
      custodian_type = "ente sanitario"
    when "ente_di_cultura-ente_di_ricerca"
      custodian_type = "ente di istruzione e ricerca"
    when "ente_ricreativo-sportivo-turistico_conservatore"
      custodian_type = "ente di cultura, ricreativo, sportivo, turistico"
    when "sindacato-organizzazione_sindacale_conservatore"
      custodian_type = "partito politico, organizzazione sindacale"
    when "arte-ordine-collegio-associazione_di_categoria"
      custodian_type = "ordine professionale, associazione di categoria"
    when "ente_e_associazione_di_culto_cattolico"
      custodian_type = "ente e associazione della chiesa cattolica"
    when "ente_e_associazione_di_culti_acattolici"
      custodian_type = "ente e associazione di culto acattolico"
    when "persona-famiglia"
      custodian_type = "persona o famiglia"
    end
    custodian_type_id = CustodianType.select(:id).where(:custodian_type => custodian_type).first.id
    custodian.custodian_type_id = custodian_type_id

    if document.xpath("scons/descrizione").present?
      custodian.history = document.xpath("scons/descrizione").text.gsub(/\t/, '')
    end

    if document.xpath("scons/servizi").present?
      custodian.services = document.xpath("scons/servizi").text
    end

    custodian.accessibility = ""
    custodian.legacy_id = document.xpath("scons/identificativi/identificativo").text
    custodian.db_source = self.identifier
    custodian.created_by = user_id
    custodian.updated_by = user_id
    custodian.group_id = group_id
    custodian.created_at = datetime
    custodian.updated_at = datetime
    custodian.sneaky_save!

    self.importable_id = custodian.id

    denominazioni = document.xpath("scons/denominazione")
    if (denominazioni.size == 1)
      custodian_name = CustodianName.new
      custodian_name.custodian_id = custodian.id
      custodian_name.name = denominazioni.first.text

      if denominazioni.xpath("@data").text != ""
        custodian_name.name += " (" + denominazioni.xpath("@data").text + ")"
      end

      custodian_name.created_at = datetime
      custodian_name.updated_at = datetime
      custodian_name.preferred = true
      custodian_name.qualifier = "OT"

      custodian_name.save!
    else
      preferred_found = false
      denominazioni.each do |denominazione|
        if denominazione.xpath("@qualifica").text == "principale"
          preferred_found = true
          break
        end
      end

      denominazioni.each do |denominazione|
        custodian_name = CustodianName.new
        custodian_name.custodian_id = custodian.id
        custodian_name.name = denominazione.text

        if denominazione.xpath("@data").text != ""
          custodian_name.name += " (" + denominazione.xpath("@data").text + ")"
        end

        custodian_name.created_at = datetime
        custodian_name.updated_at = datetime

        qualifica = denominazione.xpath("@qualifica").text
        preferred = false
        note = ""
        if (!preferred_found || (qualifica == "principale"))
          preferred_found = true

          preferred = true
          qualifier = "OT"
        elsif (qualifica == "altraDenominazione")
          qualifier = "OT"
        elsif (qualifica == "parallela")
          qualifier = "PA"
          lingua = ""
          if denominazione.xpath("boolean(@lingua)")
            lingua_xml = denominazione.xpath("@lingua").text
            if lingua_xml == "nnn"
              lingua = ""
            else
              lingua = lingua_xml
            end
          else
            lingua = ""
          end
          if lingua != ""
            note = "codice lingua: " + lingua
          end
        elsif (qualifica == "acronimo")
          qualifier = "AC"
        else
          qualifier = "OT"
        end
        custodian_name.preferred = preferred
        custodian_name.qualifier = qualifier
        custodian_name.note = note
        custodian_name.save!
      end
    end

    document.xpath("scons/relazioni/relazione").each do |relazione|
      tipo = relazione.xpath("@tipo").text
      if tipo == "URL" || tipo == "BIBSBN" || tipo == "FONTEURI"
        custodian_url = CustodianUrl.new
        custodian_url.custodian_id = custodian.id
        custodian_url.url = relazione.xpath("@href").text
        custodian_url.note = relazione.text.squish
        custodian_url.created_at = datetime
        custodian_url.updated_at = datetime
        custodian_url.save!
      end

      if tipo == "BIBTEXT" || tipo == "BIBSBN" || tipo == "FONTETEXT" || tipo == "FONTEURI"
        title = relazione.text.squish
        if title.present? && title != ""
          source_by_title = Source.find_by_title(title)
          if source_by_title.nil?
            source = Source.new
            source.created_by = user_id
            source.updated_by = user_id
            source.group_id = group_id
            source.created_at = datetime
            source.updated_at = datetime
            source.db_source = self.identifier
            source.legacy_id = custodian.legacy_id
            if tipo == "BIBTEXT" || tipo == "BIBSBN"
              source.source_type_code = 1 # bibliografia
            elsif tipo == "FONTETEXT" || tipo == "FONTEURI"
              source.source_type_code = 3 # fonte archivistica
            end
            source.title = title
            source.short_title = title.truncate(50, separator: /\s/)
            if Source.where("short_title = '#{source.short_title.gsub(/'/, "''")}'").present?
              source.sneaky_save
              source.short_title << " - #{source.id.to_s}"
            end
            source.save!
            if tipo == "BIBSBN" || tipo == "FONTEURI"
              fonte_url = relazione.xpath("@href").text
              if fonte_url.present? && fonte_url != ""
                source_url = SourceUrl.new
                source_url.url = fonte_url
                source_url.source_id = source.id
                source_url.save!
              end
            end
            source_id = source.id
          else
            source_id = source_by_title.id
          end
          rel_custodian_source = RelCustodianSource.new
          rel_custodian_source.custodian_id = custodian.id
          rel_custodian_source.source_id = source_id
          rel_custodian_source.save!
        end
      end      
    end

    if document.xpath("scons/identificativi/identificativo").present?
      custodian_identifier = CustodianIdentifier.new
      custodian_identifier.custodian_id = custodian.id
      custodian_identifier.identifier = document.xpath("scons/identificativi/identificativo").text
      custodian_identifier.identifier_source = document.xpath("scons/identificativi/identificativo/@tipo").text
      custodian_identifier.note = "Identificativo di sistema"

      #if document.xpath("scons/identificativi/identificativo/@href").present?
      #  custodian_identifier.note = document.xpath("scons/identificativi/identificativo/@href").text
      #else
      #  custodian_identifier.note = "Identificativo di sistema"
      #end

      custodian_identifier.created_at = datetime
      custodian_identifier.updated_at = datetime
      custodian_identifier.save!
    end

    document.xpath("scons/identificativi/altroidentificativo").each do |altroidentificativo|
      custodian_identifier = CustodianIdentifier.new
      custodian_identifier.custodian_id = custodian.id
      custodian_identifier.identifier = altroidentificativo.text
      custodian_identifier.identifier_source = altroidentificativo.xpath("@tipo").text
      custodian_identifier.note = "Altro identificativo"

      #if altroidentificativo.xpath("@href").present?
      #  custodian_identifier.note = altroidentificativo.xpath("@href").text
      #else
      #  custodian_identifier.note = "Altro identificativo"
      #end

      custodian_identifier.created_at = datetime
      custodian_identifier.updated_at = datetime
      custodian_identifier.save!
    end

    principale_found = false
    document.xpath("scons/localizzazioni/localizzazione").each do |localizzazione|
      custodian_building = CustodianBuilding.new
      custodian_building.custodian_id = custodian.id
      custodian_building.name = localizzazione.xpath("denominazione").text
      custodian_building.address = localizzazione.xpath("indirizzo/@denominazioneStradale").text

      if custodian_building.address == ""
        custodian_building.address = localizzazione.xpath("indirizzo").text.squish
        if localizzazione.xpath("indirizzo/@numeroCivico").present?
          numero_civico = localizzazione.xpath("indirizzo/@numeroCivico").text
          if numero_civico != ""
            custodian_building.address += (" " + numero_civico)
          end
        end
      end

      custodian_building.postcode = localizzazione.xpath("indirizzo/@cap").text
      custodian_building.city = localizzazione.xpath("indirizzo/@comune").text
      custodian_building.country = localizzazione.xpath("indirizzo/@paese").text
      custodian_building.legacy_id = localizzazione.xpath("@identificativo").text
      custodian_building.created_at = datetime
      custodian_building.updated_at = datetime

      custodian_building_type = ""
      if (localizzazione.xpath("@consultazione").text == "S")
        custodian_building_type = "sede di consultazione"
      end
      custodian_building.custodian_building_type = custodian_building_type

      custodian_building.save!

      localizzazione.xpath("contatto").each do |contatto|
        custodian_contact = CustodianContact.new
        custodian_contact.custodian_id = custodian.id
        custodian_contact.contact = contatto.text
        custodian_contact.contact_note = custodian_building.name;
        custodian_contact.created_at = datetime
        custodian_contact.updated_at = datetime

        if (contatto.xpath("@tipo").text == "telefono")
          contact_type = "tel"
        elsif (contatto.xpath("@tipo").text == "mail")
          contact_type = "email"
        elsif (contatto.xpath("@tipo").text == "pec")
          contact_type = "pec"
        elsif (contatto.xpath("@tipo").text == "fax")
          contact_type = "fax"
        elsif (contatto.xpath("@tipo").text == "sitoweb")
          contact_type = "web"
        end
        custodian_contact.contact_type = contact_type

        custodian_contact.save!
      end

      if localizzazione.xpath("boolean(orario)")
        if !custodian.accessibility.empty?
          custodian.accessibility += "\n\n"
        end
        custodian.accessibility += "Orari Sede " + custodian_building.name + " - " + localizzazione.xpath("orario").text.squish
      end

      if localizzazione.xpath("boolean(accesso)")
        if !custodian.accessibility.empty?
          custodian.accessibility += "\n"
        end
        custodian.accessibility += "Accesso Sede " + custodian_building.name + " - " + localizzazione.xpath("accesso").text.squish
      end

      if ((localizzazione.xpath("@principale").text == "S") && !principale_found)
        principale_found = true

        legal_status = nil
        privato = localizzazione.xpath("@privato").text
        if (privato == "S")
          legal_status = "PR"
        elsif (privato == "N")
          legal_status = "PU"
        end
        custodian.legal_status = legal_status
      end
    end

    document.xpath("scons/info/evento").each do |evento|
      custodian_editor = CustodianEditor.new
      custodian_editor.custodian_id = custodian.id
      custodian_editor.created_at = datetime
      custodian_editor.updated_at = datetime

      name = ""
      if evento.xpath("boolean(agente/nome)")
        name = evento.xpath("agente/nome").first.text
      end
      if evento.xpath("boolean(agente/cognome)")
        if !name.empty?
          name += " "
        end
        name += evento.xpath("agente/cognome").first.text
      end
      if evento.xpath("boolean(agente/denominazione)")
        name = evento.xpath("agente/denominazione").first.text
      end
      custodian_editor.name = name

      if evento.xpath("agente/@tipo").present?
        custodian_editor.qualifier = evento.xpath("agente/@tipo").first.text
      end

      date_str = evento.xpath("@dataEvento").first.text
      if !date_str.empty?
        date_time = DateTime::strptime(date_str, "%Y-%m-%dT%H:%M:%S")
        custodian_editor.edited_at = date_time.strftime("%Y-%m-%d")
      end

      editing_type = ""
      xml_editing_type = evento.xpath("@tipoEvento").first.text
      if (xml_editing_type == "creazione")
        editing_type = "inserimento dati"
      elsif (xml_editing_type == "modifica")
        editing_type = "aggiornamento scheda"
      elsif (xml_editing_type == "cancellazione")
        editing_type = "aggiornamento scheda"
      elsif (xml_editing_type == "altro")
        editing_type = "schedatura"
      end
      custodian_editor.editing_type = editing_type

      custodian_editor.save!
    end

    custodian.save!

    return_bundle = {custodian_id: custodian.id}
    return return_bundle
  end

  #import fonti archivistiche
  #document Nokogiri::XML
  #user_id utente che effettua l'import
  #group_id gruppo dell'utente che effettua l'import
  def import_source(document, user_id, group_id)
    source = Source.new
    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    source.created_by = user_id
    source.updated_by = user_id
    source.group_id = group_id
    source.created_at = datetime
    source.updated_at = datetime
    source.db_source = self.identifier
    source.legacy_id = document.xpath("ead/control/recordid").text
    source.title = nil
    document.xpath("ead/control/filedesc/titlestmt/titleproper").each do |title|
      if source.title.nil?
        if title.xpath("@lang").present?
          source.title = "[#{title.xpath("@lang").text}: #{title.text}]\n\n"
        else
          source.title = "[#{title.text}]\n"
        end
      else
        source.title += "[#{title.xpath("@lang").text}: #{title.text}]\n"
      end
    end
    
    source_Curator = document.xpath('ead/control/filedesc/titlestmt/author[@localtype="Curator"]')
    source_curatore = document.xpath('ead/control/filedesc/titlestmt/author[@localtype="curatore"]')
    source_author = document.xpath('ead/control/filedesc/titlestmt/author')
    
    if source_Curator.present?
      source.editor = source_Curator.text.squish
    elsif source_curatore.present?
      source.editor = source_curatore.text.squish
    elsif source_author.present?
      source.author = source_author.text.squish
    end

    source.publisher = document.xpath('ead/control/filedesc/publicationstmt/publisher').text
    source.place = document.xpath('ead/control/filedesc/publicationstmt/address/addressline').text

    document.xpath("ead/control/filedesc/notestmt/controlnote").each do |controlnote|
      if controlnote.xpath("p").present?
        control_note = controlnote.xpath("p").text.squish
        if control_note != ""
          if !source.abstract.nil? && source.abstract != ""
            source.abstract += "\n" + control_note
          else
            source.abstract = control_note
          end    
        end
      end
    end

    compilatori = ""
    if document.xpath("ead/control/maintenancehistory/maintenanceevent").present?
      document.xpath("ead/control/maintenancehistory/maintenanceevent").each do |maintenance_event|

        tipo_evento = ""
        data_evento = ""
        tipo_agente = ""
        nome_agente = ""
        descrizione_evento = ""

        if maintenance_event.xpath("eventtype").present?
          tipo_evento = maintenance_event.xpath("eventtype").text.squish
        end

        if maintenance_event.xpath("eventdatetime").present?
          data_evento = maintenance_event.xpath("eventdatetime").text.squish
        end

        if maintenance_event.xpath("agenttype/@value").present?
          tipo_agente = import_agent_type(maintenance_event.xpath("agenttype/@value").text)
        end

        if maintenance_event.xpath("agent").present?
          nome_agente = maintenance_event.xpath("agent").text.squish
        end

        if maintenance_event.xpath("eventdescription").present?
          descrizione_evento = maintenance_event.xpath("eventdescription").text.squish
        end

        evento = ""
        if nome_agente != "" || tipo_agente != ""
          evento += "Compilatore: " + nome_agente
          if tipo_agente != ""
            if nome_agente != ""
              evento += " "
            end
            evento += "(" + tipo_agente + ")"
          end
          evento += "\n"
        end

        if data_evento != ""
          evento += "Data intervento: " + data_evento + "\n"
        end

        if tipo_evento != ""
          evento += "Tipo intervento: " + tipo_evento + "\n"
        end

        if descrizione_evento != ""
          evento += "Descrizione evento: " + descrizione_evento + "\n"
        end

        if evento != ""
          evento = "\n" + evento
        end

          compilatori += evento
      end

      if compilatori != ""
        compilatori = "COMPILATORI:\n" + compilatori
      end
    end

    if !source.abstract.nil? && source.abstract != ""
      source.abstract += "\n\n" + compilatori
    else
      source.abstract = compilatori
    end
   
    source_type = SourceType.where("source_types.source_type = ?", document.xpath('ead/control/filedesc/editionstmt/edition[@localtype="typology"]').text.downcase).first
    if !source_type.present?
      Rails.logger.info("Nessun source_type corrispondente alla tipologia indicata in: \n ead/control/filedesc/editionstmt/edition[@localtype='typology'], e` stato assegnato 'fonte archivistica' di default ")
      source.source_type_code = 2
    else
      if source_type.parent_code.nil?
        source.source_type_code = source_type.code
      else
        source.source_type_code = source_type.parent_code
        source.source_subtype_code = source_type.code
      end
    end
    if document.xpath('ead/control/filedesc/editionstmt/edition[@localtype="published"]').text == 'no'
      source.finding_aid_published = 0
    else
      source.finding_aid_published = 1
    end

    if document.xpath("ead/control/filedesc/publicationstmt/date").present?
      source.date_string = document.xpath("ead/control/filedesc/publicationstmt/date").text
    end

    document.xpath("ead/control/otherrecordid").each do |other_record_id|
      if (!source.legacy_description.nil? && source.legacy_description != "")
        source.legacy_description += " " + other_record_id.text.squish
      else
        source.legacy_description = other_record_id.text.squish
      end
    end
   
    source.sneaky_save

    source.short_title = document.xpath("ead/control/filedesc/titlestmt/titleproper").text.truncate(50, separator: /\s/)
    if Source.where("short_title = '#{source.short_title.gsub(/'/, "''")}'").present?
      source.short_title << " - #{source.id.to_s}"
    end
    Rails.logger.info "Import: Salvataggio sorgente #{source.id}"

    source.save!
    Rails.logger.info "Import: sorgente salvata"


    i = 0
    until document.xpath("ead/control/representation")[i].nil? do
      source_url = SourceUrl.new
      source_url.note = document.xpath("ead/control/representation")[i].text
      source_url.url = document.xpath("ead/control/representation/@href")[i].value
      source_url.source_id = source.id
      source_url.save!
      i = i +1
    end

    document.xpath("ead/control/sources/source").each do |xmlSourceUrl|
      if xmlSourceUrl.xpath("@href").present?
        source_url = SourceUrl.new
        source_url.url = xmlSourceUrl.xpath("@href").first.text
        if xmlSourceUrl.xpath("sourceentry").present?
          source_url.note = xmlSourceUrl.xpath("sourceentry").first.text
        end
        source_url.source_id = source.id
        source_url.save!
      end
    end

    self.importable_id = source.id

    return_bundle = {source_id: source.id, legacy_fond_ids: Array.new}

    #if document.xpath("ead/control/localcontrol/term").present?
    #  document.xpath("ead/control/localcontrol/term/@identifier").each do |related_fond|
    #    Rails.logger.info "Associazione fonti a complessi"
    #    return_bundle[:legacy_fond_ids].push related_fond.text
    #    Rails.logger.info "Associazione complesso con legacy_id #{related_fond.text}"
    #  end
    #end

    return return_bundle
  end

  #import complessi archivistici
  #document Nokogiri::XML
  #user_id utente che effettua l'import
  #group_id gruppo dell'utente che effettua l'import
  def import_fond(document, user_id, group_id)
    Rails.logger.info "Inizio importazione complesso da import.rb"
    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    fond = Fond.new

    fond_type = ""
    level = document.xpath("archdesc/@level").first.text
    if level == 'otherlevel'
      level = path.xpath("archdesc/@otherlevel").text
    end
    fond_type = import_level_type(level)

      #fond_type = "sottosezione"
      #when "otherlevel"
      #fond_type = "categoria"
      #when "otherlevel"
      #fond_type = "classe"
      #when "otherlevel"
      #fond_type = "sottoclasse"
      #when "otherlevel"
      #fond_type = "rubrica"
      #when "otherlevel"
      #fond_type = "voce"
      #when "otherlevel"
      #fond_type = "sottovoce"
      #when "otherlevel"
      #fond_type = "titolo"
      #when "otherlevel"
      #fond_type = "sottotitolo"
      #when "otherlevel"
      #fond_type = "articolo"
      #
    fond.fond_type = fond_type

    #solo la prima Denominazione è considerata come principale

    document.xpath("//ead/archdesc/did/unittitle").each do |title|
      if title.xpath('@localtype').text.downcase == "denominazione"
        fond.name = title.text
      end
    end

    puts fond.inspect
    puts fond

    fond.legacy_id = document.xpath("did/unitid").text.squish
    fond.db_source = self.identifier
    fond.created_by = user_id
    fond.updated_by = user_id
    fond.group_id = group_id
    fond.created_at = datetime
    fond.updated_at = datetime

    if document.xpath("//ead/archdesc/accessrestrict").present?
      fond.access_condition = document.xpath("//ead/archdesc/accessrestrict").first.text
      fond.access_condition_note = document.xpath("//ead/archdesc/accessrestrict/p").first.text
    end
    fond.published = false
    if document.xpath("//ead/archdesc/processinfo/p").first.text.downcase == "pubblicata"
      fond.published = true
    end

    fond.history = document.xpath("//ead/archdesc/custodhist/p").text.squish
    fond.length = document.xpath("//ead/archdesc/did/physdescstructured/quantity").text
    #fond.extent = document.xpath("//ead/archdesc/did/physdescstructured/descriptivenote/p").text
    fond.extent = document.xpath("//ead/archdesc/did/physdesc").text.squish
    fond.description = document.xpath("//ead/archdesc/scopecontent/p").text.squish
    fond.arrangement_note = document.xpath("//ead/archdesc/scopecontent/p").text.squish

    fond.sneaky_save!

    self.importable_id = fond.id

    if document.xpath("//ead/archdesc/processinfo/processinfo/p").present?
      document.xpath("//ead/archdesc/processinfo[@localtype='compilatori']/processinfo[@localtype='compilatore']").each do |pi|
        editor = FondEditor.new
        editor.fond_id = fond.id
        editor.name = pi.xpath("p/persname/part[@localtype='compilatore']").text
        editor.qualifier = pi.xpath("p/persname/part[@localtype='qualifica']").text
        tipo_intervento = pi.xpath("p/persname/part[@localtype='tipoIntervento']").text
        if tipo_intervento == "inserimento" || tipo_intervento == "created"
          editor.editing_type = "inserimento dati"
        elsif tipo_intervento == "modifica" || tipo_intervento == "updated"
          editor.editing_type = "aggiornamento scheda"
        end
        editor.edited_at = Date.parse pi.xpath("p/date").text
        editor.save!
      end
    end

    puts fond.inspect
    puts fond

    if document.xpath("//ead/archdesc/controlaccess/genreform").present?
      document.xpath("//ead/archdesc/controlaccess/genreform").each do |fond_document|
        rel__f_d = RelFondDocumentForm.new
        rel__f_d.name = fond_document.xpath("part[@localtype='denominazione']").first.text.squish
        rel__f_d.description = fond_document.xpath("part[@localtype='descrizione']").first.text.squish
        rel__f_d.note = fond_document.xpath("part[@localtype='note']").first.text.squish
        if DocumentForm.where("document_forms.name = ?", rel__f_d.name).first.present?
          rel__f_d.document_form_id = DocumentForm.where("document_forms.name = ?", rel__f_d.name).first[:id]
          rel__f_d.fond_id = fond.id
          rel__f_d.save!
        else
          puts("Nessun DocumentForm trovato con il nome inserito. Non e' stato aggiunto alcun record del tipo 'RelFondDocumentForm'")
        end
      end
    end

    #altre denominazioni
    document.xpath("//ead/archdesc/did/unittitle").each do |unittitle|
      if (unittitle.text != fond.name)
        fond_name = FondName.new
        fond_name.fond_id = fond.id
        fond_name.name = unittitle.text
        fond_name.created_at = datetime
        fond_name.updated_at = datetime
        fond_name.qualifier = "O"
        fond_name.note = ""
        if unittitle.xpath("@localtype").text == "denominazioneParallela"
          fond_name.note = "Denominazione parallela;"
        end
        if unittitle.xpath("@lang").text.present?
          fond_name.note += " Codice lingua: " + unittitle.xpath("@lang").text
        end
        fond_name.save!
      end
    end

    if document.xpath("boolean(//ead/archdesc/did/unitdatestructured/dateset)")
      event = FondEvent.new
      event.fond_id = fond.id
      import_dateset(document.xpath("//ead/archdesc/did/unitdatestructured/dateset").first, event, datetime)
    end
    Rails.logger.info "Salvataggio complesso importato da import.rb > import_fond"
    fond.save
    Rails.logger.info "Salvataggio complesso COMPLETATO da import.rb > import_fond"
  end

  #import unità archivistiche
  #document Nokogiri::XML
  #user_id utente che effettua l'import
  #group_id gruppo dell'utente che effettua l'import
  def import_unit(document, user_id, group_id)
    root_unit_path = document.xpath("ead/archdesc/dsc/c")

    #La parte commentata serve ad importare la gerarchia delle unita in un fondo esistente nel db.
    #fond_id = document.xpath("ead/control/recordid").text.to_i
    #Rails.logger.info "Le unita' del file verranno importate nel complesso #{fond_id} del database, se presente"
    #if Fond.exists?(fond_id)
    #  Rails.logger.info "complesso archivistico con id: #{fond_id} presente"
    #  fond = Fond.find(fond_id)
    #  if fond.ancestry == nil
    #    root_fond_id = fond_id
    #  else
    #    root_fond_id = fond.ancestry.root.id
    #  end
    #  import_unit_hierarchy root_unit_path, root_fond_id, fond_id, user_id, group_id, nil
    #else
    #  Rails.logger.info "Complesso con id #{fond_id} non presente nel database, ne verra' creato uno nuovo per contenere le unita'"

    Rails.logger.info "Verra` importata la gerarchia dei complessi con le loro unita`"
    self.importable_id = import_fond_hierarchy document.xpath("ead/archdesc"), user_id, group_id, ''
    #end
    root_unit = Unit.where(db_source: self.identifier, legacy_id: root_unit_path.xpath("did/unitid/@identifier").text).first
    #self.importable_id = root_unit.id
    Rails.logger.info "Unita' salvate a partire dalla radice #{root_unit_path.xpath("did/unitid/@identifier").text}, ora rappresentata dall'id #{self.importable_id}"
  end

  #mapping tipologia di intervento
  def import_editing_type(event_type)
    editing_type = ""

    if event_type == "created" || event_type == "derived"
      editing_type = "inserimento dati"
    elsif event_type == "updated"
      editing_type = "aggiornamento scheda"
    elsif event_type == "revised"
      editing_type = "revisione"
    end

    return editing_type
  end

  def import_agent_type(agent_type)
    if agent_type == 'human'
      'persona'
    elsif agent_type == 'machine'
      'software'
    else
      agent_type
    end
  end

  #mapping qualifica altra denominazione
  def import_qualifer_type(localType)
    qualifier = ""

    if localType == "altraDenominazione"
      qualifier = "OT"
    elsif localType == "acronimo"
      qualifier = "AC"
    else
      qualifier = "OT"
    end

    return qualifier
  end

  def import_level_type(level)
    case level
    when "fonds"
      "fondo"
    when "recordgrp"
      "complesso di fondi"
    when "subfonds"
      "sezione"
    when "series"
      "serie"
    when "subseries"
      "sottoserie"
    when "subsubseries"
      "sottosottoserie"
    else
      level
    end
  end

  #estrae la datazione dall'xml del tracciato EAD3 e la salva sul database
  def import_dateset(dateset, event, datetime)
    Rails.logger.info "inizio funzione import_dateset()"
    event.preferred = true
    event.is_valid = true
    event.created_at = datetime
    event.updated_at = datetime

    d = extract_archidate(dateset)

    event.start_date_display = d[:start_date_display]
    event.start_date_from = d[:start_date_from]
    event.start_date_to = d[:start_date_to]
    event.start_date_format = d[:start_date_format]
    event.start_date_spec = d[:start_date_spec]
    event.start_date_valid = d[:start_date_valid]

    event.end_date_display = d[:end_date_display]
    event.end_date_from = d[:end_date_from]
    event.end_date_to = d[:end_date_to]
    event.end_date_format = d[:end_date_format]
    event.end_date_spec = d[:end_date_spec]
    event.end_date_valid = d[:end_date_valid]

    event.note = d[:note]

    Rails.logger.info "fine funzione import_dateset(), salvataggio..."
    Rails.logger.info "XML - [ #{dateset.text} \n Data = #{event.inspect}]"
    event.sneaky_save
    Rails.logger.info("...dateset salvato.")
  end

  def extract_archidate(xml_item)
    Rails.logger.info xml_item
    ret = {}

    #Estremo cronologico iniziale uguale a estremo cronologico finale
    if xml_item.xpath("datesingle[not(@localtype)]").present? || xml_item.xpath("dateSingle[not(@localtype)]").present?
      single_date = {}
      if xml_item.xpath("datesingle[not(@localtype)]").present?
        single_date = extract_singledate(xml_item.xpath("datesingle[not(@localtype)]").first, true)
      end
      if xml_item.xpath("dateSingle[not(@localtype)]").present?
        single_date = extract_singledate(xml_item.xpath("dateSingle[not(@localtype)]").first, true)
      end
      ret[:start_date_from] = single_date[:date_from]
      ret[:start_date_to] = single_date[:date_to]
      ret[:start_date_display] = single_date[:date_display]
      ret[:start_date_format] = single_date[:date_format]
      ret[:start_date_spec] = single_date[:date_spec]
      ret[:start_date_valid] = single_date[:date_valid]

      if xml_item.xpath("datesingle[not(@localtype)]").present?
        single_date = extract_singledate(xml_item.xpath("datesingle[not(@localtype)]").first, false, true)
      end
      if xml_item.xpath("dateSingle[not(@localtype)]").present?
        single_date = extract_singledate(xml_item.xpath("dateSingle[not(@localtype)]").first, false, true)
      end
      ret[:end_date_from] = single_date[:date_from]
      ret[:end_date_to] = single_date[:date_to]
      ret[:end_date_display] = single_date[:date_display]
      ret[:end_date_format] = single_date[:date_format]
      ret[:end_date_spec] = single_date[:date_spec]
      ret[:end_date_valid] = single_date[:date_valid]
    end

    #Estremo cronologico iniziale diverso da estremo cronologico finale
    if xml_item.xpath("daterange").present? || xml_item.xpath("dateRange").present?
      single_date = {}
      if (xml_item.xpath("daterange").present?)
        single_date = extract_singledate(xml_item.xpath("daterange/fromdate").first, true)
      end
      if (xml_item.xpath("dateRange").present?)
        single_date = extract_singledate(xml_item.xpath("dateRange/fromDate").first, true)
      end

      ret[:start_date_from] = single_date[:date_from]
      ret[:start_date_to] = single_date[:date_to]
      ret[:start_date_display] = single_date[:date_display]
      ret[:start_date_format] = single_date[:date_format]
      ret[:start_date_spec] = single_date[:date_spec]
      ret[:start_date_valid] = single_date[:date_valid]

      if (xml_item.xpath("daterange").present?)
        single_date = extract_singledate(xml_item.xpath("daterange/todate").first, false)
      end
      if (xml_item.xpath("dateRange").present?)
        single_date = extract_singledate(xml_item.xpath("dateRange/toDate").first, false)
      end
      ret[:end_date_from] = single_date[:date_from]
      ret[:end_date_to] = single_date[:date_to]
      ret[:end_date_display] = single_date[:date_display]
      ret[:end_date_format] = single_date[:date_format]
      ret[:end_date_spec] = single_date[:date_spec]
      ret[:end_date_valid] = single_date[:date_valid]
    end

    #Gestione per existDates eac-cpf
    if xml_item.xpath("date").present?
      single_date = extract_singledate(xml_item.xpath("date").first, true)

      ret[:start_date_from] = single_date[:date_from]
      ret[:start_date_to] = single_date[:date_to]
      ret[:start_date_display] = single_date[:date_display]
      ret[:start_date_format] = single_date[:date_format]
      ret[:start_date_spec] = single_date[:date_spec]
      ret[:start_date_valid] = single_date[:date_valid]

      single_date = extract_singledate(xml_item.xpath("date").first, false, true)

      ret[:end_date_from] = single_date[:date_from]
      ret[:end_date_to] = single_date[:date_to]
      ret[:end_date_display] = single_date[:date_display]
      ret[:end_date_format] = single_date[:date_format]
      ret[:end_date_spec] = single_date[:date_spec]
      ret[:end_date_valid] = single_date[:date_valid]
    end

    #Gestione note alla data
    if xml_item.xpath("datesingle[@localtype='noteAllaData']").present?
      ret[:note] = xml_item.xpath("datesingle[@localtype='noteAllaData']").first.text.gsub(/\t/, '')

    elsif xml_item.xpath("dateSingle[@localtype='noteAllaData']").present?
      ret[:note] = xml_item.xpath("dateSingle[@localtype='noteAllaData']").first.text.gsub(/\t/, '')

    elsif xml_item.xpath("datesingle[@localtype='notealladata']").present?
      ret[:note] = xml_item.xpath("datesingle[@localtype='notealladata']").first.text.gsub(/\t/, '')

    elsif xml_item.xpath("dateSingle[@localtype='notealladata']").present?
      ret[:note] = xml_item.xpath("dateSingle[@localtype='notealladata']").first.text.gsub(/\t/, '')

    elsif xml_item.xpath("descriptiveNote/p").present?
      ret[:note] = xml_item.xpath("descriptiveNote/p").first.text.gsub(/\t/, '')

    end

    return ret
  end

  def extract_singledate(xml_item_date, start, date_open = false)
    singledate = {}

    singledate[:date_display] = xml_item_date.text

    if xml_item_date.xpath("boolean(@notbefore)") || xml_item_date.xpath("boolean(@notBefore)")
      if xml_item_date.xpath("boolean(@notbefore)")
        singledate[:date_from] = xml_item_date.xpath("@notbefore").first.text
      end
      if xml_item_date.xpath("boolean(@notBefore)")
        singledate[:date_from] = xml_item_date.xpath("@notBefore").first.text
      end
      if xml_item_date.text[0..3].downcase == "sec."
        singledate[:date_format] = "C"
      else
        singledate[:date_format] = "Y"
      end
      singledate[:date_spec] = "idem"
    end
    if xml_item_date.xpath("boolean(@notafter)") || xml_item_date.xpath("boolean(@notAfter)")
      if xml_item_date.xpath("boolean(@notafter)")
        singledate[:date_to] = xml_item_date.xpath("@notafter").first.text
      end
      if xml_item_date.xpath("boolean(@notAfter)")
        singledate[:date_to] = xml_item_date.xpath("@notAfter").first.text
      end
      if xml_item_date.text[0..3].downcase == "sec."
        singledate[:date_format] = "C"
      else
        singledate[:date_format] = "Y"
      end
      singledate[:date_spec] = "idem"
    end
    if xml_item_date.xpath("boolean(@standarddate)") || xml_item_date.xpath("boolean(@standardDate)") || xml_item_date.xpath("not(@*)")
      if xml_item_date.xpath("boolean(@standarddate)")
        singledate[:date_from] = xml_item_date.xpath("@standarddate").text
      end
      if xml_item_date.xpath("boolean(@standardDate)")
        singledate[:date_from] = xml_item_date.xpath("@standardDate").text
      end
      if xml_item_date.xpath("not(@*)")
        singledate[:date_from] = xml_item_date.text
      end

      singledate[:date_format] = "YMD"
      if singledate[:date_from].size == 4
        singledate[:date_format] = "Y"
        if start
          singledate[:date_from] << "-01-01"
        else
          singledate[:date_from] << "-12-31"
        end
      elsif singledate[:date_from].size == 7 && singledate[:date_from].include?("-")
        singledate[:date_format] = "YM"
        if start
          singledate[:date_from] << "-01"
        else
          singledate[:date_from] << "-#{Time.days_in_month(date[5..6].to_i, date[0..3].to_i)}"
        end
      elsif singledate[:date_from].size == 6 && !singledate[:date_from].include?("-")
        singledate[:date_format] = "YM"
        singledate[:date_from] = singledate[:date_from][0..3] + "-" + singledate[:date_from][4..5]
        if start
          singledate[:date_from] << "-01"
        else
          singledate[:date_from] << "-#{Time.days_in_month(date[5..6].to_i, date[0..3].to_i)}"
        end
      elsif singledate[:date_from].size == 8 && !singledate[:date_from].include?("-")
        singledate[:date_from] = singledate[:date_from][0..3] + "-" + singledate[:date_from][4..5] + "-" + singledate[:date_from][6..7]
      end

      if singledate[:date_format] == "YMD" && singledate[:date_display].size == 4 && singledate[:date_display].scan(/\D/).empty?
        singledate[:date_format] = "Y"
      end

      singledate[:date_to] = singledate[:date_from]
    end

    if singledate.key?(:date_from) && singledate[:date_from].size == 8 && !singledate[:date_from].include?("-")
      singledate[:date_from] = singledate[:date_from][0..3] + "-" + singledate[:date_from][4..5] + "-" + singledate[:date_from][6..7]
    end

    if singledate.key?(:date_to) && singledate[:date_to].size == 8 && !singledate[:date_to].include?("-")
      singledate[:date_to] = singledate[:date_to][0..3] + "-" + singledate[:date_to][4..5] + "-" + singledate[:date_to][6..7]
    end

    if singledate[:date_display].include? "ante"
      singledate[:date_spec] = "ante"
    elsif singledate[:date_display].include? "post"
      singledate[:date_spec] = "post"
    elsif singledate[:date_display].include? "circa"
      singledate[:date_spec] = "circa"
    else
      singledate[:date_spec] = "idem"
    end

    # Gestione estremo aperto (se non data singola) 
    exist_notbefore = xml_item_date.xpath("boolean(@notbefore)") || xml_item_date.xpath("boolean(@notBefore)")
    exist_notafter = xml_item_date.xpath("boolean(@notafter)") || xml_item_date.xpath("boolean(@notAfter)")
    if ((singledate[:date_display].empty? || singledate[:date_display] == "?" || singledate[:date_display] == "s.d." || singledate[:date_display] == "non indicata") && !start) || (date_open && !(exist_notbefore && exist_notafter))
      singledate[:date_format] = "O"
      singledate[:date_valid] = "U"
      singledate[:date_spec] = "idem"
      singledate[:date_from] = "9999-12-31"
      singledate[:date_to] = "9999-12-31"
    end

    #@certainty
    if !singledate.key?(:date_valid)
      if (singledate[:date_display].start_with?("[") and singledate[:date_display].end_with?("?]"))
        singledate[:date_valid] = "UQ"
      elsif singledate[:date_display].start_with?("[")
        singledate[:date_valid] = "Q"
      elsif singledate[:date_display].end_with?("?")
        singledate[:date_valid] = "U"
      else
        singledate[:date_valid] = "C"
      end
    end

    return singledate
  end

  #calcolo data finale della data secolare
  #il calcolo si base sui valori presenti nella lib archidate
  def calc_end_periodo_data_secolare(date, date_display)
    date_obj = Date::strptime(date, "%Y-%m-%d")

    if date_display.include?("prima metà") || date_display.include?("seconda metà")
      date_str = date_obj.next_year(49).strftime("%Y-%m-%d")
    elsif date_display.include?("inizio") || date_display.include?("fine") || date_display.include?("metà")
      date_str = date_obj.next_year(9).strftime("%Y-%m-%d")
    elsif date_display.include?("quarto")
      date_str = date_obj.next_year(24).strftime("%Y-%m-%d")
    else
      date_str = ""
    end

    return date_str
  end

  #calcolo data iniziale della data secolare
  #il calcolo si base sui valori presenti nella lib archidate
  def calc_start_periodo_data_secolare(date, date_display)
    date_obj = Date::strptime(date, "%Y-%m-%d")

    if date_display.include?("prima metà") || date_display.include?("seconda metà")
      date_str = date_obj.next_year(-49).strftime("%Y-%m-%d")
    elsif date_display.include?("inizio") || date_display.include?("fine") || date_display.include?("metà")
      date_str = date_obj.next_year(-9).strftime("%Y-%m-%d")
    elsif date_display.include?("quarto")
      date_str = date_obj.next_year(-24).strftime("%Y-%m-%d")
    else
      date_str = ""
    end

    return date_str
  end

  #import xml relativo ai tracciati EAD3, SCONS2, EAC-CPF, ICAR-IMPORT
  #ritorna 0: errore di import
  #        1: import ok
  #        2: errore di validazione xml
  def import_xml_file(user, ability)
    begin
      ActiveRecord::Base.transaction do
        document = Nokogiri::XML(File.open(xml_data_file))

        if (!document.errors.empty?)
          Rails.logger.info("errore: syntax error in xml")
          return 0
        end

        #rimozione namespace: ad esempio xsi:schemaLocation diventa schemaLocation
        #per poter usare xpath più agevolmente il namespace è rimosso
        document.remove_namespaces!

        group_id = ""
        if user.is_multi_group_user?()
          group_id = ability.target_group_id
        else
          group_id = user.rel_user_groups[0].group_id
        end

        #l'xsd del tracciato EAD3 ha un elemento non deterministico
        #e.anyname
        #quando è istanziato l'oggetto schema è lanciata l'eccezione
        #Nokogiri::XML::SyntaxError: complex type 'e.anyname': The content model is not determinist.
        #non sembra essere possibile utilizzare l'xsd con la versione attuale di nokogiri
        #non è inoltre possibile aggiornare nokogiri perché le versioni successive non sono compatibili con la versione di ruby utilizzata
        #perciò la validazione non è effettuata in caso di EAD3

        skip_validation = true

        xsd_link = ""
        header_tag = ""
        if (document.xpath("boolean(//icar-import)"))
          header_tag = "icar-import"
          skip_validation = true
        elsif (document.xpath("boolean(//eac-cpf)"))
          header_tag = "eac-cpf"
        elsif (document.xpath("boolean(//scons)"))
          header_tag = "scons"
        elsif (document.xpath("boolean(//ead)"))
          header_tag = "ead"
          skip_validation = true
        elsif (document.xpath("boolean(//icar-import)"))
          header_tag = "icar-import"
          skip_validation = true
        else
          Rails.logger.info("error: l'xml non è relativo al formato SCONS2, EAC-CPF, EAD3 o ICAR-IMPORT")
          return 0
        end
        document.xpath("//" + header_tag + "/@schemaLocation").first.value.split(" ").each do |schemaLocation|
          if (schemaLocation.start_with?("http") && schemaLocation.end_with?(".xsd"))
            xsd_link = schemaLocation
            break
          end
        end
        if xsd_link == ""
          Rails.logger.info("error: l'xml non contiene il link all'xsd")
          return 0
        end

        #la versione di Ruby utilizzata non prevede i redirect da http a https o viceversa
        #workaround: in redirect.uri c'è l'url verso il quale deve essere effettuata la redirezione
        #            si effettuano massimo 3 tentativi per cercare di accedere all'xsd
        if !skip_validation
          uri = URI.parse(xsd_link)
          tries = 3
          begin
            uri.open(redirect: false)
          rescue OpenURI::HTTPRedirect => redirect
            uri = redirect.uri #"Location" response header
            retry if (tries -= 1) > 0
            raise
          end

          schema = Nokogiri::XML::Schema(uri.read)
          document_w_namespace = Nokogiri::XML(File.open(xml_data_file)) #la validazione deve essere condotta sull'xml completo di namespace
          validation_errors = schema.validate(document_w_namespace)
        else
          validation_errors = Array.new
        end
        if validation_errors.empty?

          if (document.xpath("boolean(//icar-import)"))
            import_icar_import document, user.id, group_id
            self.importable_type = "Fond"
          elsif (document.xpath("boolean(//eac-cpf)"))
            if document.xpath("boolean(//eac-cpf/cpfDescription/identity/@localType)")
              local_type = document.xpath("//eac-cpf/cpfDescription/identity/@localType").first.value
              if (local_type == "profiloIstituzionale")
                import_institution(document, user.id, group_id)
                self.importable_type = "Institution"
              elsif (local_type == "soggettoProduttore")
                import_creator(document, user.id, group_id)
                self.importable_type = "Creator"
              end
            elsif document.xpath("//eac-cpf/cpfDescription/identity/entityType").first.text == "person" &&
                document.xpath("boolean(//eac-cpf/cpfDescription/identity/entityId)") &&
                document.xpath("//eac-cpf/cpfDescription/identity/entityId/@localType").text == ""
              import_anagraphic(document, user.id, group_id)
              self.importable_type = "Anagraphic"
            else
              Rails.logger.info("error: l'xml relativo al formato EAC-CPF non è corretto")
              return 0
            end
          elsif (document.xpath("boolean(//scons)"))
            import_custodian(document, user.id, group_id)
            self.importable_type = "Custodian"
          elsif (document.xpath("boolean(//ead)"))
            if ((document.xpath("//ead/archdesc/did/*").size == 1) && (document.xpath("//ead/archdesc/did/unittitle").text == "") &&
                !document.xpath("boolean(//ead/archdesc/dsc)"))
              import_source(document, user.id, group_id)
              self.importable_type = "Source"
            else
              if !document.xpath("//ead/control/filedesc/titlestmt/titleproper/@encodinganalog").empty? && !document.xpath("//ead/control/recordid/@*").empty?
                import_unit(document, user.id, group_id)
                #import_fond(document, user.id, group_id)
                self.importable_type = "Fond"
              else
                import_unit(document, user.id, group_id)
                self.importable_type = "Fond"
                # self.importable_type = "Unit" #TODO da rivedere: in realtà dovrebbe essere comunque l'import di un complesso, quello che contiene l'unita'
              end
            end
          else
            Rails.logger.info("error: l'xml non è relativo al formato SCONS2, EAC-CPF, EAD3 o ICAR-IMPORT")
            return 0
          end
        else
          validation_errors.each do |error|
            Rails.logger.info("validation error: #{error}")
          end
          return 2
        end
      end
      return 1
    rescue Exception => e
      Rails.logger.info("\n\nEccezione - e.message: #{e.message}\n\n")
      # Decommentare le due righe seguenti in caso di necessità
      #Rails.logger.info("\n\nEccezione - e.backtrace")
      #e.backtrace.each { |line| logger.error line }
      return 0
    ensure
    end
  end

  #  def import_aef_file(user)
  def import_aef_file(user, ability)
    
    # Upgrade 2.2.0 fine
    
    #File.open(data_file) do |file|
    #  begin
    #    ActiveRecord::Base.transaction do
    #      lines = file.enum_for(:each_line)
    #      lines.each do |line|
    #        next if line.blank?
    #        data = ActiveSupport::JSON.decode(line.strip)
    #        key = data.keys.first
    #        model = key.camelize.constantize
    #        data[key].delete_if{|k, v| not model.column_names.include? k}
    #        object = model.new(data[key])
    #        object.db_source = self.identifier
    #        object.group_id = user.group_id if object.has_attribute? 'group_id'
    #        object.created_by = user.id if object.has_attribute? 'created_by'
    #        object.updated_by = user.id if object.has_attribute? 'updated_by'
    #        object.send(:create_without_callbacks)
    #      end
    #    end
    #    update_statements
    #    return true
    #  rescue
    #    return false
    #  ensure
    #    file.close
    #  end
    #end

    begin
      lines = File.readlines(data_file)
      # Upgrade 2.2.0 inizio
      unit_aef_import_units_count = 0
      # Upgrade 2.2.0 fine
      ActiveRecord::Base.transaction do
        # Upgrade 2.0.0 inizio
        model = nil
        prev_model = nil
        object = nil
        # Upgrade 2.0.0 fine
        lines.each do |line|
          next if line.blank?
          data = ActiveSupport::JSON.decode(line.strip)
          key = data.keys.first
          # Upgrade 2.1.0 inizio
          ipdata = data[key]
          if imported_file_version < "2.1.0"
            key = prv_adjust_ante_210_project(key, ipdata)
            key = prv_adjust_ante_210_project_credits(key, ipdata)
          end
          # Upgrade 2.1.0 fine
          model = key.camelize.constantize
          # Upgrade 2.1.0 inizio
          #data[key].delete_if{|k, v| not model.column_names.include? k}
          #object = model.new(data[key])
          ipdata.delete_if { |k, v| not model.column_names.include? k }
          object = model.new(ipdata)
          # Upgrade 2.1.0 fine
          object.db_source = self.identifier
          # Upgrade 2.2.0 inizio
          #object.group_id = user.group_id if object.has_attribute? 'group_id'
          if object.has_attribute? 'group_id'
            object.group_id = if user.is_multi_group_user?() then
                                ability.target_group_id
                              else
                                user.rel_user_groups[0].group_id
                              end
          end

          if (self.is_unit_aef_file?)
            if (model.to_s == "Unit")
              object.fond_id = self.ref_fond_id
              object.root_fond_id = prv_get_ref_root_fond_id
              unit_aef_import_units_count += 1
            end
          end
          # Upgrade 2.2.0 fine
          object.created_by = user.id if object.has_attribute? 'created_by'
          object.updated_by = user.id if object.has_attribute? 'updated_by'

          # Upgrade 2.0.0 inizio
          #object.send(:create_without_callbacks)
          object.sneaky_save!
          if model != prev_model && !prev_model.nil?
            prev_object = prev_model.new
            set_lacking_field_values(prev_object)
          end
          prev_model = model
        end
        if !object.nil?
          set_lacking_field_values(object)
        end
          # Upgrade 2.0.0 fine
      end
      # Upgrade 2.2.0 inizio
      #update_statements
      update_statements(unit_aef_import_units_count)
      # Upgrade 2.2.0 fine
      return true
    rescue Exception => e
      Rails.logger.info "import_aef_file Errore=" + e.message.to_s
      return false
    ensure
    end
  end

  # Upgrade 2.2.0 inizio
  #def update_statements
  def update_statements(unit_aef_import_units_count)
    # Upgrade 2.2.0 fine
    begin
      ActiveRecord::Base.transaction do
        # Upgrade 2.2.0 inizio
        #update_fonds_ancestry
        #update_units_fond_id
        #update_subunits_ancestry if db_has_subunits?
        #update_one_to_many_relations
        #update_many_to_many_relations
        #update_digital_objects if db_has_digital_objects?

        if (self.is_unit_aef_file?)
          units_aef_file_update_tables(unit_aef_import_units_count)
        else
          update_fonds_ancestry
          update_units_fond_id
          update_subunits_ancestry if db_has_subunits?
          update_one_to_many_relations
          update_many_to_many_relations
          update_digital_objects if db_has_digital_objects?
        end
        update_sc2_second_level_relations
        # Upgrade 2.2.0 fine
        # Upgrade 2.1.0 inizio
        #if imported_file_version < "2.1.0"
        # Upgrade 3.0.0 inizio 
        if !imported_file_version.nil? && imported_file_version < "2.1.0"
        # Upgrade 3.0.0 fine      
          Import.restore_d_f_s(self.identifier)
          Import.restore_bdm_oa(self.identifier)
        end
        # Upgrade 2.1.0 fine

        if self.importable_type == 'Fond'
          self.importable_id = Fond.find_by_db_source_and_ancestry("#{self.identifier}", nil).id
        else
          self.importable_id = self.importable_type.constantize.find_by_db_source("#{self.identifier}").id
        end
      end
    end
  end

  # Upgrade 2.0.0 inizio
  # assegna created_at, updated_at con la data corrente sul modello object
  def set_lacking_field_values(object)
    current_datetime = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S") # nel db le date sono in utc
    table_name = object.class.table_name.to_s

    sqlSetClause = ""
    sqlWhereClause = "#{table_name}.db_source = '#{self.identifier}'"
    if object.attributes.include? "created_at"
      sqlSetClause = "created_at = '#{current_datetime}'"
      sqlWhereClause = sqlWhereClause + " AND (created_at IS NULL)"
    end
    if object.attributes.include? "updated_at"
      if !sqlSetClause.empty? then
        sqlSetClause = sqlSetClause + ","
      end
      sqlSetClause = sqlSetClause + "updated_at = '#{current_datetime}'"
      sqlWhereClause = sqlWhereClause + " AND (updated_at IS NULL)"
    end

    if !sqlSetClause.empty?
      sqlStmt = "UPDATE #{table_name} SET #{sqlSetClause} WHERE #{sqlWhereClause}"
      ar_connection.execute(sqlStmt)
    end
  end
  # Upgrade 2.0.0 fine

  def update_fonds_ancestry(parent_id = nil, ancestry = nil)
    # Upgrade 2.0.0 inizio
    #Fond.find_each(:conditions => {:legacy_parent_id => parent_id, :db_source => self.identifier}) do |node|
    Fond.where({:legacy_parent_id => parent_id, :db_source => self.identifier}).find_each do |node|
    # Upgrade 2.0.0 fine
      node.without_ancestry_callbacks do
        node.update_attribute :ancestry, ancestry
      end
      update_fonds_ancestry node.legacy_id, if ancestry.nil? then
                                              "#{node.id}"
                                            else
                                              "#{ancestry}/#{node.id}"
                                            end
    end
  end

  # Upgrade 2.2.0 inizio
  def units_aef_file_update_tables(unit_aef_import_units_count)
    # maxsn = max sequence_number di tutte le unità del fondo considerato per l'importazione
    sqlWhereClause = "(fond_id=#{self.ref_fond_id}) AND (root_fond_id=#{prv_get_ref_root_fond_id}) AND (db_source IS NULL OR db_source <> '#{self.identifier}')"
    maxsn = Unit.where(sqlWhereClause).maximum("sequence_number")
    if (maxsn.nil?) then
      maxsn = 0
    end

    # maxpos = max position di tutte le unità non sotto-unità o sotto-sotto-unità del fondo considerato per l'importazione
    sqlWhereClause = "(fond_id=#{self.ref_fond_id}) AND (ancestry IS NULL) AND (db_source IS NULL OR db_source <> '#{self.identifier}')"
    maxpos = Unit.where(sqlWhereClause).maximum("position")
    if (maxpos.nil?) then
      maxpos = 0
    end

    # incrementa sequence_number delle unità del fondo radice considerato che avevano sequence_number > maxsn di un numero pari al numero di nuove unità importate (unit_aef_import_units_count) in modo da "fare spazio" nella sequenza alle nuove arrivate
    sqlWhereClause = "(root_fond_id=#{prv_get_ref_root_fond_id}) AND (db_source IS NULL OR db_source <> '#{self.identifier}') AND (sequence_number > #{maxsn})"
    sqlStmt = "UPDATE units SET sequence_number=sequence_number+#{unit_aef_import_units_count} WHERE #{sqlWhereClause}"
    ar_connection.execute(sqlStmt)

    # alle nuove unità importate si eseguono i seguenti aggiornamenti:
    # setta sequence_number in modo che si incastrino nella posizione prevista (in coda a quelle del fondo considerato)
    sqlWhereClause = "db_source = '#{self.identifier}'"
    sqlStmt = "UPDATE units SET sequence_number=sequence_number+#{maxsn} WHERE #{sqlWhereClause}"
    ar_connection.execute(sqlStmt)

    update_subunits_ancestry if db_has_subunits?

    posindex = maxpos + 1
    prev_ancestry = ""
    prev_ancestry_depth = 0
    sqlWhereClause = "db_source = '#{self.identifier}'"

    Unit.where(sqlWhereClause).order("ancestry_depth, sequence_number").each do |unit|
      ancestry = unit.ancestry
      if (ancestry.nil?) then
        ancestry = ""
      end
      ancestry_depth = unit.ancestry_depth
      if (ancestry != prev_ancestry || ancestry_depth != prev_ancestry_depth)
        posindex = 1
      end
      unit.update_column("position", posindex)

      posindex += 1
      prev_ancestry = ancestry
      prev_ancestry_depth = ancestry_depth
    end

    update_one_to_many_relations

    update_digital_objects if db_has_digital_objects?

    # aggiorna l'informazione sul numero di unità collegate al fondo di riferimento
    sqlStmt = "UPDATE fonds SET units_count=units_count+#{unit_aef_import_units_count} WHERE id=#{self.ref_fond_id}"
    ar_connection.execute(sqlStmt)
  end
  # Upgrade 2.2.0 fine

  def update_units_fond_id
    case adapter
    when 'sqlite'
      ar_connection.execute("UPDATE units
                           SET fond_id = (SELECT fonds.id FROM fonds
                           WHERE units.legacy_parent_fond_id = fonds.legacy_id
                           AND units.db_source = '#{self.identifier}'
                           AND fonds.db_source = '#{self.identifier}')
                           WHERE EXISTS (
                            SELECT * FROM fonds
                            WHERE units.legacy_parent_fond_id = fonds.legacy_id
                            AND units.db_source = '#{self.identifier}'
                            AND fonds.db_source = '#{self.identifier}')")
      ar_connection.execute("UPDATE units
                           SET root_fond_id = (SELECT fonds.id FROM fonds
                           WHERE units.legacy_root_fond_id = fonds.legacy_id
                           AND units.db_source = '#{self.identifier}'
                           AND fonds.db_source = '#{self.identifier}')
                           WHERE EXISTS (
                            SELECT * FROM fonds
                            WHERE units.legacy_root_fond_id = fonds.legacy_id
                            AND units.db_source = '#{self.identifier}'
                            AND fonds.db_source = '#{self.identifier}')")
    when 'mysql', 'mysql2'
      ar_connection.execute("UPDATE units u, fonds f
                           SET u.fond_id = f.id
                           WHERE u.legacy_parent_fond_id = f.legacy_id
                           AND u.db_source = '#{self.identifier}'
                           AND f.db_source = '#{self.identifier}'")

      ar_connection.execute("UPDATE units u, fonds f
                           SET u.root_fond_id = f.id
                           WHERE u.legacy_root_fond_id = f.legacy_id
                           AND u.db_source = '#{self.identifier}'
                           AND f.db_source = '#{self.identifier}'")
    when 'postgresql'
      ar_connection.execute("UPDATE units
                           SET fond_id = f.id
                           FROM fonds f
                           WHERE units.legacy_parent_fond_id = f.legacy_id
                           AND units.db_source = '#{self.identifier}'
                           AND f.db_source = '#{self.identifier}'")

      ar_connection.execute("UPDATE units
                           SET root_fond_id = f.id
                           FROM fonds f
                           WHERE units.legacy_root_fond_id = f.legacy_id
                           AND units.db_source = '#{self.identifier}'
                           AND f.db_source = '#{self.identifier}'")
    end
  end

  def update_subunits_ancestry
    case adapter
    when 'sqlite'
      (1..2).each do |n|
        ancestry = n == 1 ? "id" : "ancestry || '/' || id"
        ar_connection.execute("UPDATE units
                              SET ancestry = (SELECT #{ancestry}
                              FROM units parents
                              WHERE units.db_source = '#{self.identifier}'
                              AND parents.db_source = '#{self.identifier}'
                              AND units.legacy_parent_unit_id = parents.legacy_id
                              AND units.ancestry_depth = #{n})
                              WHERE EXISTS (
                                SELECT * FROM units parents
                                WHERE units.db_source = '#{self.identifier}'
                                AND parents.db_source = '#{self.identifier}'
                                AND units.legacy_parent_unit_id = parents.legacy_id
                                AND units.ancestry_depth = #{n});")
      end
    when 'mysql', 'mysql2'
      (1..2).each do |n|
        ar_connection.execute("UPDATE units u, units parents
                              SET u.ancestry = CONCAT_WS('/', parents.ancestry, CAST(parents.id AS char))
                              WHERE u.db_source = '#{self.identifier}'
                              AND parents.db_source = '#{self.identifier}'
                              AND u.legacy_parent_unit_id = parents.legacy_id
                              AND u.ancestry_depth = #{n};")
      end
    when 'postgresql'
      (1..2).each do |n|
        ar_connection.execute("UPDATE units
                             SET ancestry = CONCAT_WS('/', parents.ancestry, CAST(parents.id AS varchar))
                             FROM units parents
                             WHERE units.db_source = '#{self.identifier}'
                             AND parents.db_source = '#{self.identifier}'
                             AND units.legacy_parent_unit_id = parents.legacy_id
                             AND units.ancestry_depth = #{n};")
      end
    end
  end

  def update_one_to_many_relations
    entities = {
        :fonds => ["fond_events", "fond_identifiers", "fond_langs", "fond_names", "fond_owners", "fond_urls", "fond_editors"],
        # Upgrade 2.2.0 inizio
        #      :units => ["unit_events", "unit_identifiers", "unit_damages", "unit_langs", "unit_other_reference_numbers", "unit_urls", "unit_editors", "iccd_authors", "iccd_descriptions", "iccd_tech_specs", "iccd_damages", "iccd_subjects"],
        :units => ["unit_events", "unit_identifiers", "unit_damages", "unit_langs", "unit_other_reference_numbers", "unit_urls", "unit_editors", "iccd_authors", "iccd_descriptions", "iccd_tech_specs", "iccd_damages", "iccd_subjects", "sc2s", "sc2_textual_elements", "sc2_visual_elements", "sc2_authors", "sc2_commissions", "sc2_techniques", "sc2_scales", "fsc_organizations", "fsc_nationalities", "fsc_codes", "fsc_opens", "fsc_closes", "fe_identifications", "fe_contexts", "fe_operas", "fe_designers", "fe_cadastrals", "fe_land_parcels", "fe_fract_land_parcels", "fe_fract_edil_parcels"],
        # Upgrade 2.2.0 fine
        :creators => ["creator_events", "creator_identifiers", "creator_legal_statuses", "creator_names", "creator_urls", "creator_activities", "creator_editors"],
        :custodians => ["custodian_buildings", "custodian_contacts", "custodian_identifiers", "custodian_names", "custodian_owners", "custodian_urls", "custodian_editors"],
        # Upgrade 2.0.0 inizio
        #      :projects => ["project_credits", "project_urls"],
        :projects => ["project_managers", "project_stakeholders", "project_urls"],
        # Upgrade 2.0.0 fine
        :sources => ["source_urls"],
        :institutions => ["institution_editors"],
        :document_forms => ["document_form_editors"]
    }

    entities.each do |target, tables|
      target_field = "#{target}".singularize + "_id"
      tables.each do |table|
        case adapter
        when 'sqlite'
          ar_connection.execute("UPDATE #{table} SET #{target_field} = (SELECT id
                                 FROM #{target}
                                 WHERE #{table}.legacy_id = #{target}.legacy_id
                                 AND #{table}.db_source = #{target}.db_source
                                 AND #{target}.db_source = '#{self.identifier}')
                                 WHERE EXISTS (
                                  SELECT * FROM #{target}
                                  WHERE #{table}.legacy_id = #{target}.legacy_id
                                  AND #{table}.db_source = #{target}.db_source
                                  AND #{target}.db_source = '#{self.identifier}')")
        when 'mysql', 'mysql2'
          ar_connection.execute("UPDATE #{table} r, #{target} c SET r.#{target_field} = c.id
                                 WHERE r.legacy_id = c.legacy_id
                                 AND r.db_source = c.db_source
                                 AND c.db_source = '#{self.identifier}'")
        when 'postgresql'
          ar_connection.execute("UPDATE #{table} SET #{target_field} = c.id FROM #{target} c
                                 WHERE #{table}.legacy_id = c.legacy_id
                                 AND #{table}.db_source = c.db_source
                                 AND c.db_source = '#{self.identifier}'")
        end
      end
    end
  end

  def update_many_to_many_relations
    tables = {
        :rel_creator_creators => ["creators", "creators"],
        :rel_creator_fonds => ["creators", "fonds"],
        :rel_creator_institutions => ["creators", "institutions"],
        :rel_creator_sources => ["creators", "sources"],
        :rel_custodian_fonds => ["custodians", "fonds"],
        :rel_custodian_sources => ["custodians", "sources"],
        :rel_fond_document_forms => ["fonds", "document_forms"],
        :rel_fond_headings => ["fonds", "headings"],
        :rel_fond_sources => ["fonds", "sources"],
        :rel_project_fonds => ["projects", "fonds"],
        :rel_unit_headings => ["units", "headings"],
        :rel_unit_sources => ["units", "sources"]
    }

    tables.each do |table, entities|
      first_entity_field = "#{entities[0]}".singularize + "_id"
      first_legacy_entity_field = "legacy_" + "#{entities[0]}".singularize + "_id"

      if entities[0] == entities[1]
        second_entity_field = "related_" + "#{entities[1]}".singularize + "_id"
        second_legacy_entity_field = "legacy_related_" + "#{entities[1]}".singularize + "_id"
      else
        second_entity_field = "#{entities[1]}".singularize + "_id"
        second_legacy_entity_field = "legacy_" + "#{entities[1]}".singularize + "_id"
      end

      case adapter
      when 'sqlite'
        query = "UPDATE #{table}
                 SET #{first_entity_field} = (SELECT id
                 FROM #{entities[0]}
                 WHERE #{table}.#{first_legacy_entity_field} = #{entities[0]}.legacy_id
                 AND #{table}.db_source = '#{self.identifier}'
                 AND #{entities[0]}.db_source = '#{self.identifier}')
                 WHERE EXISTS (
                    SELECT * FROM #{entities[0]}
                    WHERE #{table}.#{first_legacy_entity_field} = #{entities[0]}.legacy_id
                    AND #{table}.db_source = '#{self.identifier}'
                    AND #{entities[0]}.db_source = '#{self.identifier}');"
        ar_connection.execute(query)
      when 'mysql', 'mysql2'
        query = "UPDATE #{table} r, #{entities[0]} c
                 SET r.#{first_entity_field} = c.id
                 WHERE r.#{first_legacy_entity_field} = c.legacy_id
                 AND r.db_source = '#{self.identifier}'
                 AND c.db_source = '#{self.identifier}'"
        ar_connection.execute(query)
      when 'postgresql'
        query = "UPDATE #{table}
                 SET #{first_entity_field} = c.id
                 FROM #{entities[0]} c
                 WHERE #{table}.#{first_legacy_entity_field} = c.legacy_id
                 AND #{table}.db_source = '#{self.identifier}'
                 AND c.db_source = '#{self.identifier}'"
        ar_connection.execute(query)
      end

      case adapter
      when 'sqlite'
        query = "UPDATE #{table}
                 SET #{second_entity_field} = (SELECT id
                 FROM #{entities[1]}
                 WHERE #{table}.#{second_legacy_entity_field} = #{entities[1]}.legacy_id
                 AND #{table}.db_source = '#{self.identifier}'
                 AND #{entities[1]}.db_source = '#{self.identifier}')
                 WHERE EXISTS (
                    SELECT * FROM #{entities[1]}
                    WHERE #{table}.#{second_legacy_entity_field} = #{entities[1]}.legacy_id
                    AND #{table}.db_source = '#{self.identifier}'
                    AND #{entities[1]}.db_source = '#{self.identifier}');"
        ar_connection.execute(query)
      when 'mysql', 'mysql2'
        query = "UPDATE #{table} r, #{entities[1]} c
                 SET r.#{second_entity_field} = c.id
                 WHERE r.#{second_legacy_entity_field} = c.legacy_id
                 AND r.db_source = '#{self.identifier}'
                 AND c.db_source = '#{self.identifier}'"
        ar_connection.execute(query)
      when 'postgresql'
        query = "UPDATE #{table}
                 SET #{second_entity_field} = c.id
                 FROM #{entities[1]} c
                 WHERE #{table}.#{second_legacy_entity_field} = c.legacy_id
                 AND #{table}.db_source = '#{self.identifier}'
                 AND c.db_source = '#{self.identifier}'"
        ar_connection.execute(query)
      end

    end
  end

  def update_digital_objects
    attachable_entities = {
        'Fond' => 'fonds',
        'Unit' => 'units',
        'Creator' => 'creators',
        'Custodian' => 'custodians',
        'Source' => 'sources'
    }

    attachable_entities.each do |value, table|
      # Upgrade 2.0.0 inizio
      #set = DigitalObject.all(:conditions => {:attachable_type => value, :db_source => self.identifier})
      set = DigitalObject.where({:attachable_type => value, :db_source => self.identifier})
      # Upgrade 2.0.0 fine
      unless set.blank?
        ids = set.map(&:id).join(',')
        case adapter
        when 'sqlite'
          query = "UPDATE digital_objects SET attachable_id = (SELECT id
                   FROM #{table}
                   WHERE digital_objects.legacy_id = #{table}.legacy_id
                   AND digital_objects.db_source = #{table}.db_source
                   AND #{table}.db_source = '#{self.identifier}'
                   AND digital_objects.id IN (#{ids}))
                   WHERE EXISTS (
                    SELECT * FROM #{table}
                    WHERE digital_objects.legacy_id = #{table}.legacy_id
                    AND digital_objects.db_source = #{table}.db_source
                    AND #{table}.db_source = '#{self.identifier}'
                    AND digital_objects.id IN (#{ids}));"
          ar_connection.execute(query)
        when 'mysql', 'mysql2'
          query = "UPDATE digital_objects do, #{table} e SET do.attachable_id = e.id
                   WHERE do.legacy_id = e.legacy_id
                   AND do.db_source = e.db_source
                   AND e.db_source = '#{self.identifier}'
                   AND do.id IN (#{ids})"
          ar_connection.execute(query)
        when 'postgresql'
          query = "UPDATE digital_objects SET attachable_id = e.id
                   FROM #{table} e
                   WHERE digital_objects.legacy_id = e.legacy_id
                   AND digital_objects.db_source = e.db_source
                   AND e.db_source = '#{self.identifier}'
                   AND digital_objects.id IN (#{ids})"
          ar_connection.execute(query)
        end
      end
    end

    # Upgrade 3.0.0 inizio
    # Copia degli oggetti digitali dall'aef alla destinazione fisica
    Zip::File.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") { |zip_file|
      zip_file.each { |f|
        if (f.name.include? "public") && (f.name.include? "digital_objects")
          f_path = File.join("#{Rails.root}/", f.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          zip_file.extract(f, f_path) { true } unless File.exist?(f_path)
        end
      }
    }
    # Upgrade 3.0.0 fine

  end

  # Upgrade 2.2.0 inizio
  def update_sc2_second_level_relations
    tables =
        [
            {:table => "sc2_attribution_reasons", :parent_table => "sc2_authors", :foreign_key => "sc2_author_id"},
            {:table => "sc2_commission_names", :parent_table => "sc2_commissions", :foreign_key => "sc2_commission_id"}
        ]

    tables.each do |settings|
      table = settings[:table]
      parent_table = settings[:parent_table]
      if ((!table.nil? || table != "") && (!parent_table.nil? || parent_table != ""))
        foreign_key = settings[:foreign_key]
        if (foreign_key.nil? || foreign_key == "") then
          foreign_key = "#{parent_table}".singularize + "_id"
        end
        case adapter
        when 'sqlite'
          sql_stmt = "UPDATE #{table} SET #{foreign_key} = (SELECT id
                                 FROM #{parent_table}
                                 WHERE #{table}.legacy_id = #{parent_table}.legacy_current_id
                                 AND #{table}.db_source = #{parent_table}.db_source
                                 AND #{parent_table}.db_source = '#{self.identifier}')
                                 WHERE EXISTS (
                                  SELECT * FROM #{parent_table}
                                  WHERE #{table}.legacy_id = #{parent_table}.legacy_current_id
                                  AND #{table}.db_source = #{parent_table}.db_source
                                  AND #{parent_table}.db_source = '#{self.identifier}')"
        when 'mysql', 'mysql2'
          sql_stmt = "UPDATE #{table} r, #{parent_table} c SET r.#{foreign_key} = c.id
                                 WHERE r.legacy_id = c.legacy_current_id
                                 AND r.db_source = c.db_source
                                 AND c.db_source = '#{self.identifier}'"
        when 'postgresql'
          sql_stmt = "UPDATE #{table} SET #{foreign_key} = c.id FROM #{parent_table} c
                                 WHERE #{table}.legacy_id = c.legacy_current_id
                                 AND #{table}.db_source = c.db_source
                                 AND c.db_source = '#{self.identifier}'"
        else
          sql_stmt = ""
        end
        if (sql_stmt != "")
          ar_connection.execute(sql_stmt)
        end
      end
    end
  end
  # Upgrade 2.2.0 fine

  def is_valid_file?
    if @is_batch_import == true
      src_file = File.join(Rails.root, "public", "imports", "batch_import", @batch_import_filename)

      dst_path = File.join(Rails.root, "public", "imports", self.id.to_s, ".")
      dirname = File.dirname(dst_path)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end

      extension = File.extname(@batch_import_filename).downcase
      filename = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
  
      full_dst_filename = filename + "_batch_import" + extension
      dst_file = File.join(Rails.root, "public", "imports", self.id.to_s, full_dst_filename)
      FileUtils.copy_file(src_file, dst_file)
      
      self.data_file_name = full_dst_filename
    end

    begin
      extension = File.extname(data_file_name).downcase.gsub('.', '')
      # Upgrade 3.0.0 inizio     
      raise Zip::ZipInternalError unless ['aef', 'csv', 'xml'].include? extension

    rescue Zip::ZipInternalError
      raise 'Formato file non supportato.'
    end
      # Upgrade 3.0.0 fine  
    if ['aef'].include? extension
      files = ["metadata.json", "data.json"]
      begin
        # Upgrade 2.0.0 inizio
        #      Zip::ZipFile.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") do |zipfile|
        Zip::File.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") do |zipfile|
          # Upgrade 2.0.0 fine
          # Upgrade 3.0.0 inizio
          # esclusi dal controllo di validità i file degli oggetti digitali
          zipfile.each do |entry|
            if (entry.directory?) && (entry.to_s.include? "public")
              next
            else
              if (entry.to_s.include? "public")
                next
              else
                raise Zip::ZipEntryNameError unless files.include? entry.to_s
                zipfile.extract(entry, TMP_IMPORTS + "/#{self.id}_#{entry.to_s}")
              end
            end
          end
          # Upgrade 3.0.0 fine
        end
      rescue Zip::ZipInternalError
        raise 'Il file fornito non è di formato <code>aef</code>'
      rescue Zip::ZipEntryNameError
        raise 'Il file fornito contiene dati non validi'
      rescue Zip::ZipCompressionMethodError
        raise 'Il file <code>aef</code> è danneggiato'
      rescue Zip::ZipDestinationFileExistsError
        raise "Errore interno di #{APP_NAME}, <em>stale files</em> nella directory tmp"
      rescue StandardError => e
        Rails.logger.error e.inspect
        raise "Si è verificato un errore nell'elaborazione del file <code>aef</code>"
      end

      File.open(metadata_file) do |file|
        begin
          lines = file.enum_for(:each_line)
          lines.each do |line|
            next if line.blank?
            data = ActiveSupport::JSON.decode(line.strip)
            raise "Controllo di integrità fallito" unless data['checksum'] == Digest::SHA256.file(data_file).hexdigest
            unless AEF_COMPATIBLE_VERSIONS.include?(data['version'])
              aef_version = data['version'].to_s.scan(%r([0-9])).join(".")
              raise "File incompatibile con questa versione di #{APP_NAME} (#{APP_VERSION}).<br>
              Il file <code>aef</code> è stato prodotto con la versione #{aef_version}."
            end
            self.importable_type = data['attached_entity']

            self.imported_file_version = data['version'].to_s.scan(%r([0-9])).join(".")
          end
        rescue Exception => e
          raise e.message
        ensure
          file.close
        end
      end
    elsif ['csv'].include? extension
      self.importable_type = "Unit"
    end
  end

  def wipe_all_related_records
    tables = ar_connection.tables - ["schema_migrations"]
    begin
      ActiveRecord::Base.transaction do
        # Upgrade 2.2.0 inizio
        importable_type = Import.where("identifier = '#{self.identifier}'").first.importable_type
        if (importable_type == "Unit")
          # l'idea è decrementare il campo units_count dei fondi che contengono le unità importate che si stanno cancellando.
          # i fondi di interesse potrebbero essere più di uno poiché le unità importate potrebbero essere state ricollocate sotto altri fondi dopo la loro importazione. Si selezionano i fond_id dei fondi coinvolti e per ciascuno il numero di unità di interesse che contiene. tale numero deve essere utilizzato per riassegnare correttamente il campo units_count dei fondi
          sql_stmt = "select fond_id, count(*) as n_units from units where db_source='#{self.identifier}' group by fond_id"
          result = ar_connection.execute(sql_stmt)
          result.each do |r|
            fond_id = r["fond_id"].to_s
            n_units = r["n_units"].to_s
            sql_stmt = "update fonds set units_count=units_count-#{n_units} where id=#{fond_id}"
            ar_connection.execute(sql_stmt)
          end
        end
        # Upgrade 2.2.0 fine
        tables.each do |table|
          model = table.classify.constantize
          object = model.new
          if object.has_attribute? 'db_source'
            # Upgrade 3.0.0 inizio
            # Vengono eliminati fisicamente gli oggetti digitali precedentemente importati   
            # insieme alle cartelle corrispondenti e prima dell'eliminazione dei record corrispondenti su db
            if table.include? "digital_objects"
              digital_object_ids = DigitalObject.where(:db_source => self.identifier).map(&:access_token)
              digital_object_ids.each do |doi|
                delete_digital_folder(doi)
              end
            end
            # Upgrade 3.0.0 fine
            model.delete_all("db_source = '#{self.identifier}'")
          end
        end
      end
      return true
    rescue Exception => e
      Rails.logger.info "################ Errore=" + e.message
      return false
    end
  end

  private

  # Upgrade 2.2.0 inizio
  def prv_get_ref_root_fond_id
    if self.ref_root_fond_id.nil?
      ref_root_fond_id = self.ref_fond_id
    else
      ref_root_fond_id = self.ref_root_fond_id
    end
    return ref_root_fond_id
  end
  # Upgrade 2.2.0 fine

  def sanitize_file_name
    if !@is_batch_import
      extension = File.extname(data_file_name).downcase
      filename = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
      self.data.instance_write(:file_name, "#{filename}#{extension}")
    end
  end

  def prv_adjust_ante_210_project(key, ipdata)
    begin
      if key == "project"
        case ipdata["project_type"]
        when "riordino e schedatura"
          ipdata["project_type"] = "riordino"
        when "schedatura"
          ipdata["project_type"] = "recupero"
        end
      end
    rescue Exception => e
    end
    return key
  end

  def prv_adjust_ante_210_project_credits(key, ipdata)
    begin
      if key == "project_credit"
        if ipdata.has_key?("credit_name")
          ipdata["name"] = ipdata.delete("credit_name")
        end

        if ipdata.has_key?("credit_type")
          if ipdata["credit_type"] == "PS"
            if ipdata.has_key?("qualifier")
              case ipdata["qualifier"]
              when "coordinatore"
                key = "project_stakeholder"
                ipdata["qualifier"] = "coordinamento operativo"
              when "finanziatore"
                key = "project_stakeholder"
                ipdata["qualifier"] = "finanziamento"
              when "promotore"
                key = "project_stakeholder"
                ipdata["qualifier"] = "promozione"
              when "realizzatore"
                key = "project_stakeholder"
                ipdata["qualifier"] = "realizzazione"
              when "schedatore"
                key = "project_manager"
              when "responsabile scientifico"
                key = "project_manager"
              # Upgrade 2.1.0 inizio
              else
                key = "project_stakeholder"
              # Upgrade 2.1.0 fine
              end
            end
          else
            # caso ipdata["credit_type"] == "PM" o ipdata["credit_type"] == qualsiasi altro valore
            if ipdata.has_key?("qualifier")
              case ipdata["qualifier"]
              when "coordinatore"
                key = "project_manager"
              when "finanziatore"
                key = "project_stakeholder"
                ipdata["qualifier"] = "finanziamento"
              when "promotore"
                key = "project_stakeholder"
                ipdata["qualifier"] = "promozione"
              when "realizzatore"
                key = "project_stakeholder"
                ipdata["qualifier"] = "realizzazione"
              when "schedatore"
                key = "project_manager"
              when "responsabile scientifico"
                key = "project_manager"
              # Upgrade 2.1.0 inizio
              else
                key = "project_manager"
              # Upgrade 2.1.0 fine
              end
            end
          end
        end
      end
    rescue
    end
    return key
  end
end
