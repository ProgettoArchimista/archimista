xml.did do
  ca2_id_str = sprintf '%08d', fond.id
  xml.unitid "CA-#{ca2_id_str}", :identifier => "CA-#{ca2_id_str}"
  fond.fond_identifiers.each do |identifier|
    xml.unitid identifier.identifier, :localtype => identifier.identifier_source, :identifier => identifier.identifier
  end

  xml.unittitle fond.name, {:localtype => "denominazione"}
  fond.other_names.each do |on|
	xml.unittitle on.name, {:localtype => "altreDenominazioni"}
  end
  
  xml.physdescstructured :physdescstructuredtype => "spaceoccupied", :coverage => "whole" do
	xml.quantity fond.length.blank? ? "" : fond.length
	xml.unittype fond.length.blank? ? "" : "ml"
	if !fond.extent.blank?
	  xml.descriptivenote do
		xml.p fond.extent 
	  end
	end
  end

  fond_custodians = fond.custodians
  if fond_custodians.count > 0
	xml.repository do
	  fond_custodians.each do |custodian|
		id = custodian.custodian_identifiers.first
		if id.nil?
		  sc_id_str = sprintf '%08d', custodian.id
		  xml.corpname :id => "SC-#{sc_id_str}" do 
			xml.part custodian.preferred_name.name
		  end
		else
		  xml.corpname :identifier => id.identifier do 
			xml.part custodian.preferred_name.name
		  end
		end
		building = custodian.custodian_buildings.first
		if !building.address.blank?
		  xml.address do
			xml.addressline building.address + ", " +  building.postcode + ", " +  building.city
		  end
		end
	  end
	end
  end

  fond_creators = fond.creators
  if fond_creators.count > 0
	xml.origination do
	  fond_creators.each do |creator|
		id = creator.creator_identifiers.first
		sp_id_str = sprintf '%08d', creator.id
		case creator.creator_type
		when 'C'
		  if id.nil?
			xml.corpname :identifier => "SP-#{sp_id_str}" do
			  xml.part creator.preferred_name.name
			end
		  else
			xml.corpname :identifier => id.identifier do
			  xml.part creator.preferred_name.name
			end
		  end
		when 'P'
		  if id.nil?
			xml.persname :identifier => "SP-#{sp_id_str}" do
			  xml.part creator.preferred_name.name
			end
		  else
			xml.persname :identifier => id.identifier do
			  xml.part creator.preferred_name.name
			end
		  end            
		when 'F'
		  if id.nil?
			xml.famname :identifier => "SP-#{sp_id_str}" do
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
  end

  if fond.preferred_event.present? && fond.preferred_event.valid?
	xml.unitdatestructured do
	  xml.dateset do
		if fond.preferred_event.start_date_from == fond.preferred_event.end_date_from && fond.preferred_event.start_date_to == fond.preferred_event.end_date_to            
		  #datesingle
		  if fond.preferred_event.start_date_from == fond.preferred_event.start_date_to
			xml.datesingle fond.preferred_event.start_date_display, { :standarddate => fond.preferred_event.start_date_from }.reject{ |k,v| v.nil? }
		  else 
			xml.datesingle fond.preferred_event.start_date_display, { :notbefore => fond.preferred_event.start_date_from, :notafter => fond.preferred_event.start_date_to }.reject{ |k,v| v.nil? }
		  end
		else
		  #daterange
		  xml.daterange do
			xml.fromdate fond.preferred_event.start_date_display, { :standarddate => fond.preferred_event.start_date_from }.reject{ |k,v| v.nil? }
			xml.todate fond.preferred_event.end_date_display, { :standarddate => fond.preferred_event.end_date_to }.reject{ |k,v| v.nil? }
		  end
		end

		xml.datesingle fond.preferred_event.note, {:localtype => "noteAllaData"}
	  end
	end      
  end    
end

if fond.history.present?
  xml.custodhist do
	xml.p fond.history
  end
end
if fond.description.present?
  xml.scopecontent do
	xml.p fond.description
  end
end
if fond.access_condition.present?
  xml.accessrestrict do
	xml.p fond.access_condition_note
  end
end

xml.processinfo do
  xml.p "Pubblicata"    
end

fond_editors = fond.fond_editors
if (fond_editors.present?)
  fond_editors_event_type = {"aggiornamento scheda" => "updated", "inserimento dati" => "created",
	"integrazione successiva" => "updated", "prima redazione" => "created",
	"revisione" => "revised", "rielaborazione" => "revised", "schedatura" => "created"}
  xml.processinfo :localtype => "compilatori" do
	fond_editors.each do |fe|
	  xml.processinfo :localtype => "compilatore" do
		xml.p do
		  xml.persname do
			xml.part fe.name, {:localtype => "compilatore"}
			xml.part fe.qualifier, {:localtype => "qualifica"}
			xml.part fond_editors_event_type[fe.editing_type], {:localtype => "tipoIntervento"}
		  end
		  xml.date fe.edited_at, {:localtype => "dataIntervento"}
		end
	  end
	end
  end
end

fond_document_forms = fond.document_forms
if (fond_document_forms.present?)
  xml.controlaccess do
	fond_document_forms.each do |fdf|        
	  xml.genreform do
		xml.part fdf.name, { :localtype => "denominazione" }
		xml.part fdf.description, { :localtype => "descrizione" }
		xml.part fdf.note, { :localtype => "note" }
	  end        
	end
  end
end

if fond == fond.root
  xml.dsc do
    xml << render(:partial => "fond_desc_child_ii.xml", :locals => {
      :fond_types => fond_types,
      :fond => fond
    })
  end
else
  xml << render(:partial => "fond_desc_child_ii.xml", :locals => {
    :fond_types => fond_types,
    :fond => fond
  })
end