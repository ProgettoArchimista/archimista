xml.did do
  rf_id_str = sprintf '%08d', root_fond.id
  xml.unitid "CA-#{rf_id_str}", :identifier => "CA-#{rf_id_str}"
  xml.unittitle root_fond.name, :localtype => "denominazione"
end

xml.dsc do
  base_types = {
    "fascicolo o altra unità complessa" => "file",
    "unità documentaria" => "item",
    "registro o altra unità rilegata" => "registro"
  }
  file_types = {
    "fascicolo di edilizia" => "fascicolodiedilizia",
    "fascicolo personale" => "fascicolopersonale"
  }
  sc2_tsks = {
    "CARS" => "cartografiastorica",
    "D" => "”disegnoartistico",
    "DT" => "disegnotecnico",
    "F" => "fotografia",
    "S" => "stampa"
  }
  unit_types = {
    "base_types" => base_types,
    "file_types" => file_types,
    "sc2_tsks" => sc2_tsks
  }
  sequence_numbers = Unit.display_sequence_numbers_of(Fond.find(unit.root_fond_id).root)
  
  if unit.root_fond_id == unit.fond_id
    if unit.ancestry.nil?
      xml << render(:partial => "unit_desc_ead.xml", :locals => {
        :unit => unit,
	    :unit_types => unit_types,
	    :sequence_numbers => sequence_numbers
      })
    elsif
      parent_unit_ids = unit.ancestry.split("/")
      xml << render(:partial => "unit_parent_ead.xml", :locals => {
        :parent_unit_ids => parent_unit_ids,
	    :unit => unit,
	    :unit_types => unit_types,
	    :sequence_numbers => sequence_numbers
      })
    end
  else
    fonds = Array.new
    id = unit.fond_id
    while !id.to_s.empty?
      fond = Fond.find(id)
      fonds.push(fond)
      id = fond.ancestry
	  
      if "#{fond.ancestry}" == "#{root_fond.id}"
        break
      end
    end
    
    xml << render(:partial => "unit_fond_ead.xml", :locals => {
      :fonds => fonds,
	  :fond_types => fond_types,
      :unit => unit,
	  :unit_types => unit_types,
	  :sequence_numbers => sequence_numbers
    })
  end
end