xml.tag! "envelope:record" do

xml.tag! "envelope:recordHeader", :DIRECTIVE => "UPSERT" do
  xml.tag! "envelope:recordIdentifier", "#{metadata['PROVIDER_DL']}-UA-#{unit.id}"
  xml.tag! "envelope:recordDatestamp", Time.now.strftime("%Y-%m-%dT%H:%M:%S")
end

xml.tag! "envelope:recordBody" do
  xml.tag! "mets:mets" do

    custodians = unit.fond.root.custodians

    xml.tag! "mets:metsHdr", {
      :CREATEDATE   => Time.now.strftime("%Y-%m-%dT%H:%M:%S"),
      :LASTMODDATE  => Time.now.strftime("%Y-%m-%dT%H:%M:%S"),
      :RECORDSTATUS => "Complete"
    } do

      xml.tag! "mets:agent", :TYPE => "ORGANIZATION", :ROLE => "CREATOR" do
        xml.tag! "mets:name", metadata['PROVIDER_DL']
      end

      xml.tag! "mets:agent", :TYPE => "ORGANIZATION", :ROLE => "IPOWNER" do
        xml.tag! "mets:name", custodians.present? ? custodians[0].preferred_name.name : metadata['PROVIDER_DL']
      end

      xml.tag! "mets:altRecordID", "#{metadata['PROVIDER_DL']}:UA-#{unit.id}", :TYPE => metadata['PROVIDER_DL']

    end

    xml.tag! "mets:dmdSec", :GROUPID => "desc", :ID => "ead-context-001" do
      xml.tag! "mets:mdWrap", :MIMETYPE => "text/xml", :LABEL => "Contesto", :MDTYPE => "EAD", :MDTYPEVERSION => "Arch" do
        xml.tag! "mets:xmlData" do
          xml.tag! "ead-context:ead" do
            xml.tag! "ead-context:archdesc" do
              xml.tag! "ead-context:did" do
                xml.tag! "ead-context:unitid", "#{metadata['DL_UNITID']}"
                xml.tag! "ead-context:unittitle", "#{metadata['DL_UNITTITLE']}"
                if custodians.present?
                  xml.tag! "ead-context:repository", :id => "#{metadata['DL_REPOSITORYID']}" do
                    xml.tag! "ead-context:corpname", "#{metadata['DL_CORPNAME']}"
                    xml.tag! "ead-context:abbr", "#{metadata['DL_ABBR']}"
                  end
                end
              end
            end
          end
        end
      end
    end

    xml.tag! "mets:dmdSec", :GROUPID => "desc", :ID => "ead-desc-001" do
      xml.tag! "mets:mdWrap", :MIMETYPE => "text/xml", :LABEL => "Descrizione oggetto", :MDTYPE => "EAD", :MDTYPEVERSION => "Arch" do
        xml.tag! "mets:xmlData" do
          xml.tag! "ead:c" do
            xml.tag! "ead:did" do
              xml.tag! "ead:unitid", "#{metadata['PROVIDER_DL']}:UA-#{unit.id}"
              xml.tag! "ead:unittitle", unit.title
              if unit.content.present?
                xml.tag! "ead:abstract", unit.content
              else
                xml.tag! "ead:abstract", ""
              end
              if unit.preferred_event.present?
                xml.tag! "ead:unitdate", unit.preferred_event.full_display_date, {
                  :normal => [unit.preferred_event.start_date_from.strftime("%Y%m%d"), unit.preferred_event.end_date_to.strftime("%Y%m%d")].uniq.join("/"),
                  :datechar => "principale"
                }
              else
                xml.tag! "ead:unitdate", "non indicata", :normal => "00000101", :datechar => "non indicata"
              end
              xml.tag! "ead:physdesc" do
                xml.tag! "ead:genreform", unit.unit_type, :type => "tipologie documentarie"
              end
              lingue = unit.unit_langs
              if lingue.present?
                lingue.each do |l|
                  xml.tag! "ead:langmaterial" do
                    xml.tag! "ead:language", :langcode => l.code
                  end
                end
              end
            end
            xml.tag! "ead:dao", :"xlink:href" => "#{FONDS_URL}/#{unit.fond.id}/units/#{unit.id}"
          end
        end
      end
    end

    xml.tag! "mets:dmdSec", :ID => "rel" do
      xml.tag! "mets:mdWrap", :MIMETYPE => "text/xml", :LABEL => "Relazioni SAN", :MDTYPE => "OTHER", :OTHERMDTYPE => "RDF" do
        xml.tag! "mets:xmlData" do
          xml.tag! "rdf:RDF" do
            xml.tag! "rdf:Description", :"rdf:about" => "#{metadata['PROVIDER_DL']}:UA-#{unit.id}" do
              xml.tag! "san-dl:haSistemaAderente", :"rdf:resource" => metadata['PROVIDER_DL']
              xml.tag! "san-dl:haProgettoDigitalizzazione", :"rdf:resource" =>  metadata['DL_HAPROGETTO']
              xml.tag! "san-dl:haConservatore", :"rdf:resource" =>  metadata['DL_HACONSERVATORE']
              xml.tag! "san-dl:haComplesso", :"rdf:resource" =>  metadata['DL_HACOMPLESSO']
            end
          end
        end
      end
    end

    xml.tag! "mets:amdSec" do
      xml.tag! "mets:rightsMD", :ID => "amdRD001" do
        xml.tag! "mets:mdWrap", :MIMETYPE => "text/xml", :LABEL => "Diritti oggetto digitale", :MDTYPE => "METSRIGHTS" do
          xml.tag! "mets:xmlData" do
            xml.tag! "metsrights:RightsDeclarationMD", :RIGHTSCATEGORY => "COPYRIGHTED" do
              xml.tag! "metsrights:RightsHolder" do
                xml.tag! "metsrights:RightsHolderName", custodians.present? ? custodians[0].preferred_name.name : metadata['PROVIDER_DL']
              end
            end
          end
        end
      end

      xml.tag! "mets:rightsMD", :ID => "amdRA001" do
        xml.tag! "mets:mdWrap", :MIMETYPE => "text/xml", :LABEL => "Diritti oggetto analogico", :MDTYPE => "METSRIGHTS" do
          xml.tag! "mets:xmlData" do
            xml.tag! "metsrights:RightsDeclarationMD", :RIGHTSCATEGORY => "COPYRIGHTED" do
              xml.tag! "metsrights:RightsHolder" do
                xml.tag! "metsrights:RightsHolderName", custodians.present? ? custodians[0].preferred_name.name : metadata['PROVIDER_DL']
              end
            end
          end
        end
      end
    end

    xml.tag! "mets:fileSec" do
      dob = unit.digital_objects.all.order(:position).first
      dob_id_str = sprintf '%08d', dob.id
      xml.tag! "mets:fileGrp", :USE => "thumbnail image" do
        xml.tag! "mets:file", :MIMETYPE => "image/jpeg", :ID => "OD-#{dob_id_str}" do
          xml.tag! "mets:FLocat", :LOCTYPE => "URL",
          :"xlink:href" => "#{DIGITAL_OBJECTS_URL}/#{dob.access_token}/thumb.jpg"
        end
      end
      xml.tag! "mets:fileGrp", :USE => "reference image" do       
        xml.tag! "mets:file", :MIMETYPE => "image/jpeg", :ID => "OD-#{dob_id_str}" do
          xml.tag! "mets:FLocat", :LOCTYPE => "URL", :"xlink:href" => "#{DIGITAL_OBJECTS_URL}/#{dob.access_token}/original.jpg"
        end
      end
    end

  end
end

end