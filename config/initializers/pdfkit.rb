PDFKit.configure do |config|
# Upgrade 2.0.0 inizio
#  config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
  osCurrent = ENV["OS"]
  if osCurrent.nil?
    osCurrent = ""
  end
  if osCurrent.downcase.start_with?("windows")
    if Rails.env.development?
      config.wkhtmltopdf = 'S:/PortableApps/wkhtmltopdf/wkhtmltopdf.exe'
    else
      config.wkhtmltopdf = File.expand_path("../../wkhtmltopdf/wkhtmltopdf.exe", File.dirname(__FILE__))
    end
  else
    config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
  end
# Upgrade 2.0.0 fine
  config.default_options = {
    :print_media_type => true,
    :page_size => 'A4',
    :disable_smart_shrinking => true,
    :encoding => "UTF-8"
  }
end
