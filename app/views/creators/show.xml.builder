xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.tag! "eac-cpf", {
  :"xsi:schemaLocation" => "http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd",
  :"xmlns"              => "urn:isbn:1-931666-33-4",
  :"xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",  
  :"xmlns:xs"           => "http://www.w3.org/2001/XMLSchema",
  :"xmlns:xlink"        => "http://www.w3.org/1999/xlink"
} do
  xml.control do
    xml.recordid "SP.#{@creator.id}"
    xml.maintenancestatus "new"
    xml.publicationtatus @creator.published? ? "published" : "not published"
    xml.maintenanceagency do
      xml.agencyname PROVIDER
    end
    xml.languagedeclaration do
      xml.language "Italian", :languageCode => "ita"
      xml.script "Italian", :scriptCode => "Italiano"
    end
    xml.conventiondeclaration do
      xml.citation PROVIDER
    end
    editors = @creator.creator_editors
    event_type = {"Aggiornamento scheda" => "updated", "Inserimento dati" => "created",
       "Integrazione successiva" => "updated", "Prima redazione" => "revised",
       "Revisione" => "revised", "Rielaborazione" => "derived", "Schedatura" => "unknown"}
    if editors.present?
      xml.maintenanceHistory do
        editors.each do |editor|
          xml.maintenanceEvent do
            xml.eventType event_type[editor.editing_type]
            xml.eventDateTime editor.edited_at, :standardDate => editor.edited_at.strftime("%Y-%m-%dT%H:%M:%S")
            xml.agentType "human"
            xml.agent editor.name
          end
        end
      end
    end
  end 
  xml.cpfDescription do
    xml.identity do
      types = {"C" => "corporateBody", "P" => "person", "F" => "family"}
      entityType = types[@creator.creator_type]
      xml.entityType entityType
      xml.nameEntry do
        xml.part @creator.preferred_name.name, :localType => "Denominazione"
      end
      qualifier = {"AU" => "Altra denominazione principale", "PA" => "Denominazione parallela", "AC" => "Acronimo", "OT" => "Altre denominazioni"}
      @creator.other_names.each do |other_name|
        entityQualifier = qualifier[other_name.qualifier]
        xml.nameEntry :localType => entityQualifier do
          xml.part other_name.name
        end
      end
    end
    xml.description do
      case @creator.creator_type
      when 'C'
        xml.existDates do
          xml.dateRange :localType => "Data di esistenza" do
            xml.fromDate @creator.preferred_event.start_date_display, :standardDate => @creator.preferred_event.start_date_from.strftime("%Y-%m-%d")
            xml.toDate @creator.preferred_event.end_date_display, :standardDate => @creator.preferred_event.end_date_to.strftime("%Y-%m-%d")
          end
        end
        xml.place do
          xml.placeRole "Sede"
          xml.placeEntry @creator.residence.present? ? @creator.residence : "non indicata"
          if @creator.preferred_event.note.present?
            xml.descriptiveNote do
              xml.p @creator.preferred_event.note
            end
          end
        end
      when 'P'
        xml.existDates do
          xml.date @creator.preferred_event.start_date_display, :standardDate => @creator.preferred_event.start_date_from.strftime("%Y%m%d"), :localType => "Data di nascita" 
        end
        xml.existDates do
          xml.date @creator.preferred_event.end_date_display, :standardDate => @creator.preferred_event.end_date_from.strftime("%Y%m%d"), :localType => "Data di morte"
        end
        if @creator.preferred_event.present?
          if @creator.preferred_event.start_date_place.present?
            xml.place do
              xml.placeRole "Luogo di nascita"
              xml.placeEntry @creator.preferred_event.start_date_place.present? ? @creator.preferred_event.start_date_place : "non indicata"
              if @creator.preferred_event.note.present?
                xml.descriptiveNote do
                  xml.p @creator.preferred_event.note
                end
              end
            end
          end
          if @creator.preferred_event.end_date_place.present?
            xml.place do
              xml.placeRole "Luogo di morte"
              xml.placeEntry @creator.preferred_event.end_date_place.present? ? @creator.preferred_event.end_date_place : "non indicata"
              if @creator.preferred_event.note.present?
                xml.descriptiveNote do
                  xml.p @creator.preferred_event.note
                end
              end
            end
          end
        end                      
      when 'F'
        xml.existDates :localType => "Data remota" do
          xml.dateRange do
            xml.fromDate @creator.preferred_event.start_date_display, :standardDate => @creator.preferred_event.start_date_from.strftime("%Y-%m-%d")
            xml.toDate @creator.preferred_event.start_date_display, :standardDate => @creator.preferred_event.start_date_to.strftime("%Y-%m-%d")
          end
        end
        xml.existDates :localType => "Data recente" do
          xml.dateRange do
            xml.fromDate @creator.preferred_event.end_date_display, :standardDate => @creator.preferred_event.end_date_from.strftime("%Y-%m-%d")
            xml.toDate @creator.preferred_event.end_date_display, :standardDate => @creator.preferred_event.end_date_to.strftime("%Y-%m-%d")
          end
        end
        xml.place do
          xml.placeRole "Luogo"
          xml.placeEntry "non indicato"
          if @creator.preferred_event.note.present?
            xml.descriptiveNote do
              xml.p @creator.preferred_event.note
            end
          end
        end       
      end
      if @creator.creator_identifiers.present?
        identifiers = @creator.creator_identifiers
        identifiers.each do |id|
          xml.localDescription :localType => "Codici" do
            xml.term id.identifier
            xml.descriptiveNote do
              xml.p id.note
            end
          end
        end
      end
      if @creator.creator_legal_statuses.present?
        status = {"PU" => "Pubblico", "PR" => "Privato", "EC" => "Ecclesiastico", "NA" => "Non definito"}
        legalStatuses = @creator.creator_legal_statuses
        xml.legalStatuses do
          legalStatuses.each do |ls|
            xml.legalStatus do
              xml.term status[ls.legal_status]
            end            
          end
        end
      end
      if @creator.history.present?
        xml.biogHist do
          xml.abstract @creator.history
        end
      end
    end
    xml.relations do
      related_fonds = @creator.fonds
      if related_fonds.present?
        related_fonds.each do |fond|
          xml.cpfRelation :cpfRelationType => "creatorOf", :"href" => "#{FONDS_URL}/#{fond.id}" do
            xml.relationEntry "CA.#{fond.id}", :localType => "Complesso"
          end
        end
      end

      related_institutions = @creator.rel_creator_institutions
      if related_institutions.present?
        related_institutions.each do |institution|
          xml.cpfRelation :cpfRelationType => "hierarchical", :"href" => "#{INSTITUTIONS_URL}/#{institution.id}" do
            xml.relationEntry "PI.#{institution.id}", :localType => "Profilo Istituzionale"
          end
        end
      end
      
      related_creators = @creator.rel_creator_creators
      if related_creators.present?
        related_creators.each do |rel|
          xml.cpfRelation :cpfRelationType => rel.creator_association_type.association_type , :"href" => "#{CREATORS_URL}/#{rel.related_creator_id}" do
            xml.relationEntry "SP.#{rel.related_creator_id}", :localType => "Soggetto Produttore"
          end
        end 
      end

      relcreatorsourcesbib = @creator.sources.where("source_type_code = 1")
      if relcreatorsourcesbib.present?
        relcreatorsourcesbib.each do |rcsb|
          xml.cpfRelation :cpfRelationType => "other" do
            xml.relationentry "SR.#{rcsb.id}", :localType => "BIBID"
          end
        end
      end 

      relcreatorsourcesfonte = @creator.sources.where("source_type_code = 2")
      if relcreatorsourcesfonte.present?
        relcreatorsourcesfonte.each do |rcsf|
          xml.cpfRelation :cpfRelationType => "other" do
            xml.relationentry "SR.#{rcsf.id}", :localType => "FONTEID"
          end
        end
      end   
          
      related_urls = @creator.creator_urls
      if related_urls.present?
        related_urls.each do |url|
          xml.cpfRelation :cpfRelationType => "other", :"href" => url.url do
            xml.relationEntry url.note, :localType => "URI"
          end
        end 
      end

    end
  end 
end
