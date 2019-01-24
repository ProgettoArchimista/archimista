related_fonds = source.fonds
xml.catRecord do
  xml.catRecordHeader :type => "strumento di ricerca" do
    xml.id "SR-#{source.id}"
    xml.lastUpdate source.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
  end
  xml.catRecordBody do
    xml.ead :xmlns => "http://san.mibac.it/ricerca-san/" do
      xml.eadheader do
        url = source.source_urls.present? ? source.source_urls[0].url : ""
        xml.eadid "SR-#{source.id}", :identifier => "#{metadata['PROVIDER_DL']}", :URL => url

        xml.filedesc do

          # OPTIMIZE: raffinare titolo (o abstract) di articoli di rivista e simili
          xml.titlestmt do
            xml.author source.author if source.author.present?
            xml.titleproper source.title
          end

          xml.publicationstmt do
            xml.date source.date_string
            xml.address source.place if source.place.present?
            xml.publisher source.publisher if source.publisher.present?
          end

          # OPTIMIZE: decidere se raccogliere altre info, oltre a abstract. Direi di no.
          # "i sistemi di provenienza potranno far confluire in questo elemento, per un massimo di 1500 caratteri,
          # informazioni di natura diversa:
          # a) descrizione dello strumento di ricerca; e/o
          # b) tipologia dello strumento;
          # c) la parte del fondo cui lo strumento si riferisce;
          # d) altre informazioni pertinenti."

          if source.abstract.present?
            type = source.finding_aid_published? ? {:type => "edito"} : ""
            xml.notestmt do
              xml.note source.abstract, type
            end
          end

          if source.source_urls.present?
            xml.editionstmt do
              source.source_urls.each do |source_url|
                xml.edition do
                  xml.extptr :href => source_url.url, :title => "link"
                end
              end
            end
          end

        end
      end

      xml.archdesc do
        xml.did do
          related_fonds.each do |fond|
            xml.unitid "CA-#{fond.id}"
          end
        end
      end
    end
  end
end

