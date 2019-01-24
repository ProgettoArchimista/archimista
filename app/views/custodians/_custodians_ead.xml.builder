xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
records.each do |custodian|
  xml << render(:partial => "custodian_ead.xml", :locals => {:custodian => custodian})
end


