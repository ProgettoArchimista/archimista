xml.ead :"xsi:schemaLocation" => "http://ead3.archivists.org/schema/ http://www.san.beniculturali.it/tracciato/ead3.xsd",
  :"xmlns" => "http://ead3.archivists.org/schema/",
  :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",  
  :"xmlns:xlink"  => "http://www.w3.org/1999/xlink" do

  xml.control :repositoryencoding => "iso15511",
    :countryencoding => "iso3166-1",
    :dateencoding => "iso8601",
    :scriptencoding => "iso15924",
    :langencoding => "iso639-2b",
    :relatedencoding => "ISAD(G)" do
    xml.recordid fond.name, {:instanceurl => "#{FONDS_URL}/#{fond.id}"}
    xml.filedesc do
      xml.titlestmt do
        xml.titleproper fond.name, {:encodinganalog => "title"}
      end
    end
    xml.maintenancestatus :value => "new" 
    xml.maintenanceagency do
      xml.agencyname "#{PROVIDER}"
    end
    xml.languagedeclaration do
      xml.language :langcode => "ita"
      xml.script :scriptcode => "Italian"
    end
      xml.conventiondeclaration do
      xml.citation "SAN"
    end
    xml.maintenancehistory do
      xml.maintenanceevent do
        xml.eventtype :value => "created"
        xml.eventdatetime ""
        xml.agenttype :value => "human"
        xml.agent ""
      end
    end

    fond_sources = fond.sources
    if fond_sources.present?
      xml.sources do
        fond_sources.each do |fond_source|
          sr_id_str = sprintf '%08d', fond_source.id
          xml.source :id => "SR-#{sr_id_str}", :href => "#{SOURCES_URL}/#{fond_source.id}", :linkrole => "URL" do
              xml.sourceentry fond_source.title
          end
        end
      end
    end
  end
  
  fond_types = {
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
  root_fond_type = fond_types.key?(fond.root.fond_type) ? fond_types[fond.root.fond_type] : "fonds"
  if root_fond_type == "otherlevel"
    attributes = {:level => root_fond_type, :otherlevel => root_fond.fond_type}
  else
    attributes = {:level => root_fond_type}
  end
  xml.archdesc attributes do
    if fond.ancestry.nil?
      xml << render(:partial => "fond_desc_ii.xml", :locals => {
        :fond_types => fond_types,
        :fond => fond
      })
    else
      xml.did do
        rf_id_str = sprintf '%08d', fond.root.id
        xml.unitid "CA-#{rf_id_str}", :identifier => "CA-#{rf_id_str}"
        xml.unittitle fond.root.name, :localtype => "denominazione"
      end
      
      xml.dsc do
        parents_id = fond.ancestry.split("/")
        xml << render(:partial => "fond_parent_ii.xml", :locals => {
          :parents_id => parents_id,
	      :fond_types => fond_types,
	      :fond => fond
        })
      end
    end
  end
end