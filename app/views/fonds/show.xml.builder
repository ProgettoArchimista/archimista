xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.declare! :DOCTYPE, :ead, :PUBLIC,
  "+//ISBN 1-931666-00-8//DTD ead.dtd (Encoded Archival Description (EAD) Version 2002)//EN",
  "ead.dtd"

xml.ead :"xsi:schemaLocation" => "http://ead3.archivists.org/schema/ http://www.archivesportaleurope.net/Portal/profiles/ead3.xsd",
  :"xmlns"              => "http://ead3.archivists.org/schema/",
  :"xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",  
  :"xmlns:xlink"        => "http://www.w3.org/1999/xlink" do
  xml.control :repositoryencoding => "iso15511",
    :countryencoding => "iso8859-1",
    :dateencoding => "iso8601",
    :scriptencoding => "iso15924",
    :langencoding => "iso639-2b",
    :relatedencoding => "ISAD(G)" do
    xml.recordid @fond.name, {:countrycode => "it", :encodinganalog => "identifier", :identifier => "#{@fond.name.parameterize.underscore}.xml"}
    xml.filedesc do
      xml.titlestmt do
        xml.titleproper @fond.name, {:encodinganalog => "title"}
        #xml.author @fond.projects.first.name, {:encodinganalog => "creator"} unless @fond.projects.blank?
      end
      #xml.publicationstmt do
        #xml.publisher "#{APP_NAME} #{APP_VERSION}", {:encodinganalog => "publisher"}
      #end
    end
    #xml.profiledesc do
      #xml.creation do
        #xml.text! "#{APP_CREATOR}"
        #xml.date Date.today.to_s, {:normal => "#{Date.today.to_s.gsub('-','')}"}
      #end
    #end
    xml.maintenancestatus :value => "new" 
    xml.maintenanceagency do
      xml.agencyname "#{PROVIDER}"
    end
    xml.languagedeclaration do
      xml.language :langcode => "ita"
      xml.script  :scriptcode => "Italian"
    end
    xml.conventiondeclaration do
      xml.citation "SAN"
    end

    xml.maintenancehistory do
      editors = @fond.fond_editors
      editors.each do |e|
        xml.maintenanceevent do
          xml.eventtype :value => e.editing_type
          xml.eventdatetime e.edited_at
          xml.agenttype :value => e.qualifier
          xml.agent e.qualifier
        end
      end
    end
    
  end
  xml.archdesc :level => "otherlevel", :otherlevel => "#{@fond.fond_type}", :id => "CA-#{@fond.id}" do
    xml.did do
      xml.physdesc do
        xml.extent @fond.extent, {:label => "consistenza"} unless @fond.extent.blank?
        xml.extent @fond.length, {:label => "metri lineari"} unless @fond.length.blank?
      end
      xml.repository do
        @fond.custodians.each do |custodian|
          id = custodian.custodian_identifiers.first
          if id.nil?
            xml.corpname do 
              xml.part custodian.preferred_name.name
            end
          else
            xml.corpname :identifier => id.identifier do 
              xml.part custodian.preferred_name.name
            end
          end
          buildings = custodian.custodian_buildings
          buildings.each do |b|
            xml.address do
              xml.addressline b.address + ", " +  b.postcode + ", " +  b.city
            end
          end
        end
      end
      xml.origination do
        @fond.creators.each do |creator|
          id = creator.creator_identifiers.first
          case creator.creator_type
          when 'C'
            if id.nil?
              xml.corpname do
                xml.part creator.preferred_name.name
              end
            else
              xml.corpname :identifier => id.identifier do
                xml.part creator.preferred_name.name
              end
            end
          when 'P'
            if id.nil?
              xml.persname do
                xml.part creator.preferred_name.name
              end
            else
              xml.persname :identifier => id.identifier do
                xml.part creator.preferred_name.name
              end
            end            
          when 'F'
            if id.nil?
              xml.famname do
                xml.part creator.preferred_name.name
              end
            else
              xml.famname :identifier => id.identifier do
                xml.part creator.preferred_name.name
              end
            end            
          end
        end
      end
      #@fond.fond_identifiers.each do |identifier|
        #xml.unitid identifier.identifier, { :encodinganalog => "1.1", :countrycode => "it", :repositorycode => "#{identifier.identifier_source}" }
      #end
      id = @fond.fond_identifiers.first
      xml.unitid "CA-#{@fond.id}", { :localtype => "#{@fond.fond_type}", :repositorycode => "#{id.identifier}" }
      xml.unittitle @fond.name, {:localtype => "Denominazione"}
      other_names = @fond.other_names
      other_names.each do |on|
        xml.unittitle on.name, {:localtype => on.note}
      end
      if @fond.preferred_event.present? && @fond.preferred_event.valid?
        xml.unitdate :normal => [@fond.preferred_event.start_date_from.strftime("%Y%m%d"), @fond.preferred_event.end_date_to.strftime("%Y%m%d")].uniq.join("/") do
          xml.date @fond.preferred_event.try(:full_display_date)
          xml.expan @fond.preferred_event.try(:note), {:abbr => "DATENOTE" } if @fond.preferred_event.note.present?
          case @fond.preferred_event.start_date_valid
          when 'Q'
            xml.expan "attribuita", {:abbr => "VALIDITA" }
          when 'U'
            xml.expan "incerta", {:abbr => "VALIDITA" }
          when 'UQ'
            xml.expan "incerta e attribuita", {:abbr => "VALIDITA" }
          end
        end
      end
    end
    if @fond.history.present?
      xml.custodhist do
        xml.p @fond.history
      end
    end
    if @fond.description.present?
      xml.scopecontent do
        xml.p @fond.description
      end
    end
    if @fond.arrangement_note.present?
      xml.arrangement do
        xml.p @fond.arrangement_note
      end
    end
    if @fond.access_condition.present?
      xml.accessrestrict do
        xml.p @fond.access_condition_note
      end
    end
    if @fond.published?
      xml.processinfo do
        xml.p "Pubblicata"
      end
    end
    xml.relations do
      relfondsourcesnorm = @fond.sources.where("source_type_code = 4")
      relfondsourcesnorm.each do |rfs|
        xml.relation :relationtype => "otherrelationtype", :otherrelationtype => "Fonte" do
          xml.relationentry rfs.title
        end
      end
      relfonddocument = @fond.document_forms
      relfonddocument.each do |rfd|
        xml.relation :relationtype => "otherrelationtype", :otherrelationtype => "Tipologia", :href => "#{DOCUMENT_FORMS_URL}/#{rfd.id}", :id => "#{rfd.id}" do
          xml.relationentry rfd.name
        end
      end
      relfondsourcesbib = @fond.sources.where("source_type_code = 1")
      relfondsourcesbib.each do |rfsb|
        xml.relation :relationtype => "otherrelationtype", :otherrelationtype => "BIBTEXT" do
          xml.relationentry rfsb.title
        end
      end
      relfondsourcesfonte = @fond.sources.where("source_type_code = 2")
      relfondsourcesfonte.each do |rfsf|
        xml.relation :relationtype => "otherrelationtype", :otherrelationtype => "FONTETEXT" do
          xml.relationentry rfsf.title
        end
      end
    end
    xml.dsc do
      xml << render(:partial => "ead_units.xml", :locals => { :start_from => @fond.ancestry_depth, :units => @fond.units })
      if @fond.has_children?
        #xml << render(:partial => "ead_fonds.xml", :locals => { :fonds => @fond.children.all(:conditions => "id != #{@fond.id}", :order => :sequence_number)})
        xml << render(:partial => "ead_fonds.xml", :locals => { :fonds => @fond.children.where("id != #{@fond.id}").order(:sequence_number) } )
      end
    end
  end
end