xml.did do
  cua_id_str = sprintf '%08d', unit.id
  
  xml.unitid "UA-#{cua_id_str}", :identifier => "UA-#{cua_id_str}"
  xml.unittitle unit.name, :localtype => "denominazione"
end

if unit.has_children?
  child_units = unit.children.where("id != #{unit.id}").order(:sequence_number)
  child_units.each do |child_unit|
    child_unit_type = unit_types["base_types"].key?(child_unit.unit_type) ? unit_types["base_types"][child_unit.unit_type] : ""
    if child_unit_type == "registro"
      child_file_type = child_unit_type
    else
      child_file_type = unit_types["file_types"].key?(child_unit.file_type) ? unit_types["file_types"][child_unit.file_type] : nil
    end
    child_sc2_tsk = unit_types["sc2_tsks"].key?(child_unit.sc2_tsk) ? unit_types["sc2_tsks"][child_unit.sc2_tsk] : nil
	
    if child_file_type.nil? and child_sc2_tsk.nil?
      attributes = {:level => child_unit_type}
    else
      if !child_file_type.nil?
        otherlevel = child_file_type
      else
        otherlevel = child_sc2_tsk
      end
      attributes = {:level => "otherlevel", :otherlevel => otherlevel}
    end
    xml.c attributes do
      xml << render(:partial => "unit_child_ead.xml", :locals => {
        :unit => child_unit,
        :unit_types => unit_types
      })
    end
  end
end