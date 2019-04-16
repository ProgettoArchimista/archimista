base_types = {
  "fascicolo o altra unità complessa" => "file",
  "unità documentaria" => "item",
  "registro o altra unità rilegata" => "registro"
}
file_types = {
  "fascicolo di edilizia" => "fascicolodiedilizia",
  "fascicolo personale" => "fascicolopersonale"
}
sc2_tsks = {
  "CARS" => "cartografiastorica",
  "D" => "”disegnoartistico",
  "DT" => "disegnotecnico",
  "F" => "fotografia",
  "S" => "stampa"
}
unit_types = {
  "base_types" => base_types,
  "file_types" => file_types,
  "sc2_tsks" => sc2_tsks
}
unit_type = unit_types["base_types"].key?(unit.unit_type) ? unit_types["base_types"][unit.unit_type] : ""
if unit_type == "registro"
  file_type = unit_type
else
  file_type = unit_types["file_types"].key?(unit.file_type) ? unit_types["file_types"][unit.file_type] : nil
end
sc2_tsk = unit_types["sc2_tsks"].key?(unit.sc2_tsk) ? unit_types["sc2_tsks"][unit.sc2_tsk] : nil

if file_type.nil? and sc2_tsk.nil?
  attributes = {:level => unit_type}
else
  if !file_type.nil?
    otherlevel = file_type
  else
    otherlevel = sc2_tsk
  end
  attributes = {:level => "otherlevel", :otherlevel => otherlevel}
end
xml.c attributes do
  sequence_numbers = Unit.display_sequence_numbers_of(Fond.find(unit.root_fond_id).root)
  sequence_number = sequence_numbers[unit.id]
    
  xml.did do
    ua_id_str = sprintf '%08d', unit.id
    xml.unitid "UA-#{ua_id_str}", :identifier => "UA-#{ua_id_str}"
    xml.unitid sequence_number, :localtype => "numeroOrdinamento"
    xml.unitid unit.tmp_reference_number, :localtype => "segnaturaProvvisoria", :label => "numero"
    xml.unitid unit.tmp_reference_string, :localtype => "segnaturaProvvisoria", :label => "testo"
    xml.unitid unit.folder_number, :localtype => "busta"
    xml.unitid unit.file_number, :localtype => "numFascicolo"
    xml.unitid unit.reference_number, :localtype => "segnaturaAttuale"
  
    if unit.unit_identifiers.present?
      unit.unit_identifiers.each do |identifier|
        xml.unitid identifier.identifier, :localtype => identifier.identifier_source, :identifier => identifier.identifier
      end
    end
  
    #fascicolo edilizio
    if (unit.unit_type == "fascicolo o altra unità complessa") && (unit.file_type == "fascicolo di edilizia")
      classificazione = ""
      codice = ""
      categoria = ""
      classe = ""
      fascicolo = ""
      subfascicolo = ""
      anno = ""

      contexts = unit.fe_contexts
      if contexts.any?
        ufc = contexts[0]

        classificazione = ufc.classification
        fascicolo = ufc.number
        subfascicolo = ufc.sub_number
      end
    
      identifications = unit.fe_identifications
      if contexts.any?
        ufi = identifications[0]

        codice = ufi.code
        categoria = ufi.category
        classe = ufi.identification_class
        anno = ufi.file_year
      end

      xml.unitid classificazione, :localtype => "classificazione", :identifier => classificazione
      xml.unitid codice, :localtype => "codice", :identifier => classificazione
      xml.unitid categoria, :localtype => "categoria", :identifier => classificazione
      xml.unitid classe, :localtype => "classe", :identifier => classificazione
      xml.unitid fascicolo, :localtype => "fascicolo", :identifier => classificazione
      xml.unitid subfascicolo, :localtype => "subfascicolo", :identifier => classificazione
      xml.unitid anno, :localtype => "anno", :identifier => classificazione
    end
    xml.unittitle unit.name, :localtype => "denominazione"

    periodo_data_secolare = [
      "inizio",
      "fine",
      "metà",
      "prima metà",
      "seconda metà",
      "primo quarto",
      "secondo quarto",
      "terzo quarto",
      "ultimo quarto"
    ]
    if unit.preferred_event.present? && unit.preferred_event.valid?
      xml.unitdatestructured do
        xml.dateset do
          if (unit.preferred_event.start_date_from == unit.preferred_event.end_date_from) && (unit.preferred_event.start_date_to == unit.preferred_event.end_date_to)
            if unit.preferred_event.start_date_from == unit.preferred_event.start_date_to
              xml.datesingle unit.preferred_event.start_date_display, :standarddate => unit.preferred_event.start_date_from
            else
              xml.datesingle unit.preferred_event.start_date_display, :notbefore => unit.preferred_event.start_date_from, :notafter => unit.preferred_event.start_date_to
            end
          else
            xml.daterange do
              xml.fromdate unit.preferred_event.start_date_display, :standarddate => unit.preferred_event.start_date_from
              xml.todate unit.preferred_event.end_date_display, :standarddate => unit.preferred_event.end_date_from
            end
          end

          xml.datesingle unit.preferred_event.note, :localtype => "noteAllaData"
        end    
      end
    end
  
    xml.physdescstructured :physdescstructuredtype => "materialtype", :coverage => "whole" do
      xml.quantity unit.extent
      xml.unittype ""
      xml.physfacet unit.medium, :localtype => "Supporto"
    end
	  
    if unit.physical_description.present?
      xml.physdesc unit.physical_description
    end

    if unit.sc2_scales.present? || unit.sc2_techniques.present? || (
        unit.sc2.present? && (
          unit.sc2.lrc.present? || unit.sc2.mtce.present? || unit.sc2.sdtt.present? || unit.sc2.misa.present? || unit.sc2.misl.present?
        ))
      xml.physdescstructured :physdescstructuredtype => "materialtype", :coverage => "whole" do
        xml.quantity ""
        xml.unittype ""
        
        if unit.sc2_techniques.present?
          unit.sc2_techniques.each do |st|
            xml.physfacet st.mtct, :localtype => "Tecnica"
          end
        end

        if unit.sc2.present? && unit.sc2.mtce.present?
          xml.physfacet unit.sc2.mtce, :localtype => "Esecuzione"
        end

        if unit.sc2_scales.present?
          unit.sc2_scales.each do |sc|
            xml.physfacet sc.sca, :localtype => "Scala"
          end
        end

        if unit.sc2.present? && unit.sc2.sdtt.present?
          xml.physfacet unit.sc2.sdtt, :localtype => "Tiporappresentazione"
        end

        if unit.sc2.present? && unit.sc2.misa.present?
          xml.physfacet unit.sc2.misa, :localtype => "altezza"
        end

        if unit.sc2.present? && unit.sc2.misl.present?
          xml.physfacet unit.sc2.misl, :localtype => "larghezza"
        end
        
        if unit.sc2.present? && unit.sc2.lrc.present?
          xml.descriptivenote do
            xml.p do
              xml.geogname :localtype => "Luogorappresentato" do
                xml.part unit.sc2.lrc
              end
            end
          end
        end
      end
    end

    if unit.physical_container_title.present? || unit.physical_container_type.present? || unit.physical_container_number.present?
      xml.container unit.physical_container_title, :localtype => unit.physical_container_type, :containerid => unit.physical_container_number
    end

    unit.digital_objects.each do |dob|
      dobj_id_str = sprintf '%08d', dob.id
      xml.dao :daotype => "derived", :linkrole => dob.asset_content_type, :id => "OD-#{dobj_id_str}", :href => "#{DIGITAL_OBJECTS_URL}/#{dob.access_token}/original.jpg"
    end
  end

  if !(unit.unit_type == "fascicolo o altra unità complessa") || !(unit.file_type == "fascicolo di edilizia")
    if unit.content.present?
      xml.scopecontent do
        xml.p unit.content
      end
    end
  end

  if unit.access_condition.present?
    xml.accessrestrict do
      xml.p unit.access_condition
    end
  end
  if unit.access_condition_note.present?
    xml.accessrestrict do
      xml.p unit.access_condition_note
    end
  end

  if unit.use_condition.present?
    xml.userestrict do
      xml.p unit.use_condition
    end
  end
  if unit.use_condition_note.present?
    xml.userestrict do
      xml.p unit.use_condition_note
    end
  end

  if unit.arrangement_note.present?
    xml.processinfo :localtype => "notaDellArchivista" do
      xml.p unit.arrangement_note
    end
  end

  editors = unit.unit_editors
  if editors.length > 0
    xml.processinfo :localtype => "compilatori" do
      event_types = {
        "aggiornamento scheda" => "modifica",
        "inserimento dati" => "inserimento",
        "integrazione successiva" => "modifica",
        "prima redazione" => "inserimento",
        "revisione" => "modifica",
        "rielaborazione" => "modifica",
        "schedatura" => "inserimento"
      }
      editors.each do |editor|
        xml.processinfo do
          xml.p do
            xml.persname do
              if editor.editing_type.present?
                editing_type = editor.editing_type.downcase
                event_type = event_types.key?(editing_type) ? event_types[editing_type] : "unknown"
              else
                event_type = "unknown"
              end
              xml.part event_type, :localtype => "tipoIntervento"
              xml.part editor.name, :localtype => "compilatore"
              xml.part editor.qualifier, :localtype => "qualifica"
            end
            dateTime = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
            xml.date dateTime, :localtype => "dataIntervento"
          end
        end
      end
    end
  end

  if unit.unit_type.include? "unità documentaria"
    sc2_textual_elements = unit.sc2_textual_elements
    sc2_textual_elements.each do |ste|
      xml.odd :localtype => "ElementiTestuali" do
        xml.p ste.isri
      end     
    end

    sc2_visual_elements = unit.sc2_visual_elements
    sc2_visual_elements.each do |sve|
      xml.odd :localtype => "ElementiFigurati" do
        xml.p sve.stmd
      end     
    end

    if unit.sc2.present? and unit.sc2.dpgf.present?
      xml.odd :localtype => "NumeroTavola" do
        xml.p unit.sc2.dpgf
      end  
    end

    if unit.sc2.present? and unit.sc2.sgti.present?
      xml.controlaccess do
        xml.subject :localtype => "Soggetto" do
          xml.part unit.sc2.sgti
        end
        
        if unit.sc2_authors.present?
          xml.name :relator => "Autore" do
            unit.sc2_authors.each do |sca|
              xml.part sca.autr.present? ? "" : sca.autr, :localtype => "Ruolo"
              xml.part sca.auta.present? ? "" : sca.autn, :localtype => "Autore"
              xml.part sca.autr.present? ? "" : sca.auta, :localtype => "DatiAnagrafici"
              unit.sc2_attribution_reasons.each do |scar|
                xml.part scar.autm.present? ? "" : scar.autm, :localtype => "Attribuzione"
              end
            end
          end
        end

        if unit.sc2_commissions.present?
          xml.name :relator => "Committente" do
            unit.sc2_commissions.each do |sc|
              xml.part sc.cmmc.present? ? "" : sc.cmmc, :localtype => "notecommittenza"
              if !unit.sc2.cmmr.present?
                xml.part unit.sc2.cmmr, :localtype => "numerocommessa"
              end
            end
          end
        end
      end
    else
      if unit.sc2_authors.present?
        xml.controlaccess do
          xml.name :relator => "Autore" do
            unit.sc2_authors.each do |sca|
              xml.part sca.autr.present? ? "" : sca.autr, :localtype => "Ruolo"
              xml.part sca.auta.present? ? "" : sca.autn, :localtype => "Autore"
              xml.part sca.autr.present? ? "" : sca.auta, :localtype => "DatiAnagrafici"
              unit.sc2_attribution_reasons.each do |scar|
                xml.part scar.autm.present? ? "" : scar.autm, :localtype => "Attribuzione"
              end
            end
          end

          if unit.sc2_commissions.present?
            xml.name :relator => "Committente" do
              unit.sc2_commissions.each do |sc|
                xml.part sc.cmmc.present? ? "" : sc.cmmc, :localtype => "notecommittenza"
                if !unit.sc2.cmmr.present?
                  xml.part unit.sc2.cmmr, :localtype => "numerocommessa"
                end
              end
            end
          end
        end
      else
        if unit.sc2_commissions.present?
          xml.controlaccess do
            xml.name :relator => "Committente" do
              unit.sc2_commissions.each do |sc|
                xml.part sc.cmmc.present? ? "" : sc.cmmc, :localtype => "notecommittenza"
                if !unit.sc2.cmmr.present?
                  xml.part unit.sc2.cmmr, :localtype => "numerocommessa"
                end
              end
            end
          end
        end
      end
    end
  end

  relheadings = unit.headings
  if relheadings.length > 0
    xml.controlaccess do
      relheadings.each do |heading|
        if heading.heading_type == "Persona"
          xml.persname do
            xml.part heading.name
            if heading.dates.present?
              xml.part heading.dates, :localtype => "estremiCronologici"
            end
            if heading.qualifier.present?
              xml.part heading.qualifier, :localtype => "qualifica"
            end
          end
        elsif heading.heading_type == "Famiglia"
          xml.famname do
            xml.part heading.name
            if heading.dates.present?
              xml.part heading.dates, :localtype => "estremiCronologici"
            end
            if heading.qualifier.present?
              xml.part heading.qualifier, :localtype => "qualifica"
            end
          end
        elsif heading.heading_type == "Ente"
          xml.corpname do
            xml.part heading.name
            if heading.dates.present?
              xml.part heading.dates, :localtype => "estremiCronologici"
            end
            if heading.qualifier.present?
              xml.part heading.qualifier, :localtype => "qualifica"
            end
          end
        elsif heading.heading_type == "Toponimo"
          xml.geogname do
            xml.part heading.name
            if heading.dates.present?
              xml.part heading.dates, :localtype => "estremiCronologici"
            end
            if heading.qualifier.present?
              xml.part heading.qualifier, :localtype => "qualifica"
            end
          end
        else
          #"Altro"
          xml.subject do
            xml.part heading.name
            if heading.dates.present?
              xml.part heading.dates, :localtype => "estremiCronologici"
            end
            if heading.qualifier.present?
              xml.part heading.qualifier, :localtype => "qualifica"
            end
          end
        end
      end
    end
  end

  xml.relations do
    relunitsources = unit.sources
    if relunitsources.present?
      relunitsources.each do |source|
        if source.source_type_code == 1
          relation_type = "BIBTEXT"
        else
          relation_type = "FONTETEXT"
        end
        xml.relation :relationtype => "otherrelationtype", :otherrelationtype => relation_type, :href => "#{SOURCES_URL}/#{source.id}" do
          xml.relationentry source.title
        end
      end
    end

    xml.relation :relationtype => "otherrelationtype", :href => "#{UNITS_URL}/#{unit.id}", :otherrelationtype => "URL" do
      xml.relationentry PROVIDER
    end
    reluniturls = unit.unit_urls
    if reluniturls.present?
      reluniturls.each do |ruu|
        xml.relation :relationtype => "otherrelationtype", :href => ruu.url, :otherrelationtype => "URL" do
          xml.relationentry ruu.note
        end
      end
    end
  
    unit.anagraphics.each do |anagraphic|
      xml.relation :relationtype => "otherrelationtype", :otherrelationtype => "INDICE" do
        if anagraphic.name.present? and anagraphic.surname.present?
          denominazione = "#{anagraphic.name} #{anagraphic.surname}"
        elsif anagraphic.name.present?
          denominazione = anagraphic.name
        elsif anagraphic.surname.present?
          denominazione = anagraphic.surname
        else
          denominazione = ""
        end
        sa_id_str = sprintf '%08d', anagraphic.id
      
        xml.relationentry denominazione, :localtype => "denominazione"
        xml.relationentry "SA-#{sa_id_str}", :localtype => "identificativo"
      end
    end
  
    #entità padre: può essere un fondo o una unità
    if unit.ancestry.nil?
      entity_url = "#{FONDS_URL}/#{unit.fond_id}"
    else
      if unit.ancestry.include? "/"
        entity_id = unit.ancestry.split('/').last
      else
        entity_id = unit.ancestry
      end
      entity_url = "#{UNITS_URL}/#{entity_id}"
    end
    xml.relation :relationtype => "resourcerelation" do
      xml.relationentry entity_url, :localtype => "ComplArchSup"
    end

    #fratello superiore
    if sequence_number.present? && sequence_number[-1] != "1"
      if sequence_number.include? "."
        prec_sequence_number = Integer(sequence_number[-1]) - 1
        prec_sequence_number = "#{sequence_number[0..-2]}#{prec_sequence_number}"
      else
        prec_sequence_number = "#{Integer(sequence_number[-1]) - 1}"
      end
      entity_id = nil
      sequence_numbers.each do |key, value|
        if (value <=> prec_sequence_number) == 0
          entity_id = key
          break
        end
      end
      if !entity_id.nil?
        entity_url = "#{UNITS_URL}/#{entity_id}"
      
        xml.relation :relationtype => "resourcerelation" do
          xml.relationentry entity_url, :localtype => "ComplArchPrec"
        end
     end
    end
  end

  if (unit.unit_type == "fascicolo o altra unità complessa") && (unit.file_type == "fascicolo di edilizia")
    is_fascicolo_edilizia = true
  else
    is_fascicolo_edilizia = false
  end
  contexts = unit.fe_contexts
  fe_operas = unit.fe_operas
  if fe_operas.present? || (is_fascicolo_edilizia && contexts.any? && unit.content.present?)
    xml.relatedmaterial do
      xml.archref do
        #fascicolo edilizio
        if is_fascicolo_edilizia
          if contexts.any?
            ufec = contexts[0]

            if unit.content.present?
              xml.title do
                xml.part unit.content, :localtype => "contenuto"
              end
            end

            if ufec.applicant.present?
              xml.persname :relator => "richiedente" do
                xml.part ufec.applicant
              end
               xml.genreform do
                xml.part "Fascicolo richiesta licenza edilizia"
              end
            end

            if ufec.request.present?
              xml.title do
                xml.part ufec.request, :localtype => "oggettoLicenza"
              end
            end

            if ufec.license_number.present?
              xml.num ufec.license_number, :localtype => "numeroLicenza"
            end

            if ufec.license_year.present?
              xml.date ufec.license_year, :localtype => "annoLicenza", :normal => "#{ufec.license_year}"
            end

            if ufec.license_date.present?
              xml.date ufec.license_date.strftime("%Y-%m-%d"), :localtype => "dataLicenza", :normal => "#{ufec.license_date.strftime("%Y%m%d")}"
            end

            if ufec.protocol_number.present?
              xml.num ufec.protocol_number, :localtype => "numeroProtocolloSezionale"
            end

            if ufec.habitability_number.present?
              xml.num ufec.habitability_number, :localtype => "numeroAbitabilita"
            end

            if ufec.habitability_year.present?
              xml.date ufec.habitability_year, :localtype => "annoAbitabilita", :normal => "#{ufec.habitability_year}"
            end

            if ufec.habitability_date.present?
              xml.date ufec.habitability_date.strftime("%Y-%m-%d"), :localtype => "dataAbitabilita", :normal => "#{ufec.habitability_date.strftime("%Y%m%d")}"
            end
          end
        end

        if fe_operas.present?
          fe_operas.each do |ufop|
            if ufop.is_present
              opera_present = "S"
              opera_desc = "fascicoloPresente"
            else
              opera_present = "N"
              opera_desc = "fascicoloMancante"
            end
            xml.abbr opera_present, :expan => opera_desc

            if ufop.status.present?
              if ufop.status == "approved"
                opera_status = "SI"
                opera_status_desc = "approvato"
              else
                opera_status = "NO"
                opera_status_desc = "respinto"
              end
              xml.abbr opera_status, :expan => opera_status_desc
            end

            if ufop.building_name.present?
              xml.subject do
                xml.part ufop.building_name, :localtype => "denominazioneEdificio"
                if ufop.building_type.present?
                  xml.part ufop.building_type, :localtype => "tipoEdificio"
                end
              end
            end

            if unit.fe_designers.present?
              unit.fe_designers.each do |ufd|
                if ufd.designer_name.present?
                  xml.persname :relator => "progettista" do
                    xml.part ufd.designer_name
                    if ufd.designer_role.present?
                      xml.part ufd.designer_role, :localtype => "ruoloProgettista"
                    end
                  end
                end
              end
            end
          end

          fe_operas.each do |ufop|
            dati_catastali = unit.fe_cadastrals
            if ufop.place_name.present?
              xml.geogname :relator => ufop.place_type do
                xml.part ufop.place_name, :localtype => "nomeLuogo"
                if ufop.house_number.present?
                  xml.part ufop.house_number, :localtype => "numeroCivico"
                end
                if ufop.district.present?
                  xml.part ufop.district, :localtype => "quartiere"
                end

                if dati_catastali.present?
                  dati_catastali.each do |ufca|
                    if ufca.way_code.present?
                      xml.part ufca.way_code, :localtype => "codiceVia"
                    end
                    if ufca.cadastral_municipality.present?
                      xml.part ufca.cadastral_municipality, :localtype => "comuneCatastale"
                    end
                    if ufca.municipality_code.present?
                      xml.part ufca.municipality_code, :localtype => "numero"
                    end
                  end
                end
              end
            end

            if dati_catastali.present?
              dati_catastali.each do |ufca|
                if ufca.paper_code.present?
                  xml.num ufca.paper_code, :localtype => "foglio"
                end
		      end
            end
            if unit.fe_land_parcels.present?
              unit.fe_land_parcels.each do |uflp|
                xml.num uflp.land_parcel_number, :localtype => "numeroParticellaFondiaria"
              end

              if unit.fe_fract_land_parcels.present?
                unit.fe_fract_land_parcels.each do |ufflp|
                  xml.num ufflp.fract_land_parcel_number, :localtype => "numeroFrazionamentoParticellaFondiaria"
                  xml.num ufflp.edil_parcel_number, :localtype => "numeroParticellaEdilizia"
                end
              end

              if unit.fe_fract_edil_parcels.present?
                unit.fe_fract_edil_parcels.each do |uffelp|
                  xml.num uffelp.fract_edil_parcel_number, :localtype => "numeroFrazionamentoParticellaEdilizia"
                  xml.num uffelp.material_portion, :localtype => "porzioneMateriale"
                end
              end
            end
          end
        end
      end
    end
  end

  if unit.related_materials.present?
    xml.relatedmaterial :localtype => "documentazioneCollegata" do
      xml.p unit.related_materials
    end
  end
  
  unit.children.each do |child|
    xml << view.render(:file => "unit_ii.xml.builder", :locals => {:unit => child, :view => view})
  end
end