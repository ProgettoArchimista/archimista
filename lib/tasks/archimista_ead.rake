require File.join(File.dirname(__FILE__), "..", "exporter/Configurazione_dl.rb")
require 'zip'
require 'builder'

TMP_RAKE_EAD_EXPORTS = "#{Rails.root}/tmp/exports"

namespace :ead do

  def views_path(record)
    File.join(File.dirname(__FILE__), "..", "exporter/views", record)
  end

  def set_fonds
    @fonds = Fond.roots.order(:name)
  end

  def selected_fond_ids
    set_fonds
    fond_ids = @fonds.map(&:id)
  end
  
  def stream_ead(records, ids = [], zip_file_name)
    if records.present?
      begin
        file = "#{records.class.name.tableize}_ead.xml"
        view = ActionView::Base.new(views_path(records.class.name.tableize))
        if records.class.name.tableize == 'creators'
          data_file_name = TMP_RAKE_EAD_EXPORTS + "/sp-#{records.id}.xml"
          file_name = "sp-#{records.id}.xml"
        elsif records.class.name.tableize == 'institutions'
          data_file_name = TMP_RAKE_EAD_EXPORTS + "/pi-#{records.id}.xml"
          file_name = "pi-#{records.id}.xml"
        elsif records.class.name.tableize == 'fonds'
          data_file_name = TMP_RAKE_EAD_EXPORTS + "/ca-#{records.id}.xml"
          file_name = "ca-#{records.id}.xml"
        elsif records.class.name.tableize == 'custodians'
          data_file_name = TMP_RAKE_EAD_EXPORTS + "/sc-#{records.id}.xml"
          file_name = "sc-#{records.id}.xml"
        elsif records.class.name.tableize == 'anagraphics'
          data_file_name = TMP_RAKE_EAD_EXPORTS + "/sa-#{records.id}.xml"
          file_name = "sa-#{records.id}.xml"
        else
          data_file_name = TMP_RAKE_EAD_EXPORTS + "/data-#{records.class.name.tableize}-#{records.id}.xml"
          file_name = "data-#{records.class.name.tableize}-#{records.id}.xml"
        end

        file_dest = File.new(data_file_name, 'w+')
        xml = ::Builder::XmlMarkup.new(target: file_dest, :indent => 2)
        xml =  view.render(:file => "#{file}.builder", :locals => {:records => [records], :fond_ids => ids})
        File.open(file_dest, 'w+') { |f| f.write(xml) }
        file_dest_path = file_dest.path

        Zip::File.open(zip_file_name, Zip::File::CREATE) do |zipfile|
          zipfile.add(file_name, file_dest_path)
        end

        File.delete(TMP_RAKE_EAD_EXPORTS + "/" + file_name) if File.exist?(TMP_RAKE_EAD_EXPORTS + "/" + file_name)
      rescue Exception => e
        puts "Eccezione record #{records.id}: #{e}"
      end 
    else
      puts "Record non specificato"
    end
  end
  
  def build_icar_import(fond)
    zip_file_name = TMP_RAKE_EAD_EXPORTS + "/icar-import.zip"
    File.delete(zip_file_name) if File.exist?(zip_file_name)
    
    file_name = "icar-import-#{fond.id}.xml"
    data_file_name = TMP_RAKE_EAD_EXPORTS + "/" + file_name
	file_dest = File.new(data_file_name, 'w+')
    view = ActionView::Base.new(views_path("icar-import"))
    xml = ::Builder::XmlMarkup.new(target: file_dest, :indent => 2)
    digital_objects = Array.new
    xml =  view.render(:file => "icar-import.xml.builder", :locals => {:fond => fond})
    
    xml_formatted = ''
    require "rexml/document"
    doc = REXML::Document.new(xml.to_s)
    formatter = REXML::Formatters::Pretty.new
    formatter.compact = true
    formatter.write(doc, xml_formatted)
    
    File.open(file_dest, 'w+') { |f| f.write(xml_formatted) }
    Zip::File.open(zip_file_name, Zip::File::CREATE) do |zipfile|
      zipfile.add(file_name, file_dest.path)
    end
    File.delete(TMP_RAKE_EAD_EXPORTS + "/" + file_name) if File.exist?(TMP_RAKE_EAD_EXPORTS + "/" + file_name)
    
    #oggetti digitali
    fonds_id = Array.new
    fonds_id.push(fond.id)
    if fond.ancestry.nil?
      query = "ancestry LIKE '#{fond.id}/%' OR ancestry = '#{fond.id}'"
    else
      query = "ancestry LIKE '#{fond.ancestry}/%' OR ancestry = '#{fond.ancestry}'"
    end
    children_ids = Fond.where(query).pluck(:id)
    fonds_id = fonds_id + children_ids
    unit_ids = Unit.where(fond_id: fonds_id).pluck(:id)
    digital_objects = DigitalObject.where(attachable_id: unit_ids)
    if !digital_objects.empty?
      Zip::File.open(zip_file_name, false) do |zipfile|
        digital_objects.each do |digital_object|
          dob_id_str = sprintf '%08d', digital_object.id
          file_path = "#{Rails.root}/public/digital_objects/#{digital_object.access_token}/original."
          if digital_object.asset_content_type == "application/pdf"
            file_path.concat("pdf")
          else
            file_path.concat("jpg")
          end
          if File.file?(file_path)
            zipfile.add("OD-#{dob_id_str}/#{digital_object.asset_file_name}", file_path)
          end
        end
      end
    end
  end

  desc "Genera metadati EAD relativi a: [fonds | creators | institutions | custodians | sources | units | anagraphics | icar-import]"
  task :build_xml, [:records, :query] => :environment do |t, args|
    case args[:records]
    when "fonds"
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          @fonds = Fond.find_by_sql(query)
		  if @fonds.count > 0
            puts "Creazione file EAD contenente #{@fonds.count} complessi archivistici ..."
            zip_file_name = TMP_RAKE_EAD_EXPORTS + "/fonds.zip"
			puts "... Attendere, creazione file in corso ..."
            File.delete(zip_file_name) if File.exist?(zip_file_name)
            @fonds.each do |f|
              stream_ead(f, [], zip_file_name)            
            end
            part_zips_count = Zip::File.split(zip_file_name, 1_152, false) 
            puts "File creato: #{zip_file_name}"
			
            Dir.glob("#{zip_file_name}.*").each { |file| File.delete(file)}
		  else
		    puts "Nessun complesso archivistico trovato."
		  end
        rescue Exception => e
          puts "Eccezione #{e}"
        end
      end
    when "creators"
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          @creators = Creator.find_by_sql(query)
		  if @creators.count > 0
            puts "Creazione file EAC-CPF contenente #{@creators.count} soggetti produttori ..."
            zip_file_name = TMP_RAKE_EAD_EXPORTS + "/creators.zip"
			puts "... Attendere, creazione file in corso ..."
            File.delete(zip_file_name) if File.exist?(zip_file_name)
            @creators.each do |c|
              stream_ead(c, selected_fond_ids, zip_file_name)            
            end
            part_zips_count = Zip::File.split(zip_file_name, 1_152, false) 
            puts "File creato: #{zip_file_name}"
			
            Dir.glob("#{zip_file_name}.*").each { |file| File.delete(file)}
		  else
		    puts "Nessun soggetto produttore trovato."
		  end
        rescue Exception => e
          puts "Eccezione #{e}"
        end 
      end
    when "institutions"
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          @institutions = Institution.find_by_sql(query)
		  if @institutions.count > 0
            puts "Creazione file EAC-CPF contenente #{@institutions.count} profili istituzionali ..."
            zip_file_name = TMP_RAKE_EAD_EXPORTS + "/institutions.zip"
			puts "... Attendere, creazione file in corso ..."
            File.delete(zip_file_name) if File.exist?(zip_file_name)
            @institutions.each do |c|
              stream_ead(c, [], zip_file_name)
            end
            part_zips_count = Zip::File.split(zip_file_name, 1_152, false) 
            puts "File creato: #{zip_file_name}"
			
            Dir.glob("#{zip_file_name}.*").each { |file| File.delete(file)}
		  else
		    puts "Nessun profilo istituzionale trovato."
		  end
        rescue Exception => e
          puts "Eccezione #{e}"
        end 
      end
    when "custodians"
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          @custodians = Custodian.find_by_sql(query)
		  if @custodians.count > 0
            puts "Creazione file SCONS contenente #{@custodians.count} soggetti conservatori ..."
            zip_file_name = TMP_RAKE_EAD_EXPORTS + "/custodians.zip"
			puts "... Attendere, creazione file in corso ..."
            File.delete(zip_file_name) if File.exist?(zip_file_name)
            @custodians.each do |c|
              stream_ead(c, [], zip_file_name)            
            end
            part_zips_count = Zip::File.split(zip_file_name, 1_152, false) 
            puts "File creato: #{zip_file_name}"
			
            Dir.glob("#{zip_file_name}.*").each { |file| File.delete(file)}
		  else
		    puts "Nessun soggetto conservatore trovato."
		  end
        rescue Exception => e
          puts "Eccezione #{e}"
        end
      end
    when "sources"
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          @sources = Source.find_by_sql(query)
		  if @sources.count > 0
            puts "Creazione file EAD contenente #{@sources.count} fonti / strumenti di ricerca ..."
            zip_file_name = TMP_RAKE_EAD_EXPORTS + "/sources.zip"
			puts "... Attendere, creazione file in corso ..."
            File.delete(zip_file_name) if File.exist?(zip_file_name)
            @sources.each do |s|
              stream_ead(s, [], zip_file_name)            
            end
            part_zips_count = Zip::File.split(zip_file_name, 1_152, false) 
            puts "File creato: #{zip_file_name}"
			
            Dir.glob("#{zip_file_name}.*").each { |file| File.delete(file)}
		  else
		    puts "Nessuna fonte/strumento di ricerca trovato."
		  end
        rescue Exception => e
          puts "Eccezione #{e}"
        end
      end
    when "units"
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          @units = Unit.find_by_sql(query)
		  if @units.count > 0
            puts "Creazione file EAD contenente #{@units.count} unità archivistiche ..."
            zip_file_name = TMP_RAKE_EAD_EXPORTS + "/units.zip"
			puts "... Attendere, creazione file in corso ..."
            File.delete(zip_file_name) if File.exist?(zip_file_name)
            @units.each do |s|
              stream_ead(s, [], zip_file_name)
            end
            part_zips_count = Zip::File.split(zip_file_name, 1_152, false)
            puts "File creato: #{zip_file_name}"
			
            Dir.glob("#{zip_file_name}.*").each { |file| File.delete(file)}
		  else
		    puts "Nessuna unità archivistica trovata."
		  end
        rescue Exception => e
          puts "Eccezione #{e}"
        end
      end
    when "anagraphics"
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          @anagraphics = RelUnitAnagraphic.find_by_sql(query)
		  if @anagraphics.count > 0
            rua_list = Array.new
            @anagraphics.each do |rel_unit_anagraphic|
              if !rua_list.include?(rel_unit_anagraphic.anagraphic_id)
                rua_list.push rel_unit_anagraphic.anagraphic_id
              end
            end
            puts "Creazione file EAC-CPF contenente #{rua_list.count} schede anagrafiche ..."
            zip_file_name = TMP_RAKE_EAD_EXPORTS + "/anagraphics.zip"
            puts "... Attendere, creazione file in corso ..."
            File.delete(zip_file_name) if File.exist?(zip_file_name)
            rua_list.each do |anagraphic_id|
              s = Anagraphic.find(anagraphic_id)
              stream_ead(s, [], zip_file_name)
            end
            part_zips_count = Zip::File.split(zip_file_name, 1_152, false)
            puts "File creato: #{zip_file_name}"
			
            Dir.glob("#{zip_file_name}.*").each { |file| File.delete(file)}
		  else
		    puts "Nessuna scheda anagrafica trovata."
		  end
        rescue Exception => e
          puts "Eccezione #{e}"
        end
      end
    when "icar-import"
      fond_id = args[:query]
      if fond_id.blank?
        puts "Id complesso archivistico non inserito. Ripetere la procedura."
      else
        begin
          @fond = Fond.find(fond_id)
          puts "Creazione file ICAR-IMPORT ..."
          build_icar_import(@fond)
        rescue Exception => e
          puts "Eccezione #{e}"
        end
      end
    else
      puts "Argomento non valido.\nScegli tra [fonds | creators | institutions | custodians | sources | units | anagraphics | icar-import]"
    end
  end
end