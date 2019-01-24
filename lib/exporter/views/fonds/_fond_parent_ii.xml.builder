if parents_id.empty?
  fond_type = fond_types.key?(fond.fond_type) ? fond_types[fond.fond_type] : "fonds"
  if fond_type == "otherlevel"
    attributes = {:level => fond_type, :otherlevel => fond.fond_type}
  else
    attributes = {:level => fond_type}
  end
  xml.c attributes do
    xml << render(:partial => "fond_desc_ii.xml", :locals => {
      :fond_types => fond_types,
      :fond => fond
    })
  end
else
  parent_id = parents_id.first
  if parent_id == fond.root.id.to_s
    parents_id.shift()
    
    xml << render(:partial => "fond_parent_ii.xml", :locals => {
      :parents_id => parents_id,
      :fond_types => fond_types,
      :fond => fond
    })
  else
    parent_fond = Fond.find(parent_id)
    parents_id.shift()

    fond_type = fond_types.key?(parent_fond.fond_type) ? fond_types[parent_fond.fond_type] : "fonds"
    if fond_type == "otherlevel"
      attributes = {:level => fond_type, :otherlevel => parent_fond.fond_type}
    else
      attributes = {:level => fond_type}
    end
    xml.c attributes do
      xml.did do
        pfa_id_str = sprintf '%08d', parent_fond.id
        xml.unitid "CA-#{pfa_id_str}", :identifier => "CA-#{pfa_id_str}"
        xml.unittitle parent_fond.name, :localtype => "denominazione"
      end

      xml << render(:partial => "fond_parent_ii.xml", :locals => {
        :parents_id => parents_id,
        :fond_types => fond_types,
        :fond => fond
      })
    end
  end
end