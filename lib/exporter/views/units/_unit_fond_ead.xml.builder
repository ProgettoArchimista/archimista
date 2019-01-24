fond = fonds[0]
fond_type = fond_types.key?(fond.fond_type) ? fond_types[fond.fond_type] : "fonds"
ca_id_str = sprintf '%08d', fond.id

fonds.shift()

if fond_type == "otherlevel"
  xml.c :level => fond_type, :otherlevel => fond.fond_type do
    xml.did do
      xml.unitid "CA-#{ca_id_str}", :identifier => "CA-#{ca_id_str}"
      xml.unittitle fond.name, :localtype => "denominazione"
    end

    if fonds.empty?
      if unit.ancestry.nil?
        xml << render(:partial => "unit_desc_ead.xml", :locals => {
          :unit => unit,
	      :unit_types => unit_types,
	      :sequence_numbers => sequence_numbers
        })
      else
        parent_unit_ids = unit.ancestry.split("/")
        xml << render(:partial => "unit_parent_ead.xml", :locals => {
          :parent_unit_ids => parent_unit_ids,
	      :unit => unit,
	      :unit_types => unit_types,
	      :sequence_numbers => sequence_numbers
        })
      end
    else
      xml << render(:partial => "unit_fond_ead.xml", :locals => {
        :fonds => fonds,
	    :fond_types => fond_types,
        :unit => unit,
	    :unit_types => unit_types,
	    :sequence_numbers => sequence_numbers
      })
    end
  end
else
  xml.c :level => fond_type do
    xml.did do
      xml.unitid "CA-#{ca_id_str}", :identifier => "CA-#{ca_id_str}"
      xml.unittitle fond.name, :localtype => "denominazione"
    end

    if fonds.empty?
      if unit.ancestry.nil?
        xml << render(:partial => "unit_desc_ead.xml", :locals => {
          :unit => unit,
	      :unit_types => unit_types,
	      :sequence_numbers => sequence_numbers
        })
      else
        parent_unit_ids = unit.ancestry.split("/")
        xml << render(:partial => "unit_parent_ead.xml", :locals => {
          :parent_unit_ids => parent_unit_ids,
	      :unit => unit,
	      :unit_types => unit_types,
	      :sequence_numbers => sequence_numbers
        })
      end
    else
      xml << render(:partial => "unit_fond_ead.xml", :locals => {
        :fonds => fonds,
	    :fond_types => fond_types,
        :unit => unit,
	    :unit_types => unit_types,
	    :sequence_numbers => sequence_numbers
      })
    end
  end
end