root_fond = Fond.find(unit.root_fond_id)

xml.control do
  ua_id_str = sprintf '%08d', unit.id
  xml.recordid "UA-#{ua_id_str}"
  xml.filedesc do
    xml.titlestmt do
      xml.titleproper unit.name
    end
  end
  xml.maintenancestatus :value => "new" 
  xml.maintenanceagency do
    xml.agencyname "#{PROVIDER}"
  end
  if unit.unit_langs.present?
    langs = unit.unit_langs
    langs.each do |l|
      xml.languagedeclaration do
        xml.language :langcode => l.code
        translation = Lang.where("code like ?", l.code)
        xml.script  :scriptcode => translation[0].en_name
      end
    end
  else
    xml.languagedeclaration do
      xml.language :langcode => "ita"
      xml.script  :scriptcode => "Italian"
    end
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
    
    if root_fond.present?
      fond_editors = root_fond.fond_editors
      if fond_editors.present?
        fond_editors_event_type = {
          "aggiornamento scheda" => "updated",
          "inserimento dati" => "created",
          "integrazione successiva" => "updated",
          "prima redazione" => "created",
          "revisione" => "revised",
          "rielaborazione" => "revised",
          "schedatura" => "created"
        }
        fond_editors.each do |fe|
          xml.maintenanceevent do
            if fe.editing_type.present?
		      editing_type = fe.editing_type.downcase
		      event_type = fond_editors_event_type.key?(editing_type) ? fond_editors_event_type[editing_type] : "unknown"
		    else
		      event_type = "unknown"
		    end
            if fe.edited_at.present?
		      edited_at = fe.edited_at.strftime("%Y-%m-%dT%H:%M:%S")
		    end
          
            xml.eventtype :value => event_type
            if !edited_at.nil?
              xml.eventdatetime edited_at, :standarddatetime => edited_at
            elsif
              xml.eventdatetime ""
            end
            xml.agenttype :value => "human"
            xml.agent fe.name
            xml.eventdescription fe.qualifier
          end
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
root_fond_type = fond_types.key?(root_fond.fond_type) ? fond_types[root_fond.fond_type] : "fonds"
if root_fond_type == "otherlevel"
  attributes = {:level => root_fond_type, :otherlevel => root_fond.fond_type}
else
  attributes = {:level => root_fond_type}
end
xml.archdesc attributes do
  xml << render(:partial => "unit_root_fond_archdesc_ead.xml", :locals => {
    :unit => unit,
    :root_fond => root_fond,
    :fond_types => fond_types
  })
end