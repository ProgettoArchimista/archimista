xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
  xml.tag! "ead", {
    :"xsi:schemaLocation" => "http://ead3.archivists.org/schema/ ead3.xsd",
    :"xmlns"              => "http://ead3.archivists.org/schema/",
    :"xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance"
  } do
    xml.control do
      xml.recordId "SR.#{@source.id}"
      xml.filedesc do
        xml.titlestmt do
          xml.titleproper @source.title
          if @source.author.present?
            xml.author @source.author, :localtype => "Author"
          end
          if @source.editor.present?
            xml.author @source.editor, :localtype => "Curator"
          end
        end
        xml.publicationstmt do
          xml.date @source.date_string, :normal => "AAAA"
        end
        if @source.abstract.present?
            xml.notestmt do
              xml.controlnote :localtype => "Notestoriche" do
                xml.p @source.abstract
              end 
            end
          end
      end
      xml.maintenancestatus :value => "new"
      xml.publicationtatus :value => "published"
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
    end
    xml.archdesc :level => "otherlevel" do
      xml.did do
        xml.unitid "SR-#{@source.id}", :repositorycode => PROVIDER, :identifier => "SR-#{@source.id}"
      end
      xml.relations do
        related_fonds = @source.fonds
        related_fonds.each do |fond|
          xml.relation :relationtype => "otherrelationtype", :otherrelationtype => "#{fond.fond_type}", :href => "#{FONDS_URL}/#{fond.id}" do
            xml.relationentry "CA-#{fond.id}"
          end
        end
        if @source.source_urls.present?
          @source.source_urls.each do |source_url|
            xml.relation :relationtype => "otherrelationtype", :otherrelationtype => "URL", :href => source_url.url do
              if source_url.note.blank?
                xml.relationentry source_url.url
              else
                xml.relationentry source_url.note
              end
            end
          end
        end
      end
    end
end
