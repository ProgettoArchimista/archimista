xml.tag! "scons", {
  :"xsi:schemaLocation" => "http://www.san.beniculturali.it/scons2 http://www.san.beniculturali.it/tracciato/scons2.xsd",
  :"xmlns"              => "http://www.san.beniculturali.it/scons2",
  :"xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
  :"xmlns:xlink"        => "http://www.w3.org/1999/xlink"
}  do
  editors = custodian.custodian_editors
  if !editors.empty?
    xml.info  do
      event_types = {
        "aggiornamento scheda" => "modifica",
        "inserimento dati" => "creazione",
        "integrazione successiva" => "modifica",
        "prima redazione" => "creazione",
        "revisione" => "modifica",
        "rielaborazione" => "modifica",
        "schedatura" => "altro"
      }
      editors.each do |editor|
        if editor.edited_at.present?
          event_date = editor.edited_at.strftime("%Y-%m-%dT%H:%M:%S")
        else
          event_date = ""
        end
        xml.evento :dataEvento => event_date, :tipoEvento => event_types[editor.editing_type.downcase] do
          xml.agente :tipo => "persona" do
            xml.cognome editor.name
          end
        end
      end
    end
  end
  xml.identificativi do
    xml.identificativosistema PROVIDER
	id_str = sprintf '%08d', custodian.id
	xml.identificativo "SC-#{id_str}", :tipo => PROVIDER, :href => "#{CUSTODIANS_URL}/#{custodian.id}"
    if custodian.custodian_identifiers.present?
      custodian.custodian_identifiers.each do |identifier|
        xml.altroidentificativo identifier.identifier, :tipo => identifier.identifier_source
      end
    end
  end
  xml.denominazione custodian.preferred_name.name, :qualifica => "principale"
  if custodian.other_names.present?
    qualifiers = {"au" => "altraDenominazione", "pa" => "parallela", "ac" => "acronimo", "ot" => "altraDenominazione"}
    custodian.other_names.each do |other_name|
      xml.denominazione other_name.name, :qualifica => qualifiers[other_name.qualifier.downcase]
    end
  end
  custodian_types = {
    "stato" => "TesauroSAN/archivio_di_Stato",
    "regione" => "TesauroSAN/regione-regione_a_statuto_speciale_conservatore",
    "ente pubblico territoriale" => "TesauroSAN/ente_territoriale",
    "ente funzionale territoriale" => "TesauroSAN/ente_diverso",
    "ente economico / impresa" => "TesauroSAN/ente_economico-impresa-studio_professionale_conservatore",
    "ente di credito, assicurativo, previdenziale" => "TesauroSAN/istituto_di_credito",
    "ente di assistenza e beneficenza" => "TesauroSAN/ente_di_assistenza-beneficenza-previdenza-servizi_alla_persona",
    "ente sanitario" => "TesauroSAN/ente_sanitario",
    "ente di istruzione e ricerca" => "TesauroSAN/ente_di_cultura-ente_di_ricerca",
    "ente di cultura, ricreativo, sportivo, turistico" => "TesauroSAN/ente_ricreativo-sportivo-turistico_conservatore",
    "partito politico, organizzazione sindacale" => "TesauroSAN/sindacato-organizzazione_sindacale_conservatore",
    "ordine professionale, associazione di categoria" => "TesauroSAN/arte-ordine-collegio-associazione_di_categoria",
    "ente e associazione della chiesa cattolica" => "TesauroSAN/ente_e_associazione_di_culto_cattolico",
    "ente e associazione di culto acattolico" => "TesauroSAN/ente_e_associazione_di_culti_acattolici",
    "persona o famiglia" => "TesauroSAN/persona-famiglia"
  }
  custodian_type = custodian.custodian_type.present? ? custodian_types[custodian.custodian_type.custodian_type.downcase] : "altro"
  xml.tipologia custodian_type
  xml.localizzazioni do
    custodian.custodian_buildings.each_with_index do |custodian_building, i|
      if i == 0
        principale = "S"
      else
        principale = "N"
      end
      if custodian_building.custodian_building_type == "sede di consultazione"
        consultazione = "S"
      else
        consultazione = "N"
      end
      xml.localizzazione :identificativo => custodian_building.id, :principale => principale, :consultazione => consultazione, :privato => "N" do
        xml.denominazione custodian_building.name
        attributes = {:paese => "ITA", :comune => custodian_building.city}
        if custodian_building.postcode.present?
          attributes[:cap] = custodian_building.postcode
        end
        if custodian_building.address.present?
          attributes[:denominazioneStradale] = custodian_building.address
        end
        xml.indirizzo attributes
        if (i < 1)
          if custodian.custodian_contacts.present?
            contact_types = {"tel" => "telefono", "fax" => "fax", "email" => "mail"}
            custodian.custodian_contacts.each do |custodian_contacts|
              contact_type = custodian_contacts.contact_type? ? contact_types[custodian_contacts.contact_type.downcase] : "altro"
              xml.contatto custodian_contacts.contact, :tipo => contact_type
            end
          end
          xml.orario custodian.accessibility
        end  
      end
    end
  end
  xml.descrizione custodian.history
  xml.servizi custodian.services
  xml.relazioni do
    custodian.custodian_urls.each do |custodian_url|
      xml.relazione (custodian_url.note.present? ? custodian_url.note : custodian_url.url), :tipo => "URL", :href => custodian_url.url
    end
    custodian.sources.each do |source|
      if (source.source_type.code == 1)
        xml.relazione source.title, :tipo => "BIBTEXT", :href => "#{SOURCES_URL}/#{source.id}"
      else
        xml.relazione source.title, :tipo => "FONTETEXT", :href => "#{SOURCES_URL}/#{source.id}"
      end
    end
	custodian.fonds.each do |fond|
      fond_id_str = sprintf '%08d', fond.id
      xml.relazione "CA-#{fond_id_str}", :tipo => "COMPL", :href => "#{FONDS_URL}/#{fond.id}"
    end
  end
end
