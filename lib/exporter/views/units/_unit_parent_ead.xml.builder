parent_unit = Unit.find(parent_unit_ids[0])

parent_unit_ids.shift()

parent_unit_type = unit_types["base_types"].key?(parent_unit.unit_type) ? unit_types["base_types"][parent_unit.unit_type] : ""
if parent_unit_type == "registro"
  parent_file_type = parent_unit_type
else
  parent_file_type = unit_types["file_types"].key?(parent_unit.file_type) ? unit_types["file_types"][parent_unit.file_type] : nil
end
parent_sc2_tsk = unit_types["sc2_tsks"].key?(parent_unit.sc2_tsk) ? unit_types["sc2_tsks"][parent_unit.sc2_tsk] : nil

if parent_file_type.nil? and parent_sc2_tsk.nil?
  xml.c :level => parent_unit_type do
    xml.did do
      pua_id_str = sprintf '%08d', parent_unit.id
      xml.unitid "CA-#{pua_id_str}", :identifier => "CA-#{pua_id_str}"
      xml.unittitle parent_unit.name, :localtype => "denominazione"
    end
  
    if parent_unit_ids.empty?
      xml << render(:partial => "unit_desc_ead.xml", :locals => {
        :unit => unit,
	    :unit_types => unit_types,
	    :sequence_numbers => sequence_numbers
      })
    else
      xml << render(:partial => "unit_parent_ead.xml", :locals => {
        :parent_unit_ids => parent_unit_ids,
	    :unit_types => unit_types,
	    :sequence_numbers => sequence_numbers,
	    :unit => unit
      })
    end
  end
else
  if !parent_file_type.nil?
    otherlevel = parent_file_type
  else
    otherlevel = parent_sc2_tsk
  end
  xml.c :level => "otherlevel", :otherlevel => otherlevel do
    xml.did do
      pua_id_str = sprintf '%08d', parent_unit.id
      xml.unitid "CA-#{pua_id_str}", :identifier => "CA-#{pua_id_str}"
      xml.unittitle parent_unit.name, :localtype => "denominazione"
    end
  
    if parent_unit_ids.empty?
      xml << render(:partial => "unit_desc_ead.xml", :locals => {
        :unit => unit,
	    :unit_types => unit_types,
	    :sequence_numbers => sequence_numbers
      })
    else
      xml << render(:partial => "unit_parent_ead.xml", :locals => {
        :parent_unit_ids => parent_unit_ids,
	    :unit_types => unit_types,
	    :sequence_numbers => sequence_numbers,
	    :unit => unit
      })
    end
  end
end