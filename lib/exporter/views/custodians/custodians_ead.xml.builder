if (defined?(is_icar_import)).nil? or is_icar_import != true
  xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
end
records.each do |custodian|
  xml << render(:partial => "custodian_ead.xml", :locals => {:custodian => custodian})
end