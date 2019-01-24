unit_type = unit_types["base_types"].key?(unit.unit_type) ? unit_types["base_types"][unit.unit_type] : ""
if unit_type == "registro"
  file_type = unit_type
else
  file_type = unit_types["file_types"].key?(unit.file_type) ? unit_types["file_types"][unit.file_type] : nil
end
sc2_tsk = unit_types["sc2_tsks"].key?(unit.sc2_tsk) ? unit_types["sc2_tsks"][unit.sc2_tsk] : nil

if file_type.nil? and sc2_tsk.nil?
  attributes = {:level => unit_type}
else
  if !file_type.nil?
    otherlevel = file_type
  else
    otherlevel = sc2_tsk
  end
  attributes = {:level => "otherlevel", :otherlevel => otherlevel}
end
xml.c attributes do
  xml << render(:partial => "unit_desc_inside_ead.xml", :locals => {
    :unit => unit,
    :unit_types => unit_types,
    :sequence_numbers => sequence_numbers
  })
end