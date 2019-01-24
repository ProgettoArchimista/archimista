xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"

xml.ead :"xsi:schemaLocation" => "http://ead3.archivists.org/schema/ http://www.san.beniculturali.it/tracciato/ead3.xsd",
  :"xmlns"              => "http://ead3.archivists.org/schema/",
  :"xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",  
  :"xmlns:xlink"        => "http://www.w3.org/1999/xlink" do

  records.each do |fond|
    xml << render(:partial => "fond_ead.xml", :locals => {:fond => fond})
  end

end