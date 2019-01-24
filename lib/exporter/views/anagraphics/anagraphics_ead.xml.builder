if (defined?(is_icar_import)).nil? or is_icar_import != true
  xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
end
xml.tag! "eac-cpf", {
  :"xsi:schemaLocation" => "urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd",
  :"xmlns"              => "urn:isbn:1-931666-33-4",
  :"xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
  :"xmlns:xs"           => "http://www.w3.org/2001/XMLSchema",
  :"xmlns:xlink"        => "http://www.w3.org/1999/xlink"
} do
  records.each do |anagraphic|
    xml << render(:partial => "anagraphic_ead.xml", :locals => {:anagraphic => anagraphic})
  end
end