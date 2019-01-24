view = ActionView::Base.new(views_path("units"))
fond.units.where(ancestry: nil).order(:sequence_number).each do |unit|
  xml << view.render(:file => "unit_ii.xml.builder", :locals => {
    :unit => unit,
    :view => view
  })
end

fond.children.each do |children|
  fond_type = fond_types.key?(children.fond_type) ? fond_types[children.fond_type] : "fonds"
  if fond_type == "otherlevel"
    attributes = {:level => fond_type, :otherlevel => children.fond_type}
  else
    attributes = {:level => fond_type}
  end
  xml.c attributes do
    xml << render(:partial => "fond_desc_ii.xml", :locals => {
      :fond_types => fond_types,
      :fond => children
    })
  end
end