xml.control do
  pi_id_str = sprintf '%08d', institution.id
  xml.recordId "PI-#{pi_id_str}"
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
    
    editors = institution.institution_editors
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
  xml.identity :localType => "profiloIstituzionale" do
    xml.entityType "corporateBody"
    xml.nameEntry do
      xml.part institution.name
    end
  end
  if institution.description.present?
    xml.description do
      xml.biogHist do
        xml.abstract institution.description
      end
    end
  end
  
  query = "SELECT * FROM creators sc WHERE sc.id IN (SELECT rci.creator_id FROM rel_creator_institutions rci WHERE rci.institution_id = #{institution.id});"
  creators = Creator.find_by_sql(query)
  if creators.present?
    xml.relations do
      creators.each do |creator|
        xml.cpfRelation :cpfRelationType => "hierarchical", :"xlink:href" => "#{CREATORS_URL}/#{creator.id}" do
          sp_id_str = sprintf '%08d', creator.id
          xml.relationEntry "SP-#{sp_id_str}", :localType => "soggettoProduttore"
        end
      end 
    end
  end
end
