xml.control do
  sc_id_str = sprintf '%08d', creator.id
  xml.recordId "SP-#{sc_id_str}"
  identifiers = creator.creator_identifiers
  if identifiers.present?
    identifiers.each do |identifier|
      xml.otherRecordId identifier.identifier, :localType => CGI.escape(identifier.identifier_source)
    end
  end
  xml.maintenanceStatus "new"
  xml.publicationStatus "approved"
  xml.maintenanceAgency do
    xml.agencyName PROVIDER
  end
  xml.languageDeclaration do
    xml.language "Italian", :languageCode => "ita"
    xml.script "Italian", :scriptCode => "Ital"
  end
  xml.conventionDeclaration do
    xml.citation "http://dati.san.beniculturali.it/SAN/TesauroSAN/Tipo_luogo_CPF"
  end
  xml.conventionDeclaration do
    xml.citation "http://dati.san.beniculturali.it/SAN/TesauroSAN/natura_giuridica_ente"
  end
  xml.conventionDeclaration do
    xml.citation "http://dati.san.beniculturali.it/SAN/TesauroSAN/sottotipologia_ente"
  end
  xml.conventionDeclaration do
    xml.citation "ISO 639-2"
  end
  xml.conventionDeclaration do
    xml.citation "ISO 8601"
  end
  xml.conventionDeclaration do
    xml.citation "ISO 15924"
  end
  xml.conventionDeclaration do
    xml.citation "NIERA"
  end
  xml.conventionDeclaration do
    xml.citation "ISAAR(CPF)"
  end
  xml.maintenanceHistory do
    xml.maintenanceEvent do
      xml.eventType "created"
      xml.eventDateTime ""
      xml.agentType "human"
      xml.agent ""
    end
    
    editors = creator.creator_editors
    if editors.present?
	  event_types = {
        "aggiornamento scheda" => "updated",
        "inserimento dati" => "created",
        "integrazione successiva" => "updated",
        "prima redazione" => "created",
        "revisione" => "revised",
        "rielaborazione" => "revised",
        "schedatura" => "created"
      }
      editors.each do |editor|
        xml.maintenanceEvent do
		  if editor.editing_type.present?
		    editing_type = editor.editing_type.downcase
		    event_type = event_types.key?(editing_type) ? event_types[editing_type] : "unknown"
		  else
		    event_type = "unknown"
		  end
          
          if editor.edited_at.present?
		    edited_at = editor.edited_at.strftime("%Y-%m-%dT%H:%M:%S")
		  end
          
          xml.eventType event_type
          if !edited_at.nil?
            xml.eventDateTime edited_at, :standardDateTime => edited_at
          elsif
            xml.eventDateTime ""
          end
          xml.agentType "human"
          xml.agent editor.name
          xml.eventDescription editor.qualifier
        end
      end
    end
  end
end 
xml.cpfDescription do
  creator_type = creator.creator_type.downcase
  xml.identity :localType => "soggettoProduttore" do
    types = {"c" => "corporateBody", "p" => "person", "f" => "family"}
    entityType = types[creator_type]
    xml.entityType entityType
    case creator_type
    when 'c'
      xml.nameEntry do
        xml.part creator.preferred_name.name
      end
      creator.other_names.each do |other_name|
        qualifiers = {"au" => "altraDenominazione", "pa" => "parallela", "ac" => "altraDenominazione", "ot" => "altraDenominazione"}
	    qualifier = qualifiers.key?(other_name.qualifier.downcase) ? qualifiers[other_name.qualifier.downcase] : "altraDenominazione"
		if qualifier == "parallela"
		  xml.nameEntryParallel do
		    xml.nameEntry do
              xml.part other_name.name, :lang => other_name.note
            end
          end
		else
          xml.nameEntry do
            xml.part other_name.name, :localType => qualifier
          end
		end
      end
    when 'p'
      xml.nameEntry do
        xml.part creator.preferred_name.name, :localType => "denominazione"
      end
      creator.other_names.each do |other_name|
        xml.nameEntry do
          xml.part other_name.name, :localType => "altraDenominazione"
        end
      end
    when 'f'
      xml.nameEntry do
        xml.part creator.preferred_name.name
      end
      creator.other_names.each do |other_name|
        xml.nameEntry do
          xml.part other_name.name, :localType => "altraDenominazione"
        end
      end
    end
  end
  xml.description do
    case creator_type
    when 'c'
      if creator.preferred_event.present?
        xml.existDates do
          xml.dateRange :localType => "Data di esistenza" do
            if creator.preferred_event.start_date_format != "O"
              xml.fromDate creator.preferred_event.start_date_display, :standardDate => creator.preferred_event.start_date_from.strftime("%Y-%m-%d")
            else
              xml.fromDate creator.preferred_event.start_date_display, :standardDate => "2099" + creator.preferred_event.start_date_from.strftime("-%m-%d")
            end
            if creator.preferred_event.end_date_format != "O"
              xml.toDate creator.preferred_event.end_date_display, :standardDate => creator.preferred_event.end_date_to.strftime("%Y-%m-%d")
            else
              xml.toDate creator.preferred_event.end_date_display, :standardDate => "2099" + creator.preferred_event.end_date_to.strftime("-%m-%d")
            end
          end
		  if creator.preferred_event.note.present?
		    xml.descriptiveNote do
              xml.p creator.preferred_event.note
            end
          end
        end
      end
      xml.place do
        xml.placeRole "TesauroSAN/sede", :vocabularySource => "http://dati.san.beniculturali.it/SAN/TesauroSAN/Tipo_luogo_CPF"
        xml.placeEntry creator.residence.present? ? creator.residence : "non indicata"
      end
	  xml.localDescription :localType => "tipologiaEnte" do
	    corporate_types = {
          "stato" => "TesauroSAN/statali",
          "regione" => "TesauroSAN/regione-regione_a_statuto_speciale_sp",
          "ente pubblico territoriale" => "TesauroSAN/ente_territoriale_minore",
          "ente funzionale territoriale" => "TesauroSAN/ente_territoriale_minore",
          "ente economico / impresa" => "TesauroSAN/ente_economico-impresa-studio_professionale_sp",
          "ente di credito, assicurativo, previdenziale" => "TesauroSAN/banca-istituto_di_credito-ente_assicurativo-ente_previdenziale",
          "ente di assistenza e beneficenza" => "TesauroSAN/opera_pia-istituzione_ed_ente_assistenza_e_beneficenza_ospedale",
          "ente sanitario" => "TesauroSAN/ente_sanitario-ente_servizi_alla_persona",
          "ente di istruzione e ricerca" => "TesauroSAN/scuola-ente_di_istruzione",
          "ente di cultura, ricreativo, sportivo, turistico" => "TesauroSAN/accademia_ente_di_cultura",
          "partito politico, organizzazione sindacale" => "TesauroSAN/partito_e_movimento_politico-associazione_politica",
          "ordine professionale, associazione di categoria" => "TesauroSAN/arte_ordine_collegio_associazione_di_categoria",
          "ente e associazione della chiesa cattolica" => "TesauroSAN/ente_culto_cattolico-associazione_cattolica",
          "ente e associazione di culto acattolico" => "TesauroSAN/ente_di_culto_acattolico-associazione_acattolica",
          "preunitario" => "TesauroSAN/organo_e_ufficio_statale_centrale_del_periodo_preunitario",
          "organo giudiziario" => "TesauroSAN/statali",
          "organo periferico dello stato" => "TesauroSAN/organo_e_ufficio_statale_periferico_di_periodo_postunitario",
          "ente ecclesiastico" => "TesauroSAN/corporazione_religiosa"
	    }
	    ente_type = creator.creator_corporate_type.corporate_type.downcase
        corporate_type = corporate_types.key?(ente_type) ? corporate_types[ente_type] : "altro"
	    xml.term corporate_type, :vocabularySource => "http://dati.san.beniculturali.it/SAN/TesauroSAN/sottotipologia_ente"
	  end
    when 'p'
      if creator.preferred_event.present?
        xml.existDates do
          xml.dateRange do
            if creator.preferred_event.start_date_format != "O"
              xml.fromDate creator.preferred_event.start_date_display, :standardDate => creator.preferred_event.start_date_from.strftime("%Y-%m-%d")
            else
              xml.fromDate creator.preferred_event.start_date_display, :standardDate => "2099" + creator.preferred_event.start_date_from.strftime("-%m-%d")
            end
            if creator.preferred_event.end_date_format != "O"
              xml.toDate creator.preferred_event.end_date_display, :standardDate => creator.preferred_event.end_date_from.strftime("%Y-%m-%d")
            else
              xml.toDate creator.preferred_event.end_date_display, :standardDate => "2099" + creator.preferred_event.end_date_from.strftime("-%m-%d")
            end
          end
        end
        if creator.preferred_event.start_date_place.present?
          xml.place do
            xml.placeRole "TesauroSAN/luogo di nascita", :vocabularySource => "http://dati.san.beniculturali.it/SAN/TesauroSAN/Tipo_luogo_CPF"
            xml.placeEntry creator.preferred_event.start_date_place.present? ? creator.preferred_event.start_date_place : "non indicata"
          end
        end
        if creator.preferred_event.end_date_place.present?
          xml.place do
		    xml.placeRole "TesauroSAN/luogo di morte", :vocabularySource => "http://dati.san.beniculturali.it/SAN/TesauroSAN/Tipo_luogo_CPF"
            xml.placeEntry creator.preferred_event.end_date_place.present? ? creator.preferred_event.end_date_place : "non indicata"
          end
        end
      end
    when 'f'
      xml.existDates do
        if creator.preferred_event.present?
          xml.dateRange do
            if creator.preferred_event.start_date_format != "O"
              xml.fromDate creator.preferred_event.start_date_display, :standardDate => creator.preferred_event.start_date_from.strftime("%Y-%m-%d")
            else
              xml.fromDate creator.preferred_event.start_date_display, :standardDate => "2099" + creator.preferred_event.start_date_from.strftime("-%m-%d")
            end
            if creator.preferred_event.end_date_format != "O"
              xml.toDate creator.preferred_event.end_date_display, :standardDate => creator.preferred_event.end_date_to.strftime("%Y-%m-%d")
            else
              xml.toDate creator.preferred_event.end_date_display, :standardDate => "2099" + creator.preferred_event.end_date_to.strftime("-%m-%d")
            end
          end
        else
          xml.dateRange do
            xml.fromDate "non indicata", :standardDate => "0000-01-01"
            xml.toDate "non indicata", :standardDate => "2099-12-31"
          end
        end
      end
      xml.place do
        xml.placeRole "TesauroSAN/sede", :vocabularySource => "http://dati.san.beniculturali.it/SAN/TesauroSAN/Tipo_luogo_CPF"
        xml.placeEntry "non indicato", :vocabularySource => "http://dati.san.beniculturali.it/ASI"
      end
	  xml.localDescription :localType => "titoli" do
	    xml.term creator.note, :vocabularySource => "NIERA"
	  end
    end
    if creator.creator_legal_statuses.present?
      status = {"PU" => "Pubblico", "PR" => "Privato", "EC" => "Ecclesiastico", "NA" => "Non definito"}
      legalStatuses = creator.creator_legal_statuses
      xml.legalStatuses do
        legalStatuses.each do |ls|
          xml.legalStatus do
            xml.term status[ls.legal_status]
          end            
        end
      end
    end
    if creator.history.present?
      xml.biogHist do
        xml.abstract creator.history
      end
    end
  end
  
  xml.relations do
    related_institutions = creator.rel_creator_institutions
    if related_institutions.present?
      related_institutions.each do |institution|
        xml.cpfRelation :cpfRelationType => "hierarchical", :"xlink:href" => "#{INSTITUTIONS_URL}/#{institution.institution_id}" do
          pi_id_str = sprintf '%08d', institution.id
          xml.relationEntry "PI-#{pi_id_str}", :localType => "profiloIstituzionale"
        end
      end
    end
    
    related_creators = creator.rel_creator_creators
    if related_creators.present?
      related_creators.each do |related_creator|
        xml.cpfRelation :cpfRelationType => "associative", :"xlink:href" => "#{CREATORS_URL}/#{related_creator.related_creator_id}" do
          sp_id_str = sprintf '%08d', related_creator.related_creator_id
          xml.relationEntry "SP-#{sp_id_str}", :localType => "soggettoProduttore"
        end
      end 
    end

    related_fonds = creator.fonds.where(["fond_id IN (?)", fond_ids])
    if related_fonds.present?
      related_fonds.each do |fond|
        xml.resourceRelation :resourceRelationType => "creatorOf", :"xlink:href"  => "#{FONDS_URL}/#{fond.id}" do
          ca_id_str = sprintf '%08d', fond.id
          xml.relationEntry "CA-#{ca_id_str}", :localType => "complesso"
        end
      end
    end

    creator_sources = creator.sources
    if creator_sources.present?
      creator_sources.each do |creator_source|
        if creator_source.source_type_code == 1
          localType = "BIBTEXT"
        else
          localType = "FONTETEXT"
        end
        xml.resourceRelation :resourceRelationType => "other", :"xlink:href" => "#{SOURCES_URL}/#{creator_source.id}" do
          xml.relationEntry creator_source.title, :localType => localType
        end
      end
    end
        
    related_urls = creator.creator_urls
    if related_urls.present?
      related_urls.each do |url|
        xml.resourceRelation :resourceRelationType => "other", :"xlink:href" => url.url do
          xml.relationEntry url.note, :localType => "URI"
        end
      end 
    end
  end
end
