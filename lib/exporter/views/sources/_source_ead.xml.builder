first_fond_level = nil

xml.control do
  sr_id_str = sprintf '%08d', source.id
  xml.recordid "SR-#{sr_id_str}"

  # Estensione 2018
  # Aggiunta
  # Relazione con una URL
  if source.source_urls.present?
    source.source_urls.each do |source_url|
      xml.representation source_url.note, :href => source_url.url
    end
  end
  
  xml.filedesc do
    xml.titlestmt do
      xml.titleproper source.title
      if source.author.present?
        xml.author source.author, :localtype => "Author"
      end
      if source.editor.present?
        xml.author source.editor, :localtype => "Curator"
      end
    end

    # Estensione 2018
    # Aggiunta
    # Tipologia, Edito
    xml.editionstmt do
      xml.edition source.source_type.source_type, :localtype => "typology"
      if (source.source_type.source_type == "strumento di corredo" && source.finding_aid_published == 1)
        xml.edition "si", :localtype => "published"
      else
        xml.edition "no", :localtype => "published"
      end      
    end

    # Estensione 2018
    # Modifica
    # Modificato il valore del tag date
    # Aggiunti i sottotag publisher e address
    xml.publicationstmt do
      if source.year.present?
        xml.date source.year, {:localtype => "singledate", :normal => "AAAA"}
      end      
      xml.publisher source.editor
      xml.address do
        xml.addressline source.place
      end
    end

    if source.abstract.present?
        xml.notestmt do
          xml.controlnote :localtype => "Notestoriche" do
            xml.p source.abstract
          end 
        end
      end
  end
  xml.maintenancestatus :value => "new"
  xml.publicationstatus :value => "published"
  xml.maintenanceagency do
    xml.agencyname PROVIDER
  end
  xml.languagedeclaration do
    xml.language :langcode => "ita"
    xml.script :scriptcode => "Italiano"
  end
  xml.conventiondeclaration do
    xml.citation PROVIDER
  end

  # Estensione 2018
  # Aggiunta
  # Relazione con un complesso archivistico  
  fond_first_levels = {
    "archivio" => "fonds",
    "complesso di fondi" => "recordgrp",
    "iperfondo" => "recordgrp",
    "fondo" => "fonds",
    "subfondo" => "subfonds",
    "sezione" => "subfonds",
    "sottosezione" => "otherlevel",
    "partizione" => "subfonds",
    "sottopartizione" => "subfonds",
    "serie" => "series",
    "sottoserie" => "subseries",
    "sottosottoserie" => "subseries",
    "parte" => "subfonds",
    "categoria" => "otherlevel",
    "classe" => "otherlevel",
    "sottoclasse" => "otherlevel",
    "rubrica" => "otherlevel",
    "voce" => "otherlevel",
    "sottovoce" => "otherlevel",
    "titolo" => "otherlevel",
    "sottotitolo" => "otherlevel",
    "articolo" => "otherlevel"
  }
  first_fond_level_set = false
  related_fonds = source.fonds.order(:id)
  if related_fonds.present?
    related_fonds.each do |fond|
      if first_fond_level_set == false
        if fond.fond_type.empty?
          first_fond_level = "fonds"
        else
          level = fond.fond_type
          if fond_first_levels[level].nil?
            first_fond_level = "otherlevel"
          else
            first_fond_level = fond_first_levels[level]
          end
        end
        first_fond_level_set = true
      end
      xml.localcontrol :localtype => "complArchCollegato" do
	    ca_id_str = sprintf '%08d', fond.id
        xml.term fond.name, :identifier => "CA-#{ca_id_str}"
      end
    end
  end
  
  xml.maintenancehistory do
    xml.maintenanceevent do
      xml.eventtype :value => "created"
      xml.eventdatetime ""
      xml.agenttype :value => "human"
      xml.agent ""
    end
  end
end

# Estensione 2018
# Modifica
# Tag vuoto con l'indicazione del livello del complesso collegato. Se sono presenti più complessi va indicato il livello del primo.
xml.archdesc :level => first_fond_level do
  xml.did do
    xml.unittitle
  end
end
