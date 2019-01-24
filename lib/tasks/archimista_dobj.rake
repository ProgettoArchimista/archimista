ARCHIMISTA_TASKS_PATH = "#{Rails.root}/lib/tasks/"
ARCHIMISTA_DIGITAL_PATH = "#{Rails.root}/public/digital_objects/"

namespace :dobj do
  desc "Procedura di caricamento multiplo di oggetti digitali su entità archivistica"
  task :upload => :environment do |t|
  	puts "Avvio procedura di caricamento multiplo di oggetti digitali su entità archivistica"
  	dobj_path = ARCHIMISTA_TASKS_PATH + "dobj.json"
  	if File.exist?(dobj_path)
  		dobj_objects = JSON.parse(File.read(dobj_path))
  		dobj_objects.each do |dobj|
  			if dobj["type"].nil? || dobj["type"].empty?
  			puts "Inserire una tipologia \"type\" alla quale associare l'oggetto digitale tra le seguenti: Fond, Unit, Creator, Custodian, Source"
  		else
  			if ['Fond', 'Unit', 'Creator', 'Custodian', 'Source'].include? dobj["type"]
				if dobj["id"].empty? || dobj["img_dir"].empty? || dobj["user_id"].empty? || dobj["group_id"].empty?
					puts "Manca qualche variabile o hai inserito valori non accettati"
				else
					position = DigitalObject.where(attachable_id: dobj["id"], attachable_type: dobj["type"]).maximum(:position)
					if position.nil?
						position = 0
					end
					puts "Gli oggetti digitali verranno caricati su entità di tipologia #{dobj["type"]} con id #{dobj["id"]}"
					file_names = dobj["file_names"]

					file_names.each do |file|
						complete_name_file = dobj["img_dir"] + file
						puts "Caricamento del file: #{complete_name_file}"
						position = position + 1
						title = File.basename(complete_name_file, ".*" )
						afn = File.basename(complete_name_file)
						size = File.size(complete_name_file)
						access_token = Digest::SHA1.hexdigest("#{afn}#{(Time.now.to_f * 1000).to_i}")
						new_dir = ARCHIMISTA_DIGITAL_PATH + access_token
						Dir.mkdir(new_dir, 0755)

						if File.extname(complete_name_file).include? ".pdf"
							FileUtils.cp(complete_name_file, File.join(new_dir, "original.pdf"))	
							act = "application/pdf"
						else
							act = "image/jpeg"
							ext = File.extname(complete_name_file)
							FileUtils.cp(complete_name_file, File.join(new_dir, "original" + ext))
					
							`convert "#{complete_name_file}" -resize 1280x1280 "#{new_dir}"/large#{ext}` 
							`convert "#{complete_name_file}" -resize 210x210 "#{new_dir}"/medium#{ext}` 
							`convert "#{complete_name_file}" -resize 130x130 "#{new_dir}"/thumb#{ext}`
						end
						
						updated_time = Time.now.strftime('%Y-%m-%d %H:%M:%S')

						sql = "INSERT INTO digital_objects (attachable_type, attachable_id, position, title, description, access_token, asset_file_name, asset_content_type, asset_file_size, asset_updated_at, created_by, updated_by, group_id, created_at, updated_at) VALUES ('#{dobj["type"]}', #{dobj["id"]}, '#{position}', '#{title}', '#{title}', '#{access_token}', '#{afn}', '#{act}', #{size}, '#{updated_time}', #{dobj["user_id"]}, #{dobj["user_id"]}, #{dobj["group_id"]}, '#{updated_time}', '#{updated_time}')"
  						ActiveRecord::Base.connection.execute(sql) 
					end

					
					puts "La procedura è stata completata, tutti i file digitali sono stati associati all'entità prescelta"
				end
  			else
  				puts "La tipologia " + dobj["type"] + " non è tra quelle selezionabili: fond, unit, creator, custodian, source"
  			end
  			end
  		end

  		
  	else
  		puts "Il file di configurazione " + dobj_path + " non esiste"
  	end
  end
end