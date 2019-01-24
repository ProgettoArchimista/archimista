require File.join(File.dirname(__FILE__), "..", "exporter/Configurazione_dl.rb")
require 'zip'
require 'builder'

TMP_RAKE_EXPORTS = "#{Rails.root}/tmp/exports"

namespace :san do

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

  def stream(records, fond_ids = [])
    if records.present?
      file = "#{records[0].class.name.tableize}.xml"
      dl_metadata = {'DL_FOND_ID' => DL_FOND_ID, 'PROVIDER_DL' => PROVIDER_DL, 
                    'DL_HACONSERVATORE' => DL_HACONSERVATORE, 'DL_REPOSITORYID' => DL_REPOSITORYID,
                    'DL_ABBR' => DL_ABBR, 'DL_CORPNAME' => DL_CORPNAME,
                    'DL_HAPROGETTO' => DL_HAPROGETTO, 'DL_HACOMPLESSO' => DL_HACOMPLESSO,
                    'DL_UNITID' => DL_UNITID, 'DL_UNITTITLE' => DL_UNITTITLE
                  }
      view = ActionView::Base.new(views_path(records[0].class.name.tableize))

      data_file_name = TMP_RAKE_EXPORTS + "/" + file

      puts "... Attendere, creazione file in corso ..."

      file_dest = File.new(data_file_name, 'w+')
      xml = ::Builder::XmlMarkup.new(target: file_dest, :indent => 2)

      xml =  view.render(:file => "#{file}.builder", :locals => {:records => records, :fond_ids => fond_ids, :metadata => dl_metadata})
      File.open(file_dest, 'w+') { |f| f.write(xml) }

      zip_file_name = TMP_RAKE_EXPORTS + "/" + "#{records[0].class.name.tableize}.zip"
      file_dest_path = file_dest.path

      File.delete(zip_file_name) if File.exist?(zip_file_name)

      Zip::File.open(zip_file_name, Zip::File::CREATE) do |zipfile|
      	zipfile.add(file, file_dest_path)
      end
      File.delete(data_file_name) if File.exist?(data_file_name)
	  part_zips_count = Zip::File.split(zip_file_name, 1_152, false) 

      puts "File creato: #{zip_file_name}"
    else
      puts "Nessun risultato"
    end
  end

  def stream_mets(records)
    if records.present?
      file = "digital_objects.xml"
      dl_metadata = {'DL_FOND_ID' => DL_FOND_ID, 'PROVIDER_DL' => PROVIDER_DL, 
                    'DL_HACONSERVATORE' => DL_HACONSERVATORE, 'DL_REPOSITORYID' => DL_REPOSITORYID,
                    'DL_ABBR' => DL_ABBR, 'DL_CORPNAME' => DL_CORPNAME,
                    'DL_HAPROGETTO' => DL_HAPROGETTO, 'DL_HACOMPLESSO' => DL_HACOMPLESSO,
                    'DL_UNITID' => DL_UNITID, 'DL_UNITTITLE' => DL_UNITTITLE
                  }

      view = ActionView::Base.new(views_path("digital_objects"))

      data_file_name = TMP_RAKE_EXPORTS + "/" + file

      puts "... Attendere, creazione file in corso ..."

      file_dest = File.new(data_file_name, 'w+')
      xml = ::Builder::XmlMarkup.new(target: file_dest, :indent => 2)

      xml =  view.render(:file => "#{file}.builder", :locals => {:records => records, :metadata => dl_metadata})
      File.open(file_dest, 'w+') { |f| f.write(xml) }
      
      zip_file_name = TMP_RAKE_EXPORTS + "/" + "#{records[0].class.name.tableize}.zip"
      file_dest_path = file_dest.path

      File.delete(zip_file_name) if File.exist?(zip_file_name)

      Zip::File.open(zip_file_name, Zip::File::CREATE) do |zipfile|
      	zipfile.add(file, file_dest_path)
      end

	  part_zips_count = Zip::File.split(zip_file_name, 1_152, false) 

      puts "File creato: #{zip_file_name}"
    else
      puts "Nessun risultato"
    end
  end

  desc "Genera metadati CAT-SAN relativi a: [fonds | creators | custodians | sources]"
  task :build_xml, [:records, :query] => :environment do |t, args|
    case args[:records]
    when "fonds"
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          fondi = Fond.find_by_sql(query)
          fond_ids = []
          fondi.each do |f|
          	fond_ids.push(f.id)
          	fond_children_ids = Fond.where("ancestry in (?) and ancestry_depth = 1", f.id).map(&:id)
          	fond_rel_creator_ids = RelCreatorFond.where("fond_id in (?)", f.id).map(&:creator_id)
          	fond_children_ids.each do |fci|
          		fond_children_rel_creator_ids = RelCreatorFond.where("fond_id in (?)", fci).map(&:creator_id)
          		fond_children_rel_creator_ids.each do |fcrci|
          			if !fond_rel_creator_ids.include? fcrci
          				fond_ids.push(fci)	
          				break
          			end
          		end
          	end
          end
          @fonds = Fond.where("id in (?)", fond_ids)
          puts "Creazione file CAT-SAN contenente #{@fonds.count} complessi archivistici ..."
          stream(@fonds)
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
        	puts "Creazione file CAT-SAN contenente #{@creators.count} complessi archivistici ..."
        	stream(@creators, selected_fond_ids)
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
        	puts "Creazione file CAT-SAN contenente #{@custodians.count} soggetti conservatori ..."
        	stream(@custodians)
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
        	puts "Creazione file CAT-SAN contenente #{@sources.count} fonti / strumenti di ricerca ..."
        	stream(@sources, selected_fond_ids)
        rescue Exception => e
        	puts "Eccezione #{e}"
        end
      end
    else
      puts "Argomento non valido.\nScegli tra [fonds | creators | custodians | sources]"
    end
  end

  desc "Genera metadati METS-SAN relativi a immagini di unità archivistiche, per singolo complesso di livello 1"
  task :build_mets, [:query] => :environment do |t, args|
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          @units = Unit.find_by_sql(query)
          puts "Genero file METS-SAN con #{@units.count} unità ..."
          stream_mets(@units)
        rescue Exception => e
        	puts "Eccezione #{e}"
        end
      end
  end

end