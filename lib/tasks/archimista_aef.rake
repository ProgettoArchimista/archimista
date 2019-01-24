require 'zip'
require 'builder'

TMP_AEF_EXPORTS = "#{Rails.root}/tmp/exports"

namespace :aef do

  def get_rake_target_class_caption(target_class)
    case target_class
      when "fond"
        caption = "export_complesso"
      when "custodian"
        caption = "export_conservatore"
      when "project"
        caption = "export_progetto"
      when "unit"
        caption = "export_unita"
      else
        caption = (target_class.nil? || target_class == "") ? "export" : "export_" + target_class
    end
    return caption
  end

  def writeRakeEntries(entries, path, io)
    entries.each { |e|
      zipFilePath = path == "" ? e : File.join(path, e)
      destZipFilePath = "public/digital_objects/" + zipFilePath
      diskFilePath = File.join(@dir_digital, zipFilePath)
      if  File.directory?(diskFilePath)
        io.mkdir(destZipFilePath)
        subdir =Dir.entries(diskFilePath); subdir.delete("."); subdir.delete("..")
        writeRakeEntries(subdir, zipFilePath, io)
      else
        if Dir.exists?(diskFilePath) 
          io.get_output_stream(destZipFilePath) { |f| f.puts(File.open(diskFilePath, "rb").read())}
        elsif File.exists?(diskFilePath)
          io.get_output_stream(destZipFilePath) { |f| f.puts(File.open(diskFilePath, "rb").read())}
        else
          next
        end
      end
    }
  end

  def create_rake_export_file
    create_rake_data_file
    create_rake_metadata_file
    create_rake_aef_file
  end

  def create_rake_metadata_file
    puts "Generazione dei metadati in formato json ..."
    metadata = Hash.new
    metadata.store('version', APP_VERSION.gsub('.', '').to_i)
    metadata.store('checksum', Digest::SHA256.file(@export.data_file).hexdigest)
    metadata.store('date', Time.now)
    metadata.store('producer', RbConfig::CONFIG['host'])
    metadata.store('attached_entity', @export.target_class.capitalize)
    metadata.store('mode', @export.mode)
    File.open(@export.metadata_file, "w+") do |file|
      file.write(metadata.to_json)
    end
  end

  def create_rake_aef_file
    puts "Ultimazione pacchetto dati in formato aef ..."
    files = {"metadata.json" => @export.metadata_file, "data.json" => @export.data_file}
    @dir = TMP_AEF_EXPORTS
    @dir.sub!(%r[/$],'')
    @dir_digital = "#{Rails.root}/public/digital_objects"
    @dir_digital.sub!(%r[/$],'')
    include_digital_objects = @export.inc_digit
    Zip::File.open(@export.dest_file, Zip::File::CREATE) do |zipfile|
      files.each do |dst, src|
        zipfile.add(dst, src)
      end
      if include_digital_objects == 'true'
        fond_access_tokens = DigitalObject.select("access_token").where(:attachable_id => @export.fond_ids, :attachable_type => "Fond").map(&:access_token)
        unit_access_tokens = DigitalObject.select("access_token").where(:attachable_id => @export.unit_ids, :attachable_type => "Unit").map(&:access_token)
        entries = fond_access_tokens + unit_access_tokens
        writeRakeEntries(entries, "", zipfile )
      end
    end
    files.each do |dst, src|
      File.delete(src) if File.exist?(src)
    end
    puts "File creato: #{@export.dest_file}"
  end

  def create_rake_data_file
    puts "Generazione dei dati in formato json ..."
    @export.fond_ids = Array.new
    ActiveRecord::Base.include_root_in_json = true
    case @export.target_class
      when 'fond'
        @export.fond_ids = Fond.subtree_of(@export.target_id).select(:id).order("sequence_number")
      when 'custodian'
        custodian = Custodian.select(:id).find(@export.target_id)
        fonds = custodian.fonds.select(:fond_id)
        fonds.each do |f|
          tmp = Fond.subtree_of(f.fond_id).select(:id).order("sequence_number")
          @export.fond_ids += tmp
        end
      when 'project'
        project = Project.select(:id).find(@export.target_id)
        fonds = project.fonds.select(:fond_id)
        fonds.each do |f|
          tmp = Fond.subtree_of(f.fond_id).select(:id).order("sequence_number")
          @export.fond_ids += tmp
        end
      end
      rake_fonds_and_units 
      rake_major_entities
      rake_headings
      rake_document_forms
      rake_institutions
      rake_sources
      rake_digital_objects
  end

  def rake_fonds_and_units
    @export.unit_ids = Array.new
    @export.fond_ids = @export.fond_ids.map(&:id).join(',')
    fonds = Fond.where("id IN (#{@export.fond_ids})").includes([:units]).order("sequence_number")

    File.open(@export.data_file, "a") do |file|
      fonds.each do |fond|
        fond.legacy_id = fond.id
        if fond.is_root?
          fond.legacy_parent_id = nil
        else
        fond.legacy_parent_id = fond.parent_id.to_s
        end
        file.write(fond.to_json(:except => [:id, :ancestry, :group_id, :db_source, :created_by, :updated_by, :created_at, :updated_at]).gsub("\\r",""))
        file.write("\r\n")

        fond.units.each do |unit|
          unit.legacy_id = unit.id
          unit.legacy_parent_unit_id = unit.is_root? ? nil : unit.parent_id.to_s
          unit.legacy_root_fond_id = unit.root_fond_id
          unit.legacy_parent_fond_id = unit.fond_id
          file.write(unit.to_json(:except => [:id, :ancestry, :db_source, :created_by, :updated_by, :created_at, :updated_at]).gsub("\\r",""))
          file.write("\r\n")
          @export.unit_ids.push(unit.id)
        end
      end

      unless @export.fond_ids.empty?
        @export.tables[:fonds].each do |table|
          model = table.singularize.camelize.constantize
          set = model.where("fond_id IN (#{@export.fond_ids})")
          set.each do |e|
            e.legacy_id = e.fond_id
            file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
            file.write("\r\n")
          end
        end
      end
      export_units_related_entities(file, @export.unit_ids, @export.tables[:units])
    end
  end

  def rake_major_entities
    entities = ['creator', 'custodian', 'project']
    File.open(@export.data_file, "a") do |file|
      entities.each do |entity|
        container = Array.new
        relation = "rel_#{entity}_fond".camelize.constantize
        model = entity.camelize.constantize
        index = entity.pluralize.to_sym
        set = relation.where("fond_id IN (#{@export.fond_ids})")
        set.each do |rel|
          container.push rel.send("#{entity}_id")
          rel.legacy_fond_id = rel.fond_id
          rel.send("legacy_#{entity}_id=", rel.send("#{entity}_id"))
          file.write(rel.to_json(:except => [:id, :db_source, :fond_id, "#{entity}_id".to_sym, :created_at, :updated_at]))
          file.write("\r\n")
        end

        if entity == 'creator'
          direct_creators = container.join(',')
          unless direct_creators.blank?
            set = RelCreatorCreator.where("creator_id IN (#{direct_creators}) OR related_creator_id IN (#{direct_creators})")
            set.each do |rel|
              rel.legacy_creator_id = rel.creator_id
              rel.legacy_related_creator_id = rel.related_creator_id
              file.write(rel.to_json(:except => [:id, :db_source, :creator_id, :related_creator_id, :created_at, :updated_at]))
              file.write("\r\n")
              container.push(rel.creator_id)
              container.push(rel.related_creator_id)
            end
          end
        end

        ids = container.uniq.join(',')
        unless ids.blank?
          set = model.where("id IN (#{ids})")
          set.each do |ent|
            ent.legacy_id = ent.id
            file.write(ent.to_json(:except => [:id, :group_id, :db_source, :created_by, :updated_by, :created_at, :updated_at]))
            file.write("\r\n")
          end

          @export.tables[index].each do |table|
            attached_model = table.singularize.camelize.constantize
            set = attached_model.where("#{entity}_id IN (#{ids})")
            set.each do |e|
              e.legacy_id = e.send("#{entity}_id")
              file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
              file.write("\r\n")
            end
          end
        end
        @export.send("#{entity}_ids=", container.uniq)
      end
    end
  end

  def rake_institutions
    i = Array.new
    unless @export.creator_ids.blank?
      File.open(@export.data_file, "a") do |file|
        set = RelCreatorInstitution.where("creator_id IN (#{@export.creator_ids.join(',')})")
        set.each do |rel|
          rel.legacy_creator_id = rel.creator_id
          rel.legacy_institution_id = rel.institution_id
          file.write(rel.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
          file.write("\r\n")
          i.push(rel.institution_id)
        end

        @export.institution_ids = i.uniq
        unless @export.institution_ids.blank?
          set = Institution.where("id IN (#{@export.institution_ids.join(',')})")
          set.each do |institution|
            institution.legacy_id = institution.id
            file.write(institution.to_json(:except => [:id, :db_source, :group_id, :created_by, :updated_by, :created_at, :updated_at]))
            file.write("\r\n")
          end

          @export.tables[:institutions].each do |table|
            model = table.singularize.camelize.constantize
            set = model.where("institution_id IN (#{@export.institution_ids.join(',')})")
            set.each do |e|
              e.legacy_id = e.institution_id
              file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
              file.write("\r\n")
            end
          end
        end
      end
    end
  end

  def rake_headings
    entities = ['fond', 'unit']
    container = Array.new

    File.open(@export.data_file, "a") do |file|
      entities.each do |entity|
        relation = "rel_#{entity}_heading".camelize.constantize
        ids = @export.send("#{entity}_ids")
        ids = ids.join(',') unless entity == 'fond'
        unless ids.blank?
          set = relation.where("#{entity}_id IN (#{ids})")
# Upgrade 2.0.0 fine
          set.each do |rel|
            rel.send("legacy_#{entity}_id=", rel.send("#{entity}_id"))
            rel.legacy_heading_id = rel.heading_id
            file.write(rel.to_json(:except => [:id, :db_source, :source_id, "#{entity}_id".to_sym, :created_at, :updated_at]))
            file.write("\r\n")
            container.push(rel.heading_id)
          end
        end
      end

      headings = container.uniq.compact
      unless headings.blank?
        set = Heading.where("id IN (#{headings.join(',')})")
        set.each do |heading|
          heading.legacy_id = heading.id
          file.write(heading.to_json(:except => [:id, :db_source, :group_id, :created_at, :updated_at]))
          file.write("\r\n")
        end
      end
    end
  end

  def rake_document_forms
    df = Array.new
    File.open(@export.data_file, "a") do |file|
      set = RelFondDocumentForm.where("fond_id IN (#{@export.fond_ids})")
      set.each do |rel|
        rel.legacy_fond_id = rel.fond_id
        rel.legacy_document_form_id = rel.document_form_id
        file.write(rel.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
        file.write("\r\n")
        df.push(rel.document_form_id)
      end

      @export.document_form_ids = df.uniq
      unless @export.document_form_ids.blank?
        set = DocumentForm.where("id IN (#{@export.document_form_ids.join(',')})")
        set.each do |document_form|
          document_form.legacy_id = document_form.id
          file.write(document_form.to_json(:except => [:id, :db_source, :created_by, :updated_by, :group_id, :created_at, :updated_at]))
          file.write("\r\n")
        end

        @export.tables[:document_forms].each do |table|
          model = table.singularize.camelize.constantize
          set = model.where("document_form_id IN (#{@export.document_form_ids.join(',')})")
          set.each do |e|
            e.legacy_id = e.document_form_id
            file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
            file.write("\r\n")
          end
        end
      end
    end
  end

  def rake_sources
    entities = ['creator', 'custodian', 'fond', 'unit']
    container = Array.new

    File.open(@export.data_file, "a") do |file|
      entities.each do |entity|
        relation = "rel_#{entity}_source".camelize.constantize
        ids = @export.send("#{entity}_ids")
        ids = ids.join(',') unless entity == 'fond'
        unless ids.blank?
          set = relation.where("#{entity}_id IN (#{ids})")
          set.each do |rel|
            rel.send("legacy_#{entity}_id=", rel.send("#{entity}_id"))
            rel.legacy_source_id = rel.source_id
            file.write(rel.to_json(:except => [:id, :db_source, :source_id, "#{entity}_id".to_sym, :created_at, :updated_at]))
            file.write("\r\n")
            container.push(rel.source_id)
          end
        end
      end

      @export.source_ids = container.uniq
      unless @export.source_ids.blank?
        set = Source.where("id IN (#{@export.source_ids.join(',')})")
        set.each do |source|
          source.legacy_id = source.id
          file.write(source.to_json(:except => [:id, :db_source, :created_by, :updated_by, :group_id, :created_at, :updated_at]))
          file.write("\r\n")
        end

        @export.tables[:sources].each do |table|
          model = table.singularize.camelize.constantize
          set = model.where("source_id IN (#{@export.source_ids.join(',')})")
          set.each do |e|
            e.legacy_id = e.source_id
            file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
            file.write("\r\n")
          end
        end
      end
    end
  end

  def rake_editors
    File.open(@export.data_file, "a") do |file|
      set = Editor.where("group_id = #{@export.group_id}")
      set.each do |editor|
        editor.legacy_id = editor.id
        file.write(editor.to_json(:except => [:id, :db_source, :group_id, :created_at, :updated_at]))
        file.write("\r\n")
      end
    end
  end

  def rake_digital_objects
    entities = {
      'Fond' => @export.fond_ids,
      'Unit' => @export.unit_ids,
      'Creator' => @export.creator_ids,
      'Custodian' => @export.custodian_ids,
      'Source' => @export.source_ids
    }
    File.open(@export.data_file, "a") do |file|
      entities.each do |type, ids|
        export_entity_related_digital_objects(file, type, ids)
      end
    end
  end

  def export_units_related_entities(file, unit_ids, unit_related_tables)
    sc2_attribution_reasons_ids = Array.new
    sc2_commission_names_ids = Array.new
    
    unless unit_ids.empty?
      unit_related_tables.each do |table|
        model = table.singularize.camelize.constantize
        set = model.where("unit_id IN (#{unit_ids.join(',')})")
        set.each do |e|
          e.legacy_id = e.unit_id
          if (["sc2_authors","sc2_commissions"].include?(table)) then
            e.legacy_current_id = e.id
            if (table == "sc2_authors") then sc2_attribution_reasons_ids.push(e.id) end
            if (table == "sc2_commissions") then sc2_commission_names_ids.push(e.id) end
          end
          file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
          file.write("\r\n")
        end
      end
    end
    unless sc2_attribution_reasons_ids.empty?
      set = Sc2AttributionReason.where("sc2_author_id IN (#{sc2_attribution_reasons_ids.join(',')})")
      set.each do |e|
        e.legacy_id = e.sc2_author_id
        file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
        file.write("\r\n")
      end
    end
    unless sc2_commission_names_ids.empty?
      set = Sc2CommissionName.where("sc2_commission_id IN (#{sc2_commission_names_ids.join(',')})")
      set.each do |e|
        e.legacy_id = e.sc2_commission_id
        file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
        file.write("\r\n")
      end
    end
  end

  def export_entity_related_digital_objects(file, type, entity_ids)
    unless entity_ids.blank?
      entity_ids = entity_ids.join(',') unless type == 'Fond'
      set = DigitalObject.where("attachable_id IN (#{entity_ids}) AND attachable_type = '#{type}'")
      set.each do |digital_object|
        digital_object.legacy_id = digital_object.attachable_id
        file.write(digital_object.to_json(:except => [:id, :group_id, :db_source, :created_by, :updated_by, :created_at, :updated_at]))
        file.write("\r\n")
      end
    end
  end

  desc "Genera estrazioni aef con oggetti digitali relativi a: [fonds | projects | custodians]"
  task :build_data, [:records, :query] => :environment do |t, args|
    case args[:records]
    when "fonds"
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          puts "Estrazione dati aef relativi a complessi archivistici ..."
          fond_root_ids = Fond.find_by_sql(query).map(&:id)
          if fond_root_ids.empty?
            puts "Estrazione dati terminata. Non ci sono fondi corrispondenti ai criteri selezionati."
          else
            i = 1
            fond_root_ids.each do |frid|
              suffix = Time.now.strftime("%Y%m%d%H%M%S")
              @export = Export.new
              @export.target_id = frid
              @export.target_class = "fond"
              @export.mode = "full"
              @export.metadata_file = TMP_AEF_EXPORTS + "/metadata-#{suffix}.json"
              @export.data_file = TMP_AEF_EXPORTS + "/data-#{suffix}.json"
              @export.dest_file = TMP_AEF_EXPORTS + "/archimista-#{get_rake_target_class_caption(@export.target_class)}-#{i}-#{suffix}.aef"
              i += 1
              @export.inc_digit = 'true'
              model = @export.target_class.singularize.camelize.constantize
              entity = model.find(@export.target_id)
              @export.group_id = entity.group_id
              begin
                create_rake_export_file
              rescue Exception => e
                puts "ERRORE: #{e.message}"
              end        
            end
          end         
        rescue Exception => e
          puts "Eccezione #{e}"
        end
        puts "Estrazione dati terminata"      
      end
    when "projects"
      query = args[:query]
      if query.blank?
        puts "Query non inserita. Ripetere la procedura."
      else
        begin
          puts "Estrazione dati aef relativi a progetti ..."
          project_ids = Project.find_by_sql(query).map(&:id)
          if project_ids.empty?
            puts "Estrazione dati terminata. Non ci sono progetti corrispondenti ai criteri selezionati."
          else
            i = 1
            project_ids.each do |pid|
              suffix = Time.now.strftime("%Y%m%d%H%M%S")
              @export = Export.new
              @export.target_id = pid
              @export.target_class = "project"
              @export.mode = "full"
              @export.metadata_file = TMP_AEF_EXPORTS + "/metadata-#{suffix}.json"
              @export.data_file = TMP_AEF_EXPORTS + "/data-#{suffix}.json"
              @export.dest_file = TMP_AEF_EXPORTS + "/archimista-#{get_rake_target_class_caption(@export.target_class)}-#{i}-#{suffix}.aef"
              i += 1
              @export.inc_digit = 'true'
              model = @export.target_class.singularize.camelize.constantize
              entity = model.find(@export.target_id)
              @export.group_id = entity.group_id
              begin
                create_rake_export_file
              rescue Exception => e
                puts "ERRORE: #{e.message}"
              end  
              puts "Estrazione dati terminata"      
            end
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
          puts "Estrazione dati aef relativi a soggetti conservatori ..."
          custodian_ids = Custodian.find_by_sql(query).map(&:id)
          if custodian_ids.empty?
            puts "Estrazione dati terminata. Non ci sono soggetti conservatori corrispondenti ai criteri selezionati."
          else
            i = 1
            custodian_ids.each do |cid|
              suffix = Time.now.strftime("%Y%m%d%H%M%S")
              @export = Export.new
              @export.target_id = cid
              @export.target_class = "custodian"
              @export.mode = "full"
              @export.metadata_file = TMP_AEF_EXPORTS + "/metadata-#{suffix}.json"
              @export.data_file = TMP_AEF_EXPORTS + "/data-#{suffix}.json"
              @export.dest_file = TMP_AEF_EXPORTS + "/archimista-#{get_rake_target_class_caption(@export.target_class)}-#{i}-#{suffix}.aef"
              i += 1
              @export.inc_digit = 'true'
              model = @export.target_class.singularize.camelize.constantize
              entity = model.find(@export.target_id)
              @export.group_id = entity.group_id
              begin
                create_rake_export_file
              rescue Exception => e
                puts "ERRORE: #{e.message}"
              end      
              puts "Estrazione dati terminata"        
            end
          end
        rescue Exception => e
          puts "Eccezione #{e}"
        end
      end
    else
      puts "Argomento non valido.\nScegli tra [fonds | creators | custodians | sources]"
    end
  end

end