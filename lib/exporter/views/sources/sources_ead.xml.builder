if (defined?(is_icar_import)).nil? or is_icar_import != true
  xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
end
xml.tag! "ead", {
  :"xsi:schemaLocation" => "http://ead3.archivists.org/schema/ http://www.san.beniculturali.it/tracciato/ead3.xsd",
  :"xmlns"              => "http://ead3.archivists.org/schema/",
  :"xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
  :"xmlns:xlink"        => "http://www.w3.org/1999/xlink"
} do
  records.each do |source|
    xml << render(:partial => "source_ead.xml", :locals => {:source => source})
  end
end