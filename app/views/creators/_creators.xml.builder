xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.tag! "cat-import", {
  :"xmlns"              => "http://san.mibac.it/cat-import",
  :"xmlns:eac-cpf"      => "http://san.mibac.it/eac-san/",
  :"xmlns:ead-complarc" => "http://san.mibac.it/ead-san/",
  :"xmlns:ead-str"      => "http://san.mibac.it/ricerca-san/",
  :"xmlns:scons"        => "http://san.mibac.it/scons-san/",
  :"xmlns:xlink"        => "http://www.w3.org/1999/xlink",
  :"xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
  :"xsi:schemaLocation" => "http://san.mibac.it/cat-import http://www.san.beniculturali.it/tracciato/cat-import.xsd"
} do

  xml << render(:partial => "catheader.xml")

  xml.catListRecords do
    records.each do |creator|
      xml << render(:partial => "creator.xml", :locals => {:creator => creator, :fond_ids => fond_ids, :metadata => metadata})
    end
  end

end