xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.scons do
  published = @custodian.published? ? "Pubblicato" : "Non pubblicato"
  xml.info :datacreazione => "#{@custodian.created_at}", :status => published  do
    editors = @custodian.custodian_editors
    editors.each do |e|
      xml.agente :ruolo => e.qualifier, :tipo => "Persona" do
        xml.nome e.name
        xml.intervento e.editing_type
        xml.data e.edited_at, :format => :long
      end
    end
  end
  xml.formaautorizzata @custodian.preferred_name.name
  if @custodian.other_names.present?
    @custodian.other_names.each do |other_name|
      xml.altradenominazione show_item(other_name.name), :qualifica => show_item(t(other_name.qualifier)).capitalize
    end
  end
  xml.identifier :type => PROVIDER, :href => "#{CUSTODIANS_URL}/#{@custodian.id}" do
    xml.recordId "SC-#{@custodian.id}"
    xml.OtherRecordId "#{DL_CONSERVATORE}"
    xml.sistemaId "#{PROVIDER}"
    xml.status published
  end
  if @custodian.custodian_type.present?
    xml.tipologia @custodian.custodian_type.custodian_type.capitalize
  end
  xml.localizzazioni do
    @custodian.custodian_buildings.each_with_index do |custodian_building, i|
      xml.localizzazione :paese => show_item(custodian_building.country), :comune => show_item(custodian_building.city), :cap => show_item(custodian_building.postcode) do
        xml.text!("#{show_item(custodian_building.name)}")
        xml.indirizzo "#{show_item(custodian_building.address)}"
        if(i < 1)
          if @custodian.custodian_contacts.present?
            @custodian.custodian_contacts.each do |custodian_contacts|
              xml.contatto custodian_contacts.contact, {:tipo => custodian_contacts.contact_type}
            end
          end
          xml.orario @custodian.accessibility
          xml.accesso @custodian.services
        end  
      end
    end
  end
  xml.relazioni do
    urls = @custodian.custodian_urls
    urls.each do |url|
      xml.relazione (url.note.present? ? url.note : url.url), {:tipo => "URL", :href => "#{url.url}"}      
    end
    sources = @custodian.sources
    sources.each do |source|
      if (source.source_type.code == 1)
        xml.relazione source.title, {:tipo => "BIB", :sottotipo => "#{source.source_type.source_type}" }
      elsif (source.source_type.code == 3 || source.source_type.code == 4)
        xml.relazione source.title, {:tipo => "FONTE", :id => "SR-#{source.id}"}
      end 
    end
    fonds = @custodian.fonds
    if(fonds.length > 0)
      xml.complessi do
        fonds.each do |fond|
          xml.complesso "CA-#{fond.id}", {:tipo => PROVIDER, :href => "#{FONDS_URL}/#{fond.id}", :data => "#{fond.created_at.strftime("%Y%m%d")}"}
        end        
      end
    end 
  end
  xml.descrizione @custodian.history
end
