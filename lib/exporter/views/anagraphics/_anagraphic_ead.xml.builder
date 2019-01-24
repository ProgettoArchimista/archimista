sa_id_str = sprintf '%08d', anagraphic.id

xml.control do
  xml.recordId "SA-#{sa_id_str}"
  identifiers = anagraphic.anag_identifiers
  if identifiers.present?
    identifiers.each do |identifier|
      xml.otherRecordId identifier.identifier, :localType => CGI.escape(identifier.qualifier)
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
  end
end 
xml.cpfDescription do
  xml.identity do
    xml.entityId "SA-#{sa_id_str}", :localType => ""
    xml.entityType "person"
    xml.nameEntry do
      xml.part anagraphic.name, :localType => "nome"
      xml.part anagraphic.surname, :localType => "cognome"
    end
  end
  xml.description do
    xml.existDates do
      xml.dateRange :localType => "Data di esistenza" do
        if anagraphic.start_date.present?
          xml.fromDate anagraphic.start_date, :standardDate => anagraphic.start_date.strftime("%Y-%m-%d")
        elsif
          xml.fromDate "?"
        end
        if anagraphic.end_date.present?
          xml.toDate anagraphic.end_date, :standardDate => anagraphic.end_date.strftime("%Y-%m-%d")
        elsif
          xml.toDate "-", :standardDate => "2099-12-31"
        end
      end
    end
    xml.place do
      xml.placeRole "TesauroSAN/luogo di nascita", :vocabularySource => "http://dati.san.beniculturali.it/SAN/TesauroSAN/Tipo_luogo_CPF"
      xml.placeEntry anagraphic.start_date_place.present? ? anagraphic.start_date_place : "non indicata"
    end
    xml.place do
      xml.placeRole "TesauroSAN/luogo di morte", :vocabularySource => "http://dati.san.beniculturali.it/SAN/TesauroSAN/Tipo_luogo_CPF"
      xml.placeEntry anagraphic.end_date_place.present? ? anagraphic.end_date_place : "non indicata"
    end
  end
end
