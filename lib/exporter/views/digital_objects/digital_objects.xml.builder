xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.tag! "envelope:envelope", {
  :"xmlns:ead"          => "http://san.mibac.it/ead-san-objdig/",
  :"xmlns:ead-context"  => "http://san.mibac.it/ead-san-objdig/context",
  :"xmlns:ead-noarch"   => "http://san.mibac.it/ead-san-objdig-noarch/",
  :"xmlns:envelope"     => "http://san.beniculturali.it/envelope-san/",
  :"xmlns:mets"         => "http://san.mibac.it/mets-san/",
  :"xmlns:metsrights"   => "http://san.mibac.it/metsrights-lite/",
  :"xmlns:mix"          => "http://san.mibac.it/mix-lite/",
  :"xmlns:rdf"          => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
  :"xmlns:san-dl"       => "http://mibac.it/san/dl#",
  :"xmlns:xlink"        => "http://www.w3.org/1999/xlink",
  :"xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
  :"xsi:schemaLocation" => "http://san.beniculturali.it/envelope-san/ http://san.beniculturali.it/tracciato/envelope-san.xsd"
} do

  xml.tag! "envelope:header", :CREATED => Time.now.strftime("%Y-%m-%dT%H:%M:%S") do
    xml.tag! "envelope:source", metadata['PROVIDER_DL']
  end

  xml.tag! "envelope:recordList" do
    records.each do |unit|
      xml << render(:partial => "digital_object.xml", :locals => {:unit => unit, :metadata => metadata})
    end
  end

end