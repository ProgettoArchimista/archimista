xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.tag! "icar-import:icar-import", {
  :"xmlns:xlink" => "http://www.w3.org/1999/xlink",
  :"xmlns:icar-import" => "http://www.san.beniculturali.it/icar-import",
  :"xmlns:dc" => "http://purl.org/dc/elements/1.1/",
  :"xmlns:ead" => "http://ead3.archivists.org/schema/",
  :"xmlns:scons" => "http://www.san.beniculturali.it/scons",
  :"xmlns:eac-cpf" => "urn:isbn:1-931666-33-4",
  :"xmlns:mets" => "http://www.loc.gov/METS/",
  :"xmlns:metsrights" => "http://cosimo.stanford.edu/sdr/metsrights/",
  :"xmlns:mix" => "http://www.loc.gov/mix/v20",
  :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  :"xsi:schemaLocation" => "http://www.san.beniculturali.it/icar-import http://www.san.beniculturali.it/tracciato/icar-import.xsd"
} do
  datetime = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
  xml.tag! "icar-import:header" do
    xml.tag! "icar-import:systemId", PROVIDER
    xml.tag! "icar-import:systemTitle", ICAR_IMPORT_SYSTEM_TITLE
    xml.tag! "icar-import:contact" do
      xml.tag! "icar-import:mail", ICAR_IMPORT_CONTACT_MAIL
    end
    xml.tag! "icar-import:event", {:eventType => "creation", :eventDate => datetime} do
      xml.tag! "icar-import:agent", {:agentType => "software"}, "Archimista"
    end
    xml.tag! "icar-import:fileDesc" do
      xml.tag! "icar-import:title", ICAR_IMPORT_FILE_DESC_TITLE
      xml.tag! "icar-import:abstract", ICAR_IMPORT_FILE_DESC_ABSTRACT
      xml.tag! "icar-import:date", datetime
    end
  end
  xml.tag! "icar-import:listRecords" do
    #EAD3 (complessi archivistici, unità archivistiche)
    xml.tag! "icar-import:record" do
      xml.tag! "icar-import:recordHeader", {:action => "insert", :groupEad => "single", :type => "ead3"} do
        ca_id_str = sprintf '%08d', fond.id
        xml.tag! "icar-import:id", "CA-#{ca_id_str}"
        xml.tag! "icar-import:lastUpdate", fond.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
      end
      xml.tag! "icar-import:recordBody" do
        view = ActionView::Base.new(views_path("fonds"))
        xml << view.render(:file => "fonds_ii.xml.builder", :locals => {:fond => fond})
      end
    end
    
    #complessi coinvolti nell'esportazione
    fonds_id = Array.new
    fonds_id.push(fond.id)
    if fond.ancestry.nil?
      query = "ancestry LIKE '#{fond.id}/%' OR ancestry = '#{fond.id}'"
    else
      query = "ancestry LIKE '#{fond.ancestry}/%' OR ancestry = '#{fond.ancestry}'"
    end
    children_ids = Fond.where(query).pluck(:id)
    fonds_id = fonds_id + children_ids
    
    #unità coinvolte nell'esportazione
    units_id = Unit.where(fond_id: fonds_id).pluck(:id)
    
    #SCONS2 (soggetti conservatori)
    custodians = Custodian.where(id: RelCustodianFond.where(fond_id: fond.root_id).pluck(:custodian_id))
    # è possibile definire il conservatore solo a livello di fondo radice, quindi nella query si specifica solo fond.root_id
    custodians.each do |custodian|
      xml.tag! "icar-import:record" do
        xml.tag! "icar-import:recordHeader", {:action => "insert", :groupEad => "single", :type => "scons"} do
          sc_id_str = sprintf '%08d', custodian.id
          xml.tag! "icar-import:id", "SC-#{sc_id_str}"
          xml.tag! "icar-import:lastUpdate", custodian.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
        end
        xml.tag! "icar-import:recordBody" do
          view = ActionView::Base.new(views_path("custodians"))
          xml << view.render(:file => "custodians_ead.xml.builder", :locals => {:records => [custodian], :is_icar_import => true})
        end
      end
    end
    
    #EAC-CPF (soggetti produttori)
    creators = Creator.where(id: RelCreatorFond.where(fond_id: fonds_id).pluck(:creator_id))
    creators_id = Array.new
    creators.each do |creator|
      creators_id.push(creator.id)
      
      xml.tag! "icar-import:record" do
        xml.tag! "icar-import:recordHeader", {:action => "insert", :groupEad => "single", :type => "eac-cpf"} do
          sp_id_str = sprintf '%08d', creator.id
          xml.tag! "icar-import:id", "SP-#{sp_id_str}"
          xml.tag! "icar-import:lastUpdate", creator.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
        end
        xml.tag! "icar-import:recordBody" do
          view = ActionView::Base.new(views_path("creators"))
          xml << view.render(:file => "creators_ead.xml.builder", :locals => {:records => [creator], :is_icar_import => true})
        end
      end
    end
    
    #EAC-CPF (profili istituzionali)
    institutions = Institution.where(id: RelCreatorInstitution.where(creator_id: creators_id).pluck(:institution_id))
    institutions.each do |institution|
      xml.tag! "icar-import:record" do
        xml.tag! "icar-import:recordHeader", {:action => "insert", :groupEad => "single", :type => "eac-cpf"} do
          pi_id_str = sprintf '%08d', institution.id
          xml.tag! "icar-import:id", "PI-#{pi_id_str}"
          xml.tag! "icar-import:lastUpdate", institution.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
        end
        xml.tag! "icar-import:recordBody" do
          view = ActionView::Base.new(views_path("institutions"))
          xml << view.render(:file => "institutions_ead.xml.builder", :locals => {:records => [institution], :is_icar_import => true})
        end
      end
    end
    
    #EAC-CPF (schede anagrafiche)
    anagraphics = Anagraphic.where(id: RelUnitAnagraphic.where(unit_id: units_id).pluck(:anagraphic_id))
    anagraphics.each do |anagraphic|
      xml.tag! "icar-import:record" do
        xml.tag! "icar-import:recordHeader", {:action => "insert", :groupEad => "single", :type => "eac-cpf"} do
          sa_id_str = sprintf '%08d', anagraphic.id
          xml.tag! "icar-import:id", "SA-#{sa_id_str}"
          xml.tag! "icar-import:lastUpdate", anagraphic.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
        end
        xml.tag! "icar-import:recordBody" do
          view = ActionView::Base.new(views_path("anagraphics"))
          xml << view.render(:file => "anagraphics_ead.xml.builder", :locals => {:records => [anagraphic], :is_icar_import => true})
        end
      end
    end
    
    #EAD3 (fonti archivistiche)
    sources_id = RelFondSource.where(fond_id: fonds_id).pluck(:source_id)
    sources = Source.where(id: sources_id)
    sources.each do |source|
      xml.tag! "icar-import:record" do
        xml.tag! "icar-import:recordHeader", {:action => "insert", :groupEad => "single", :type => "ead3"} do
          sr_id_str = sprintf '%08d', source.id
          xml.tag! "icar-import:id", "SR-#{sr_id_str}"
          xml.tag! "icar-import:lastUpdate", source.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
        end
        xml.tag! "icar-import:recordBody" do
          view = ActionView::Base.new(views_path("sources"))
          xml << view.render(:file => "sources_ead.xml.builder", :locals => {:records => [source], :is_icar_import => true})
        end
      end
    end
  end
end