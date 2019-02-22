class Import < ActiveRecord::Base
  require 'csv'
  
# Upgrade 2.0.0 inizio
#  require 'zip/zip'
# nella versione rubyzip-1.1.6 zip.rb non è nella sottocartella zip dive invece era nella rubyzip-0.9.9 usata prima
  require 'zip'
# Upgrade 2.0.0 fine

# Upgrade 2.1.0 inizio
  extend Sc2Restore
# Upgrade 2.1.0 fine

  attr_accessor :imported_file_version
# Upgrade 2.2.0 inizio
  attr_accessor :ref_fond_id, :ref_root_fond_id
# Upgrade 2.2.0 fine

  TMP_IMPORTS = "#{Rails.root}/tmp/imports"
# Upgrade 3.0.0 inizio  
  PUBLIC_IMPORTS = "#{Rails.root}/public/imports"
# Upgrade 3.0.0 fine  
  DIGITAL_FOLDER_PATH = "#{Rails.root}/public/digital_objects"

  belongs_to :user
  belongs_to :importable, :polymorphic => true

  has_attached_file :data, :path => ":rails_root/public/imports/:id/:basename.:extension"

  before_create :sanitize_file_name
  validates_attachment_presence :data
# Upgrade 2.0.0 inizio
  do_not_validate_attachment_file_type :data
# Upgrade 2.0.0 fine

  def ar_connection
# Upgrade 2.0.0 inizio
#    ActiveRecord::Base.connection
    self.class.connection
# Upgrade 2.0.0 fine
  end

  def adapter
    ar_connection.adapter_name.downcase
  end

  def zip_data_file
    filename = self.importable_type.downcase
    TMP_IMPORTS + "/#{self.id}_data-#{filename}.xml"  
  end

# Upgrade 3.0.0 inizio  
  def csv_data_file
    PUBLIC_IMPORTS + "/#{self.id}/#{self.data_file_name}"  
  end
# Upgrade 3.0.0 fine  

  def data_file
    TMP_IMPORTS + "/#{self.id}_data.json"
  end

  def metadata_file
    TMP_IMPORTS + "/#{self.id}_metadata.json"
  end

  def delete_tmp_files
    File.delete(data_file)      if File.exists?(data_file)
    File.delete(metadata_file)  if File.exists?(metadata_file)
  end

  def delete_tmp_zip_files
    @extracted_files.each do |efd|
      File.delete(efd) if File.exists?(efd)
    end
    File.delete(TMP_IMPORTS + "/data.json")  if File.exists?(TMP_IMPORTS + "/data.json")
  end

  def delete_digital_folder(folder)
    if Dir.exists?(DIGITAL_FOLDER_PATH + "/" + folder)
      FileUtils.remove_dir(DIGITAL_FOLDER_PATH + "/" + folder)
    end
  end

  def db_has_subunits?
    Unit.exists?(["db_source = ? AND ancestry_depth > 0", self.identifier])
  end

  def db_has_digital_objects?
    DigitalObject.exists?(["db_source = ?", self.identifier])
  end

# Upgrade 2.2.0 inizio
  def is_unit_importable_type?
    return (importable_type == "Unit")
  end

  def is_unit_aef_file?
    return is_unit_importable_type?
  end

# Upgrade 3.0.0 inizio
# modificata nella 3.1.1 con l'utilizzo della gemma csv
  def import_csv_file(user, ability)
    begin
      csv_file = CSV.read(csv_data_file)
      lines = File.readlines(csv_data_file)
      unit_aef_import_units_count = 0
		
      ActiveRecord::Base.transaction do
        model = nil
        prev_model = nil
        object = nil
        prev_line = ""
        headers = ""
        elem_count = 0
        separator = ""
        lines.each_with_index do |line, i|
          line = line.delete("\r")
          line = line.delete("\a")
          line = line.delete("\b")
          line = line.delete("\t")
          line = line.delete("\f")
          if prev_line.blank?
            elements = line.delete("\n").split(',')            
            elem_count > elements.count - 1 ? elem_count = elem_count : elem_count = elements.count - 1
            separator = "," * elem_count
            elem = elements[1].split('_')
            pos_last = -1
            elem.each do |e|
              if e.last == "s"
                pos_last += 1
                break
              else
                pos_last += 1
              end            
            end
            key = (elem[0..pos_last].join('_'))[0..-2]
            key = key.to_s
            model = key.camelize.constantize
            headers = elements.map!{ |element| element.gsub(key + 's_', '') }
            prev_line = "not_blank"
          else
            line = line.delete("\n")
            if (line.include? separator) || (line.blank?)
              prev_line = ""
              next
            else
              values = csv_file[i]
              values = values.map!{ |value| value.nil? ? '' : value }
              zipped = headers.zip(values)
              ipdata = Hash[zipped]
              object = model.new(ipdata)
              object.db_source = self.identifier
              if object.has_attribute? 'group_id'
                object.group_id = if user.is_multi_group_user?() then ability.target_group_id else user.rel_user_groups[0].group_id end
              end
              if (self.is_unit_aef_file?)
                if (model.to_s == "Unit")
                  object.fond_id = self.ref_fond_id
                  object.root_fond_id = prv_get_ref_root_fond_id
                  unit_aef_import_units_count += 1
                end
              end
              object.created_by = user.id if object.has_attribute? 'created_by'
              object.updated_by = user.id if object.has_attribute? 'updated_by'
              object.sneaky_save!
              if model != prev_model && !prev_model.nil?
                prev_object = prev_model.new
                set_lacking_field_values(prev_object)
              end
              prev_model = model
            end
          end
        end
      end
      update_statements(unit_aef_import_units_count)
    rescue Exception => e
      Rails.logger.info "import_csv_file errore: " + e.message.to_s
      return false
    ensure
    end
  end
# Upgrade 3.0.0 fine

  def fond_creator_relation(creator_id)
    rel_creator_fond = {'rel_creator_fond' => { 
        'legacy_creator_id'=> creator_id,
        'legacy_fond_id'=> @fond_leg_id
        }
      }
      File.open(TMP_IMPORTS + "/data.json","a") do |f|
        f.write(rel_creator_fond.to_json)
        f.write("\r\n")
      end 
  end

  def extract_creator(zip_data_file)
    xml = File.open(zip_data_file).read
    json = Hash.from_xml(xml).to_json      
    parsed_xml_to_json = ActiveSupport::JSON.decode(json).symbolize_keys
    if parsed_xml_to_json[:eac_cpf]["cpfDescription"].kind_of?(Array)
      creator_size = parsed_xml_to_json[:eac_cpf]["cpfDescription"].length
      creator_num = 0
      begin
        creator_leg_id = rand(1..1000)
        fond_creator_relation(creator_leg_id)
        entityType = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["identity"]["entityType"]
        if entityType == "corporateBody"
          creator_type = "C"
          event_start = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["description"]["existDates"]["dateRange"]
          event_end = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["description"]["existDates"]["dateRange"]
          residence = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["description"]["place"]["placeEntry"]
        elsif entityType == "person"
          creator_type = "P"
          event_start = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["description"]["existDates"][0]
          event_end = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["description"]["existDates"][1]
          residence = nil
        elsif entityType == "family"
          creator_type = "F"
          event_start = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["description"]["existDates"][0]
          event_end = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["description"]["existDates"][1]
          residence = nil
        end
    history = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["description"]["biogHist"].present? ? parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["description"]["biogHist"]["abstract"] : nil
        creator = {'creator' => { 
          'creator_type'=> creator_type,
          'creator_corporate_type_id'=> nil,
          'residence'=> residence,
          'abstract'=> '',
          'history'=> history,
          'legal_status'=> nil,
          'note'=> '',
          'legacy_id'=> creator_leg_id,
          'published'=> true
          }
        }
        File.open(TMP_IMPORTS + "/data.json","a") do |f|
          f.write(creator.to_json)
          f.write("\r\n")
        end 

        rel_creator_event(event_start, event_end, creator_leg_id)

        if parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["identity"]["nameEntry"].present?
          if parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["identity"]["nameEntry"].kind_of?(Array)
            size = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["identity"]["nameEntry"].length
            nums = 0      
            begin
              creator_name = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["identity"]["nameEntry"][nums]["part"]  
              preferred = true
              qualifier = "A"
              if nums > 0
                preferred = false
                qualifier = "OT"
              end
              rel_creator_name(creator_name, creator_leg_id, preferred, qualifier)  
              nums += 1  
            end while size > nums
          else
            creator_name = parsed_xml_to_json[:eac_cpf]["cpfDescription"][creator_num]["identity"]["nameEntry"]["part"]  
            preferred = true
            qualifier = "A"
            rel_creator_name(creator_name, creator_leg_id, preferred, qualifier)
          end
        end  

        if parsed_xml_to_json[:eac_cpf]["control"][creator_num]["maintenanceHistory"]["maintenanceEvent"].kind_of?(Array)
          length_editor = parsed_xml_to_json[:eac_cpf]["control"][creator_num]["maintenanceHistory"]["maintenanceEvent"].length
          num = 0
          begin
             creator_editor = parsed_xml_to_json[:eac_cpf]["control"][creator_num]["maintenanceHistory"]["maintenanceEvent"][num]
             rel_creator_editor(creator_editor, creator_leg_id)
             num +=1
          end while length_editor > num
        else
          creator_editor = parsed_xml_to_json[:eac_cpf]["control"][creator_num]["maintenanceHistory"]["maintenanceEvent"]
          rel_creator_editor(creator_editor, creator_leg_id)
        end
        creator_num += 1  
      end while creator_size > creator_num
    else
        creator_leg_id = rand(1..1000)
        fond_creator_relation(creator_leg_id)
        entityType = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["identity"]["entityType"]
        if entityType == "corporateBody"
          creator_type = "C"
          event_start = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["description"]["existDates"]["dateRange"]
          event_end = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["description"]["existDates"]["dateRange"]
          residence = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["description"]["place"]["placeEntry"]
        elsif entityType == "person"
          creator_type = "P"
          event_start = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["description"]["existDates"][0]
          event_end = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["description"]["existDates"][1]
          residence = nil
        elsif entityType == "family"
          creator_type = "F"
          event_start = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["description"]["existDates"][0]
          event_end = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["description"]["existDates"][1]
          residence = nil
        end
    	history = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["description"]["biogHist"].present? ? parsed_xml_to_json[:eac_cpf]["cpfDescription"]["description"]["biogHist"]["abstract"] : nil

        creator = {'creator' => { 
          'creator_type'=> creator_type,
          'creator_corporate_type_id'=> nil,
          'residence'=> residence,
          'abstract'=> '',
          'history'=> history,
          'legal_status'=> nil,
          'note'=> '',
          'legacy_id'=> creator_leg_id,
          'published'=> true
          }
        }
        File.open(TMP_IMPORTS + "/data.json","a") do |f|
          f.write(creator.to_json)
          f.write("\r\n")
        end 

        rel_creator_event(event_start, event_end, creator_leg_id)

        if parsed_xml_to_json[:eac_cpf]["cpfDescription"]["identity"]["nameEntry"].present?
           if parsed_xml_to_json[:eac_cpf]["cpfDescription"]["identity"]["nameEntry"].kind_of?(Array)
            size = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["identity"]["nameEntry"].length
            nums = 0       
            begin
              creator_name = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["identity"]["nameEntry"][nums]["part"]  
              preferred = true
              qualifier = "A"
              if nums > 0
                preferred = false
                qualifier = "OT"
              end
              rel_creator_name(creator_name, creator_leg_id, preferred, qualifier)  
              nums += 1  
            end while size > nums
          else
            creator_name = parsed_xml_to_json[:eac_cpf]["cpfDescription"]["identity"]["nameEntry"]["part"]  
            preferred = true
            qualifier = "A"
            rel_creator_name(creator_name, creator_leg_id, preferred,qualifier)
          end
        end  

        if parsed_xml_to_json[:eac_cpf]["control"]["maintenanceHistory"]["maintenanceEvent"].kind_of?(Array)
          length_editor = parsed_xml_to_json[:eac_cpf]["control"]["maintenanceHistory"]["maintenanceEvent"].length
          num = 0
          begin
             creator_editor = parsed_xml_to_json[:eac_cpf]["control"]["maintenanceHistory"]["maintenanceEvent"][num]
             rel_creator_editor(creator_editor, creator_leg_id)
             num +=1
          end while length_editor > num
        else
          creator_editor = parsed_xml_to_json[:eac_cpf]["control"]["maintenanceHistory"]["maintenanceEvent"]
          rel_creator_editor(creator_editor, creator_leg_id)
        end
    end
  end

  def rel_creator_editor(rel_c, creator_id)

    creator_editor = {'creator_editor' => { 
      'creator_id'=> creator_id,
      'name'=> rel_c["agent"],
      'qualifier'=> nil,
      'editing_type'=> rel_c["eventType"],
      'edited_at'=> rel_c["eventDateTime"],
      'legacy_id'=> creator_id
      }
    }

    File.open(TMP_IMPORTS + "/data.json","a") do |f|
      f.write(creator_editor.to_json)
      f.write("\r\n")
    end 

  end

  def rel_creator_name(rel_c, creator_id, preferred, qualifier)
    creator_name = {'creator_name' => { 
      'creator_id'=> creator_id,
      'preferred'=> preferred,
      'name'=> rel_c,
      'first_name'=> nil,
      'last_name'=> nil,
      'qualifier'=> qualifier,
      'patronymic'=> nil,
      'nickname'=> nil,
      'legacy_id'=> creator_id
      }
    }

    File.open(TMP_IMPORTS + "/data.json","a") do |f|
      f.write(creator_name.to_json)
      f.write("\r\n")
    end 
  end

  def rel_creator_event(event_start, event_end, creator_id)
    
    if(event_start["fromDate"] != nil)
      st_date = event_start["fromDate"]
      start_date_from = st_date + '-01-01'
      start_date_to = st_date + '-12-31'
      start_date_display = st_date
      start_date_format = 'Y'
    elsif(event_start["date"] != nil)
      st_date = event_start["date"]
      start_date_from = nil
      start_date_to = nil
      start_date_display = st_date
      start_date_format = 'YMD'
    elsif(event_start["dateRange"]["fromDate"] != nil)
      st_date = event_start["dateRange"]["fromDate"]
      start_date_from = nil
      start_date_to = nil
      start_date_display = st_date
      start_date_format = 'C'
    end
    
    if(event_end["fromDate"] != nil)
      end_date = event_start["fromDate"]
      end_date_from = end_date + '-01-01'
      end_date_to = end_date + '-12-31'
      end_date_display = end_date
      end_date_format = 'Y'
    elsif(event_end["date"] != nil)
      end_date = event_start["date"]
      end_date_from = nil
      end_date_to = nil
      end_date_display = end_date
      end_date_format = 'YMD'
    elsif(event_end["dateRange"]["fromDate"] != nil)
      end_date = event_start["dateRange"]["fromDate"]
      end_date_from = nil
      end_date_to = nil
      end_date_display = end_date
      end_date_format = 'C'
    end

    creator_event = {'creator_event' => { 
          'creator_id'=> creator_id,
          'preferred'=> true,
          'is_valid'=> true,
          'start_date_place'=> nil,
          'start_date_spec'=> 'idem',
          'start_date_from'=> start_date_from,
          'start_date_to'=> start_date_to,
          'start_date_valid'=> 'C',
          'start_date_format'=> start_date_format,
          'start_date_display'=> start_date_display,
          'end_date_place'=> nil,
          'end_date_spec'=> 'idem',
          'end_date_from'=> end_date_from,
          'end_date_to'=> end_date_to,
          'end_date_valid'=> 'C',
          'end_date_format'=> end_date_format,
          'end_date_display'=> end_date_display,
          'legacy_display_date'=> nil,
          'order_date'=> nil,
          'note'=> '',
          'legacy_id'=> creator_id
        }
      }  
      File.open(TMP_IMPORTS + "/data.json","a") do |file|
        file.write(creator_event.to_json)
        file.write("\r\n")
      end   
  end

  def fond_custodian_relation(custodian_id)
    rel_custodian_fond = {'rel_custodian_fond' => { 
        'legacy_custodian_id'=> custodian_id,
        'legacy_fond_id'=> @fond_leg_id
        }
      }
      File.open(TMP_IMPORTS + "/data.json","a") do |f|
        f.write(rel_custodian_fond.to_json)
        f.write("\r\n")
      end 
  end

  def extract_custodian(zip_data_file)
    xml = File.open(zip_data_file).read
    json = Hash.from_xml(xml).to_json      
    parsed_xml_to_json = ActiveSupport::JSON.decode(json)
    custodian_leg_id = rand(1..1000)
    fond_custodian_relation(custodian_leg_id)
    c_id = CustodianType.where("custodian_type like (?)", parsed_xml_to_json["scons"]["tipologia"]).first.id

    custodian = {'custodian' => { 
      'custodian_type_id'=> c_id,
      'legal_status'=> nil,
      'owner'=> nil,
      'contact_person'=> '',
      'history'=> parsed_xml_to_json["scons"]["descrizione"],
      'administrative_structure'=> nil,
      'collecting_policies'=> nil,
      'holdings'=> nil,
      'accessibility'=> nil,
      'services'=> nil,
      'legacy_id'=> custodian_leg_id,
      'published'=> true
      }
    }
    File.open(TMP_IMPORTS + "/data.json","a") do |f|
      f.write(custodian.to_json)
      f.write("\r\n")
    end 

    custodian_name = parsed_xml_to_json["scons"]["formaautorizzata"]
    rel_custodian_name(custodian_name, custodian_leg_id)

    if parsed_xml_to_json["scons"]["info"]["evento"].kind_of?(Array)
    	length_editor = parsed_xml_to_json["scons"]["info"]["evento"].length
	    num = 0
	    begin
	       custodian_editor = parsed_xml_to_json["scons"]["info"]["evento"][num]
	       rel_custodian_editor(custodian_editor, custodian_leg_id)
	       num +=1
	    end while length_editor > num
    else
    	custodian_editor = parsed_xml_to_json["scons"]["info"]["evento"]
	    rel_custodian_editor(custodian_editor, custodian_leg_id)
    end
    
  end

  def rel_custodian_editor(rel_c, cust_id)

    custodian_editor = {'custodian_editor' => { 
      'custodian_id'=> cust_id,
      'name'=> rel_c["agente"]["cognome"],
      'qualifier'=> nil,
      'editing_type'=> rel_c["tipoevento"],
      'edited_at'=> rel_c["dataevento"],
      'legacy_id'=> cust_id
      }
    }

    File.open(TMP_IMPORTS + "/data.json","a") do |f|
      f.write(custodian_editor.to_json)
      f.write("\r\n")
    end 
    
  end

  def rel_custodian_name(rel_c, cust_id)
    custodian_name = {'custodian_name' => { 
      'custodian_id'=> cust_id,
      'preferred'=> true,
      'name'=> rel_c,
      'qualifier'=> "AU",
      'note'=> '',
      'legacy_id'=> cust_id
      }
    }

    File.open(TMP_IMPORTS + "/data.json","a") do |f|
      f.write(custodian_name.to_json)
      f.write("\r\n")
    end 
  end

  def extract_fond(zip_data_file)
      xml = File.open(zip_data_file).read
      json = Hash.from_xml(xml).to_json      
      parsed_xml_to_json = ActiveSupport::JSON.decode(json)
      @fond_leg_id = rand(1..1000)

      fond_name = parsed_xml_to_json["ead"]["control"]["recordid"].present? ? parsed_xml_to_json["ead"]["control"]["recordid"] : nil
      fond_first_levels = {"recordgrp" => "complesso di fondi",
      "fonds" => "fondo", "subfonds" => "subfondo",  
      "series" => "serie", "subseries" => "sottoserie"}
      if(parsed_xml_to_json["ead"]["archdesc"]["level"].present?)
      	if(parsed_xml_to_json["ead"]["archdesc"]["level"].include? "otherlevel")
      		fond_type = fond_first_levels[parsed_xml_to_json["ead"]["archdesc"]["otherlevel"]]
      	else
      		fond_type = fond_first_levels[parsed_xml_to_json["ead"]["archdesc"]["level"]]
      	end      	
      else
      	fond_type = nil
      end
      fond_length = parsed_xml_to_json["ead"]["archdesc"]["did"]["physdescstructured"]["quantity"].present? ? parsed_xml_to_json["ead"]["archdesc"]["did"]["physdescstructured"]["quantity"] : nil
      fond_extent = parsed_xml_to_json["ead"]["archdesc"]["did"]["physdescstructured"]["descriptivenote"].present? ? parsed_xml_to_json["ead"]["archdesc"]["did"]["physdescstructured"]["descriptivenote"]["p"] : nil
      fond_description = parsed_xml_to_json["ead"]["archdesc"]["scopecontent"].present? ? parsed_xml_to_json["ead"]["archdesc"]["scopecontent"]["p"] : nil
      arrangement_note = parsed_xml_to_json["ead"]["archdesc"]["arrangement"].present? ? parsed_xml_to_json["ead"]["archdesc"]["arrangement"]["p"] : nil
      access_condition_note = parsed_xml_to_json["ead"]["archdesc"]["accessrestrict"].present? ? parsed_xml_to_json["ead"]["archdesc"]["accessrestrict"]["p"] : nil
      #use_condition_note = parsed_xml_to_json["ead"]["archdesc"]["custodhist"].present? ? parsed_xml_to_json["ead"]["archdesc"]["custodhist"]["p"] : nil
      fond_history = parsed_xml_to_json["ead"]["archdesc"]["custodhist"].present? ? parsed_xml_to_json["ead"]["archdesc"]["custodhist"]["p"] : nil

      fond = {'fond' => { 
          'ancestry_depth'=> 0,
          'position'=> rand(1..1000),
          'sequence_number'=> 1,
          'trashed'=> false,
          'trashed_ancestor_id'=> nil,
          'units_count'=> 0,
          'name'=> fond_name,
          'fond_type'=> fond_type,
          'length'=> fond_length,
          'extent'=> fond_extent,
          'abstract'=> nil,
          'description'=> fond_description,
          'arrangement_note'=> arrangement_note,
          'related_materials'=> nil,
          'access_condition'=> nil,
          'access_condition_note'=> access_condition_note,
          'history' => fond_history,
          'use_condition'=> nil,
          'use_condition_note'=> '',
          'type_materials'=> nil,
          'preservation'=> nil,
          'preservation_note'=> nil,
          'description_type'=> nil,
          'note'=> nil,
          'legacy_id'=> @fond_leg_id,
          'legacy_parent_id'=> nil,
          'published'=> true,
        }
      }

      File.open(TMP_IMPORTS + "/data.json","w+") do |f|
        f.write(fond.to_json)
        f.write("\r\n")
      end 

      if parsed_xml_to_json["ead"]["archdesc"]["did"]["unittitle"].kind_of?(Array)
      	names_array = parsed_xml_to_json["ead"]["archdesc"]["did"]["unittitle"]
      	names_array.delete_at(0)
      	names_array.each do |na|
      		fond_name = na
      		rel_fond_name(fond_name, @fond_leg_id)
      	end      	      	
      end

      #fond_event = parsed_xml_to_json["ead"]["archdesc"]["did"]
      #rel_fond_event(fond_event, @fond_leg_id)

      if parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"] != nil
        #length_c1 = parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"].length
        length_c1 = 1
        num_c1 = 0
        begin
          leg_id_for_children = rand(1..1000)
          rel_fonds_def(parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"], 1, 1, 2, @fond_leg_id, leg_id_for_children)
          #fond_event = parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["did"]
          #rel_fond_event(fond_event, leg_id_for_children)
          if parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["did"]["unittitle"].kind_of?(Array)
      		names_array = parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["did"]["unittitle"]
      		names_array.delete_at(0)
      		names_array.each do |na|
      			fond_name = na
      			rel_fond_name(fond_name, leg_id_for_children)
      		end      	      	
      	  end

          if parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"].present?
            if parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"].kind_of?(Array)
              length_c2 = parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"].length
              num_c2 = 0
              begin
                rel_f = parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"][num_c2]
                new_leg_id_for_children = rand(1..1000)
                rel_fonds_def(rel_f, 2, num_c1+1, num_c1+3, leg_id_for_children, new_leg_id_for_children)
                #fond_event = parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"][num_c2]["did"]
                #rel_fond_event(fond_event, new_leg_id_for_children)
                if parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"][num_c2]["did"]["unittitle"].kind_of?(Array)
	      			names_array = parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"][num_c2]["did"]["unittitle"]
	      			names_array.delete_at(0)
	      			names_array.each do |na|
	      				fond_name = na
	      				rel_fond_name(fond_name, new_leg_id_for_children)
	      			end      	      	
	      	    end
                num_c2 +=1
              end while length_c2 > num_c2
            else
              rel_f = parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"]
              new_leg_id_for_children = rand(1..1000)
              rel_fonds_def(rel_f, 2, num_c1+1, num_c1+3, leg_id_for_children, new_leg_id_for_children)
              #fond_event = parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"]["did"]
              #rel_fond_event(fond_event, new_leg_id_for_children)
              if parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"]["did"]["unittitle"].kind_of?(Array)
	      			names_array = parsed_xml_to_json["ead"]["archdesc"]["dsc"]["c"]["c"]["did"]["unittitle"]
	      			names_array.delete_at(0)
	      			names_array.each do |na|
	      				fond_name = na
	      				rel_fond_name(fond_name, new_leg_id_for_children)
	      			end      	      	
	      	    end
            end            
          end
          num_c1 +=1
        end while length_c1 > num_c1
      end     

        length_editor = parsed_xml_to_json["ead"]["control"]["maintenancehistory"]["maintenanceevent"].length

        num = 0
        begin
           fond_editor = parsed_xml_to_json["ead"]["control"]["maintenancehistory"]["maintenanceevent"][num]
           rel_fond_editor(fond_editor, @fond_leg_id)
           num +=1
        end while length_editor > num
  end

  def rel_fond_name(rel_f, fond_id)
  	fond_name_rel = {'fond_name' => {
  		'fond_id'=> fond_id,
  		'name'=> rel_f,
        'qualifier'=> 'O',
  		'note'=> '',
  		'legacy_id'=> fond_id
  		}
  	}

  	File.open(TMP_IMPORTS + "/data.json","a") do |file|
    	file.write(fond_name_rel.to_json)
    	file.write("\r\n")
  	end 
  end

  def rel_fond_editor(rel_f, fond_id)

    fond_editor_rel = {'fond_editor' => { 
        'fond_id'=> fond_id,
        'name'=> rel_f["agent"],
        'qualifier'=> rel_f["agent"],
        'editing_type'=> rel_f["eventtype"]["value"],
        'edited_at'=> rel_f["eventdatetime"],
        'legacy_id'=> fond_id
      }
    }
    File.open(TMP_IMPORTS + "/data.json","a") do |file|
    	file.write(fond_editor_rel.to_json)
    	file.write("\r\n")
  	end 
  end

  def rel_fond_event(rel_f, fond_id)
    if(rel_f["normal"] != nil)
      date = rel_f["normal"]
      st_date = date.split('/')[0][0..3]
      end_date = date.split('/')[1][0..3]
    else
      date = rel_f["unitdate"]
      if date.include? "["
        st_date = date[1..4]
        end_date = date[1..4]
      elsif date.include? " - "
        st_date = date.split(' - ')[0]
        end_date = date.split(' - ')[1]
      else
        st_date = date
        end_date = date
      end
    end
    
    fond_event_rel = {'fond_event' => { 
          'fond_id'=> fond_id,
          'preferred'=> true,
          'is_valid'=> true,
          'start_date_place'=> nil,
          'start_date_spec'=> 'idem',
          'start_date_from'=> st_date + '-01-01',
          'start_date_to'=> st_date + '-12-31',
          'start_date_valid'=> 'C',
          'start_date_format'=> 'Y',
          'start_date_display'=> st_date,
          'end_date_place'=> nil,
          'end_date_spec'=> 'idem',
          'end_date_from'=> end_date + '-01-01',
          'end_date_to'=> end_date + '-12-31',
          'end_date_valid'=> 'C',
          'end_date_format'=> 'Y',
          'end_date_display'=> end_date,
          'legacy_display_date'=> nil,
          'order_date'=> st_date + '-01-01|1|' + st_date + '-12-31|0|' + end_date + '-01-01|1|' + end_date + '-12-31|0|',
          'note'=> '',
          'legacy_id'=> fond_id
        }
      }  
      File.open(TMP_IMPORTS + "/data.json","a") do |file|
        file.write(fond_event_rel.to_json)
        file.write("\r\n")
      end    
  end

  def rel_fonds_def(rel_f, dep, pos, seq, fond_leg_id,leg_id_for_children)
  	if rel_f["did"]["unittitle"].kind_of?(Array)
  		names_array = rel_f["did"]["unittitle"]
  		fond_rel_name = names_array[0]      	      	
  	else
  		fond_rel_name = rel_f["did"]["unittitle"]
  	end

  	fond_first_levels = {"recordgrp" => "complesso di fondi",
      "fonds" => "fondo", "subfonds" => "subfondo",  
      "series" => "serie", "subseries" => "sottoserie"}
      if(rel_f["level"].present?)
      	if(rel_f["level"].include? "otherlevel")
      		fond_type = fond_first_levels[rel_f["otherlevel"]]
      	else
      		fond_type = fond_first_levels[rel_f["level"]]
      	end      	
      else
      	fond_type = nil
      end
      fond_length = rel_f["did"]["physdescstructured"]["quantity"].present? ? rel_f["did"]["physdescstructured"]["quantity"] : nil
      fond_extent = rel_f["did"]["physdescstructured"]["descriptivenote"].present? ? rel_f["did"]["physdescstructured"]["descriptivenote"]["p"] : nil
      fond_description = rel_f["scopecontent"].present? ? rel_f["scopecontent"]["p"] : nil
      arrangement_note = rel_f["arrangement"].present? ? rel_f["arrangement"]["p"] : nil
      access_condition_note = rel_f["accessrestrict"].present? ? rel_f["accessrestrict"]["p"] : nil
      #use_condition_note = parsed_xml_to_json["ead"]["archdesc"]["custodhist"].present? ? parsed_xml_to_json["ead"]["archdesc"]["custodhist"]["p"] : nil
      fond_history = rel_f["custodhist"].present? ? rel_f["custodhist"]["p"] : nil


    fond_rel = {'fond' => { 
          'ancestry_depth'=> dep,
          'position'=> pos,
          'sequence_number'=> seq,
          'trashed'=> false,
          'trashed_ancestor_id'=> nil,
          'units_count'=> 0,
          'name'=> fond_rel_name,
          'fond_type'=> fond_type,
          'length'=> fond_length,
          'extent'=> fond_extent,
          'abstract'=> nil,
          'description'=> fond_description,
          'arrangement_note'=> arrangement_note,
          'related_materials'=> nil,
          'access_condition'=> nil,
          'access_condition_note'=> access_condition_note,
          'history' => fond_history,
          'use_condition'=> nil,
          'use_condition_note'=> nil,
          'type_materials'=> nil,
          'preservation'=> nil,
          'preservation_note'=> nil,
          'description_type'=> nil,
          'note'=> nil,
          'legacy_id'=> leg_id_for_children,
          'legacy_parent_id'=> fond_leg_id,
          'published'=> true
        }
      }      
      File.open(TMP_IMPORTS + "/data.json","a") do |file|
        file.write(fond_rel.to_json)
        file.write("\r\n")
      end
  end


def import_zip_file(user, ability)

	@extracted_files.each do |ef|
		if ef.to_s.include? TMP_IMPORTS + "/#{self.id}_ca"
			extract_fond(ef)
		elsif ef.to_s.include? TMP_IMPORTS + "/#{self.id}_data-custodians.xml"
			extract_custodian(ef)
		elsif ef.to_s.include? TMP_IMPORTS + "/#{self.id}_sp"
			extract_creator(ef)
		end
	end

    #extract_fond(zip_data_file)
    #if File.exist?(TMP_IMPORTS + "/#{self.id}_data-creator.xml")
    #  extract_creator(TMP_IMPORTS + "/#{self.id}_data-creator.xml")
    #end
    #if File.exist?(TMP_IMPORTS + "/#{self.id}_data-custodian.xml")
    #  extract_custodian(TMP_IMPORTS + "/#{self.id}_data-custodian.xml")
    #end
    
    #extract_source(TMP_IMPORTS + "/#{self.id}_data-#{custodian}.xml") unless File.exist?(TMP_IMPORTS + "/#{self.id}_data-#{custodian}.xml")
    #begin
    #  case self.importable_type
    #    when /Fond/
    #      extract_fond(zip_data_file)
    #    when /Custodian/
    #      extract_custodian(zip_data_file)
    #    when /Creator/
    #      extract_creator(zip_data_file)
    #    when /Source/
    #      extract_source(zip_data_file)
    #  end
    #end  
    data_file = TMP_IMPORTS + "/data.json"
    begin
      lines = File.readlines(data_file)

      unit_aef_import_units_count = 0

      ActiveRecord::Base.transaction do

        model = nil
        prev_model = nil
        object = nil

        lines.each do |line|
          next if line.blank?
          data = ActiveSupport::JSON.decode(line.strip)
          key = data.keys.first
          ipdata = data[key]

          model = key.camelize.constantize

          ipdata.delete_if{|k, v| not model.column_names.include? k}


          object = model.new(ipdata)

          object.db_source = self.identifier

          if object.has_attribute? 'group_id'
            object.group_id = if user.is_multi_group_user?() then ability.target_group_id else user.rel_user_groups[0].group_id end
          end

          object.created_by = user.id if object.has_attribute? 'created_by'
          object.updated_by = user.id if object.has_attribute? 'updated_by'

          object.sneaky_save!
          if model != prev_model && !prev_model.nil?
            prev_object = prev_model.new
            set_lacking_field_values(prev_object)
          end
          prev_model = model
        end
        if !object.nil?
          set_lacking_field_values(object)
        end
      end
      update_statements_zip
      return true
    rescue Exception => e
      Rails.logger.info "import_zip_file Errore=" + e.message.to_s
      return false
    ensure
    end

  end 
  
#  def import_aef_file(user)
  def import_aef_file(user, ability)
# Upgrade 2.2.0 fine
=begin
    File.open(data_file) do |file|
      begin
        ActiveRecord::Base.transaction do
          lines = file.enum_for(:each_line)
          lines.each do |line|
            next if line.blank?
            data = ActiveSupport::JSON.decode(line.strip)
            key = data.keys.first
            model = key.camelize.constantize
            data[key].delete_if{|k, v| not model.column_names.include? k}
            object = model.new(data[key])
            object.db_source = self.identifier
            object.group_id = user.group_id if object.has_attribute? 'group_id'
            object.created_by = user.id if object.has_attribute? 'created_by'
            object.updated_by = user.id if object.has_attribute? 'updated_by'
            object.send(:create_without_callbacks)
          end
        end
        update_statements
        return true
      rescue
        return false
      ensure
        file.close
      end
    end
=end

    begin
      lines = File.readlines(data_file)
# Upgrade 2.2.0 inizio
      unit_aef_import_units_count = 0
# Upgrade 2.2.0 fine
      ActiveRecord::Base.transaction do
# Upgrade 2.0.0 inizio
        model = nil
        prev_model = nil
        object = nil
# Upgrade 2.0.0 fine
        lines.each do |line|
          next if line.blank?
          data = ActiveSupport::JSON.decode(line.strip)
          key = data.keys.first
# Upgrade 2.1.0 inizio
          ipdata = data[key]
          if imported_file_version < "2.1.0"
            key = prv_adjust_ante_210_project(key, ipdata)
            key = prv_adjust_ante_210_project_credits(key, ipdata)
          end
# Upgrade 2.1.0 fine
          model = key.camelize.constantize
# Upgrade 2.1.0 inizio
#         data[key].delete_if{|k, v| not model.column_names.include? k}
#         object = model.new(data[key])
          ipdata.delete_if{|k, v| not model.column_names.include? k}
          object = model.new(ipdata)
# Upgrade 2.1.0 fine
          object.db_source = self.identifier
# Upgrade 2.2.0 inizio
#         object.group_id = user.group_id if object.has_attribute? 'group_id'
          if object.has_attribute? 'group_id'
            object.group_id = if user.is_multi_group_user?() then ability.target_group_id else user.rel_user_groups[0].group_id end
          end

          if (self.is_unit_aef_file?)
            if (model.to_s == "Unit")
              object.fond_id = self.ref_fond_id
              object.root_fond_id = prv_get_ref_root_fond_id
              unit_aef_import_units_count += 1
            end
          end
# Upgrade 2.2.0 fine
          object.created_by = user.id if object.has_attribute? 'created_by'
          object.updated_by = user.id if object.has_attribute? 'updated_by'

# Upgrade 2.0.0 inizio
#          object.send(:create_without_callbacks)
          object.sneaky_save!
          if model != prev_model && !prev_model.nil?
            prev_object = prev_model.new
            set_lacking_field_values(prev_object)
          end
          prev_model = model
        end
        if !object.nil?
          set_lacking_field_values(object)
        end
# Upgrade 2.0.0 fine
      end
# Upgrade 2.2.0 inizio
#      update_statements
      update_statements(unit_aef_import_units_count)
# Upgrade 2.2.0 fine
      return true
    rescue Exception => e
      Rails.logger.info "import_aef_file Errore=" + e.message.to_s
      return false
    ensure
    end
  end

  def update_statements_zip
    begin
      ActiveRecord::Base.transaction do
        update_fonds_ancestry
        update_one_to_many_relations
        update_many_to_many_relations
        self.importable_id = Fond.find_by_db_source_and_ancestry("#{self.identifier}", nil).id
      end
    end
  end
# Upgrade 2.2.0 inizio
#  def update_statements
  def update_statements(unit_aef_import_units_count)
# Upgrade 2.2.0 fine
    begin
      ActiveRecord::Base.transaction do
# Upgrade 2.2.0 inizio
=begin
        update_fonds_ancestry
        update_units_fond_id
        update_subunits_ancestry if db_has_subunits?
        update_one_to_many_relations
        update_many_to_many_relations
        update_digital_objects if db_has_digital_objects?
=end
        if (self.is_unit_aef_file?)
          units_aef_file_update_tables(unit_aef_import_units_count)
        else
          update_fonds_ancestry
          update_units_fond_id
          update_subunits_ancestry if db_has_subunits?
          update_one_to_many_relations
          update_many_to_many_relations
          update_digital_objects if db_has_digital_objects?
        end
        update_sc2_second_level_relations
# Upgrade 2.2.0 fine
# Upgrade 2.1.0 inizio
    #if imported_file_version < "2.1.0"
# Upgrade 3.0.0 inizio 
        if !imported_file_version.nil? && imported_file_version < "2.1.0"
# Upgrade 3.0.0 fine      
          Import.restore_d_f_s(self.identifier)
          Import.restore_bdm_oa(self.identifier)
        end
# Upgrade 2.1.0 fine

        if self.importable_type == 'Fond'
          self.importable_id = Fond.find_by_db_source_and_ancestry("#{self.identifier}", nil).id
        else
          self.importable_id = self.importable_type.constantize.find_by_db_source("#{self.identifier}").id
        end
      end
    end
  end

# Upgrade 2.0.0 inizio
# assegna created_at, updated_at con la data corrente sul modello object
  def set_lacking_field_values(object)
    current_datetime = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")     # nel db le date sono in utc
    table_name = object.class.table_name.to_s

    sqlSetClause = ""
    sqlWhereClause = "#{table_name}.db_source = '#{self.identifier}'"
    if object.attributes.include? "created_at"
      sqlSetClause = "created_at = '#{current_datetime}'"
      sqlWhereClause = sqlWhereClause + " AND (created_at IS NULL)"
    end
    if object.attributes.include? "updated_at"
      if !sqlSetClause.empty? then sqlSetClause = sqlSetClause + "," end
      sqlSetClause = sqlSetClause + "updated_at = '#{current_datetime}'"
      sqlWhereClause = sqlWhereClause + " AND (updated_at IS NULL)"
    end

    if !sqlSetClause.empty?
      sqlStmt = "UPDATE #{table_name} SET #{sqlSetClause} WHERE #{sqlWhereClause}"
      ar_connection.execute(sqlStmt)
    end
  end
# Upgrade 2.0.0 fine

  def update_fonds_ancestry(parent_id = nil, ancestry = nil)
# Upgrade 2.0.0 inizio
#    Fond.find_each(:conditions => {:legacy_parent_id => parent_id, :db_source => self.identifier}) do |node|
    Fond.where({:legacy_parent_id => parent_id, :db_source => self.identifier}).find_each do |node|
# Upgrade 2.0.0 fine
      node.without_ancestry_callbacks do
        node.update_attribute :ancestry, ancestry
      end
      update_fonds_ancestry node.legacy_id, if ancestry.nil? then "#{node.id}" else "#{ancestry}/#{node.id}" end
    end
  end

# Upgrade 2.2.0 inizio
  def units_aef_file_update_tables(unit_aef_import_units_count)
    # maxsn = max sequence_number di tutte le unità del fondo considerato per l'importazione
    sqlWhereClause = "(fond_id=#{self.ref_fond_id}) AND (root_fond_id=#{prv_get_ref_root_fond_id}) AND (db_source IS NULL OR db_source <> '#{self.identifier}')"
    maxsn = Unit.where(sqlWhereClause).maximum("sequence_number")
    if (maxsn.nil?) then maxsn = 0 end
    
    # maxpos = max position di tutte le unità non sotto-unità o sotto-sotto-unità del fondo considerato per l'importazione
    sqlWhereClause = "(fond_id=#{self.ref_fond_id}) AND (ancestry IS NULL) AND (db_source IS NULL OR db_source <> '#{self.identifier}')"
    maxpos = Unit.where(sqlWhereClause).maximum("position")
    if (maxpos.nil?) then maxpos = 0 end

    # incrementa sequence_number delle unità del fondo radice considerato che avevano sequence_number > maxsn di un numero pari al numero di nuove unità importate (unit_aef_import_units_count) in modo da "fare spazio" nella sequenza alle nuove arrivate
    sqlWhereClause = "(root_fond_id=#{prv_get_ref_root_fond_id}) AND (db_source IS NULL OR db_source <> '#{self.identifier}') AND (sequence_number > #{maxsn})"
    sqlStmt = "UPDATE units SET sequence_number=sequence_number+#{unit_aef_import_units_count} WHERE #{sqlWhereClause}"
    ar_connection.execute(sqlStmt)
    
    # alle nuove unità importate si eseguono i seguenti aggiornamenti:
    # setta sequence_number in modo che si incastrino nella posizione prevista (in coda a quelle del fondo considerato)
    sqlWhereClause = "db_source = '#{self.identifier}'"
    sqlStmt = "UPDATE units SET sequence_number=sequence_number+#{maxsn} WHERE #{sqlWhereClause}"
    ar_connection.execute(sqlStmt)

    update_subunits_ancestry if db_has_subunits?
    
    posindex = maxpos + 1
    prev_ancestry = ""
    prev_ancestry_depth = 0
    sqlWhereClause = "db_source = '#{self.identifier}'"

    Unit.where(sqlWhereClause).order("ancestry_depth, sequence_number").each do |unit|
      ancestry = unit.ancestry
      if (ancestry.nil?) then ancestry = "" end
      ancestry_depth = unit.ancestry_depth
      if (ancestry != prev_ancestry || ancestry_depth != prev_ancestry_depth)
        posindex = 1
      end
      unit.update_column("position", posindex)
    
      posindex += 1
      prev_ancestry = ancestry
      prev_ancestry_depth = ancestry_depth
    end
    
    update_one_to_many_relations
    
    update_digital_objects if db_has_digital_objects?

    # aggiorna l'informazione sul numero di unità collegate al fondo di riferimento
    sqlStmt = "UPDATE fonds SET units_count=units_count+#{unit_aef_import_units_count} WHERE id=#{self.ref_fond_id}"
    ar_connection.execute(sqlStmt)
  end
# Upgrade 2.2.0 fine
  
  def update_units_fond_id
    case adapter
    when 'sqlite'
      ar_connection.execute("UPDATE units
                           SET fond_id = (SELECT fonds.id FROM fonds
                           WHERE units.legacy_parent_fond_id = fonds.legacy_id
                           AND units.db_source = '#{self.identifier}'
                           AND fonds.db_source = '#{self.identifier}')
                           WHERE EXISTS (
                            SELECT * FROM fonds
                            WHERE units.legacy_parent_fond_id = fonds.legacy_id
                            AND units.db_source = '#{self.identifier}'
                            AND fonds.db_source = '#{self.identifier}')")
      ar_connection.execute("UPDATE units
                           SET root_fond_id = (SELECT fonds.id FROM fonds
                           WHERE units.legacy_root_fond_id = fonds.legacy_id
                           AND units.db_source = '#{self.identifier}'
                           AND fonds.db_source = '#{self.identifier}')
                           WHERE EXISTS (
                            SELECT * FROM fonds
                            WHERE units.legacy_root_fond_id = fonds.legacy_id
                            AND units.db_source = '#{self.identifier}'
                            AND fonds.db_source = '#{self.identifier}')")
    when 'mysql', 'mysql2'
      ar_connection.execute("UPDATE units u, fonds f
                           SET u.fond_id = f.id
                           WHERE u.legacy_parent_fond_id = f.legacy_id
                           AND u.db_source = '#{self.identifier}'
                           AND f.db_source = '#{self.identifier}'")

      ar_connection.execute("UPDATE units u, fonds f
                           SET u.root_fond_id = f.id
                           WHERE u.legacy_root_fond_id = f.legacy_id
                           AND u.db_source = '#{self.identifier}'
                           AND f.db_source = '#{self.identifier}'")
    when 'postgresql'
      ar_connection.execute("UPDATE units
                           SET fond_id = f.id
                           FROM fonds f
                           WHERE units.legacy_parent_fond_id = f.legacy_id
                           AND units.db_source = '#{self.identifier}'
                           AND f.db_source = '#{self.identifier}'")

      ar_connection.execute("UPDATE units
                           SET root_fond_id = f.id
                           FROM fonds f
                           WHERE units.legacy_root_fond_id = f.legacy_id
                           AND units.db_source = '#{self.identifier}'
                           AND f.db_source = '#{self.identifier}'")
    end
  end

  def update_subunits_ancestry
    case adapter
    when 'sqlite'
      (1..2).each do |n|
        ancestry = n == 1 ? "id" : "ancestry || '/' || id"
        ar_connection.execute("UPDATE units
                              SET ancestry = (SELECT #{ancestry}
                              FROM units parents
                              WHERE units.db_source = '#{self.identifier}'
                              AND parents.db_source = '#{self.identifier}'
                              AND units.legacy_parent_unit_id = parents.legacy_id
                              AND units.ancestry_depth = #{n})
                              WHERE EXISTS (
                                SELECT * FROM units parents
                                WHERE units.db_source = '#{self.identifier}'
                                AND parents.db_source = '#{self.identifier}'
                                AND units.legacy_parent_unit_id = parents.legacy_id
                                AND units.ancestry_depth = #{n});")
      end
    when 'mysql', 'mysql2'
      (1..2).each do |n|
        ar_connection.execute("UPDATE units u, units parents
                              SET u.ancestry = CONCAT_WS('/', parents.ancestry, CAST(parents.id AS char))
                              WHERE u.db_source = '#{self.identifier}'
                              AND parents.db_source = '#{self.identifier}'
                              AND u.legacy_parent_unit_id = parents.legacy_id
                              AND u.ancestry_depth = #{n};")
      end
    when 'postgresql'
      (1..2).each do |n|
        ar_connection.execute("UPDATE units
                             SET ancestry = CONCAT_WS('/', parents.ancestry, CAST(parents.id AS varchar))
                             FROM units parents
                             WHERE units.db_source = '#{self.identifier}'
                             AND parents.db_source = '#{self.identifier}'
                             AND units.legacy_parent_unit_id = parents.legacy_id
                             AND units.ancestry_depth = #{n};")
      end
    end
  end

  def update_one_to_many_relations
    entities = {
      :fonds => ["fond_events", "fond_identifiers", "fond_langs", "fond_names", "fond_owners", "fond_urls", "fond_editors"],
# Upgrade 2.2.0 inizio
#      :units => ["unit_events", "unit_identifiers", "unit_damages", "unit_langs", "unit_other_reference_numbers", "unit_urls", "unit_editors", "iccd_authors", "iccd_descriptions", "iccd_tech_specs", "iccd_damages", "iccd_subjects"],
      :units => ["unit_events", "unit_identifiers", "unit_damages", "unit_langs", "unit_other_reference_numbers", "unit_urls", "unit_editors", "iccd_authors", "iccd_descriptions", "iccd_tech_specs", "iccd_damages", "iccd_subjects", "sc2s", "sc2_textual_elements", "sc2_visual_elements", "sc2_authors", "sc2_commissions",  "sc2_techniques", "sc2_scales", "fsc_organizations", "fsc_nationalities", "fsc_codes", "fsc_opens", "fsc_closes", "fe_identifications", "fe_contexts", "fe_operas", "fe_designers", "fe_cadastrals", "fe_land_parcels", "fe_fract_land_parcels", "fe_fract_edil_parcels"],
# Upgrade 2.2.0 fine
      :creators => ["creator_events", "creator_identifiers", "creator_legal_statuses", "creator_names", "creator_urls", "creator_activities", "creator_editors"],
      :custodians => ["custodian_buildings", "custodian_contacts", "custodian_identifiers", "custodian_names", "custodian_owners", "custodian_urls", "custodian_editors"],
# Upgrade 2.0.0 inizio
#      :projects => ["project_credits", "project_urls"],
      :projects => ["project_managers", "project_stakeholders", "project_urls"],
# Upgrade 2.0.0 fine
      :sources => ["source_urls"],
      :institutions => ["institution_editors"],
      :document_forms => ["document_form_editors"]
    }

    entities.each do |target, tables|
      target_field = "#{target}".singularize + "_id"
      tables.each do |table|
        case adapter
        when 'sqlite'
          ar_connection.execute("UPDATE #{table} SET #{target_field} = (SELECT id
                                 FROM #{target}
                                 WHERE #{table}.legacy_id = #{target}.legacy_id
                                 AND #{table}.db_source = #{target}.db_source
                                 AND #{target}.db_source = '#{self.identifier}')
                                 WHERE EXISTS (
                                  SELECT * FROM #{target}
                                  WHERE #{table}.legacy_id = #{target}.legacy_id
                                  AND #{table}.db_source = #{target}.db_source
                                  AND #{target}.db_source = '#{self.identifier}')")
        when 'mysql', 'mysql2'
          ar_connection.execute("UPDATE #{table} r, #{target} c SET r.#{target_field} = c.id
                                 WHERE r.legacy_id = c.legacy_id
                                 AND r.db_source = c.db_source
                                 AND c.db_source = '#{self.identifier}'")
        when 'postgresql'
          ar_connection.execute("UPDATE #{table} SET #{target_field} = c.id FROM #{target} c
                                 WHERE #{table}.legacy_id = c.legacy_id
                                 AND #{table}.db_source = c.db_source
                                 AND c.db_source = '#{self.identifier}'")
        end
      end
    end
  end

  def update_many_to_many_relations
    tables = {
      :rel_creator_creators => ["creators", "creators"],
      :rel_creator_fonds => ["creators", "fonds"],
      :rel_creator_institutions => ["creators", "institutions"],
      :rel_creator_sources => ["creators", "sources"],
      :rel_custodian_fonds => ["custodians", "fonds"],
      :rel_custodian_sources => ["custodians", "sources"],
      :rel_fond_document_forms => ["fonds", "document_forms"],
      :rel_fond_headings => ["fonds", "headings"],
      :rel_fond_sources => ["fonds", "sources"],
      :rel_project_fonds => ["projects", "fonds"],
      :rel_unit_headings => ["units", "headings"],
      :rel_unit_sources => ["units", "sources"]
    }

    tables.each do |table, entities|
      first_entity_field = "#{entities[0]}".singularize + "_id"
      first_legacy_entity_field = "legacy_" + "#{entities[0]}".singularize + "_id"

      if entities[0] == entities[1]
        second_entity_field = "related_" + "#{entities[1]}".singularize + "_id"
        second_legacy_entity_field = "legacy_related_" + "#{entities[1]}".singularize + "_id"
      else
        second_entity_field = "#{entities[1]}".singularize + "_id"
        second_legacy_entity_field = "legacy_" + "#{entities[1]}".singularize + "_id"
      end

      case adapter
      when 'sqlite'
        query = "UPDATE #{table}
                 SET #{first_entity_field} = (SELECT id
                 FROM #{entities[0]}
                 WHERE #{table}.#{first_legacy_entity_field} = #{entities[0]}.legacy_id
                 AND #{table}.db_source = '#{self.identifier}'
                 AND #{entities[0]}.db_source = '#{self.identifier}')
                 WHERE EXISTS (
                    SELECT * FROM #{entities[0]}
                    WHERE #{table}.#{first_legacy_entity_field} = #{entities[0]}.legacy_id
                    AND #{table}.db_source = '#{self.identifier}'
                    AND #{entities[0]}.db_source = '#{self.identifier}');"
        ar_connection.execute(query)
      when 'mysql', 'mysql2'
        query = "UPDATE #{table} r, #{entities[0]} c
                 SET r.#{first_entity_field} = c.id
                 WHERE r.#{first_legacy_entity_field} = c.legacy_id
                 AND r.db_source = '#{self.identifier}'
                 AND c.db_source = '#{self.identifier}'"
        ar_connection.execute(query)
      when 'postgresql'
        query = "UPDATE #{table}
                 SET #{first_entity_field} = c.id
                 FROM #{entities[0]} c
                 WHERE #{table}.#{first_legacy_entity_field} = c.legacy_id
                 AND #{table}.db_source = '#{self.identifier}'
                 AND c.db_source = '#{self.identifier}'"
        ar_connection.execute(query)
      end

      case adapter
      when 'sqlite'
        query = "UPDATE #{table}
                 SET #{second_entity_field} = (SELECT id
                 FROM #{entities[1]}
                 WHERE #{table}.#{second_legacy_entity_field} = #{entities[1]}.legacy_id
                 AND #{table}.db_source = '#{self.identifier}'
                 AND #{entities[1]}.db_source = '#{self.identifier}')
                 WHERE EXISTS (
                    SELECT * FROM #{entities[1]}
                    WHERE #{table}.#{second_legacy_entity_field} = #{entities[1]}.legacy_id
                    AND #{table}.db_source = '#{self.identifier}'
                    AND #{entities[1]}.db_source = '#{self.identifier}');"
        ar_connection.execute(query)
      when 'mysql', 'mysql2'
        query = "UPDATE #{table} r, #{entities[1]} c
                 SET r.#{second_entity_field} = c.id
                 WHERE r.#{second_legacy_entity_field} = c.legacy_id
                 AND r.db_source = '#{self.identifier}'
                 AND c.db_source = '#{self.identifier}'"
        ar_connection.execute(query)
      when 'postgresql'
        query = "UPDATE #{table}
                 SET #{second_entity_field} = c.id
                 FROM #{entities[1]} c
                 WHERE #{table}.#{second_legacy_entity_field} = c.legacy_id
                 AND #{table}.db_source = '#{self.identifier}'
                 AND c.db_source = '#{self.identifier}'"
        ar_connection.execute(query)
      end

    end
  end

  def update_digital_objects
    attachable_entities = {
      'Fond' => 'fonds',
      'Unit' => 'units',
      'Creator' => 'creators',
      'Custodian' => 'custodians',
      'Source' => 'sources'
    }

    attachable_entities.each do |value, table|
# Upgrade 2.0.0 inizio
#      set = DigitalObject.all(:conditions => {:attachable_type => value, :db_source => self.identifier})
      set = DigitalObject.where({:attachable_type => value, :db_source => self.identifier})
# Upgrade 2.0.0 fine
      unless set.blank?
        ids = set.map(&:id).join(',')
        case adapter
        when 'sqlite'
          query = "UPDATE digital_objects SET attachable_id = (SELECT id
                   FROM #{table}
                   WHERE digital_objects.legacy_id = #{table}.legacy_id
                   AND digital_objects.db_source = #{table}.db_source
                   AND #{table}.db_source = '#{self.identifier}'
                   AND digital_objects.id IN (#{ids}))
                   WHERE EXISTS (
                    SELECT * FROM #{table}
                    WHERE digital_objects.legacy_id = #{table}.legacy_id
                    AND digital_objects.db_source = #{table}.db_source
                    AND #{table}.db_source = '#{self.identifier}'
                    AND digital_objects.id IN (#{ids}));"
          ar_connection.execute(query)
        when 'mysql', 'mysql2'
          query = "UPDATE digital_objects do, #{table} e SET do.attachable_id = e.id
                   WHERE do.legacy_id = e.legacy_id
                   AND do.db_source = e.db_source
                   AND e.db_source = '#{self.identifier}'
                   AND do.id IN (#{ids})"
          ar_connection.execute(query)
        when 'postgresql'
          query = "UPDATE digital_objects SET attachable_id = e.id
                   FROM #{table} e
                   WHERE digital_objects.legacy_id = e.legacy_id
                   AND digital_objects.db_source = e.db_source
                   AND e.db_source = '#{self.identifier}'
                   AND digital_objects.id IN (#{ids})"
          ar_connection.execute(query)
        end
      end
    end


# Upgrade 3.0.0 inizio
# Copia degli oggetti digitali dall'aef alla destinazione fisica
     Zip::File.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") { |zip_file|
         zip_file.each { |f|
          if (f.name.include? "public") && (f.name.include? "digital_objects")
             f_path=File.join("#{Rails.root}/", f.name)
             FileUtils.mkdir_p(File.dirname(f_path))
             zip_file.extract(f, f_path){ true } unless File.exist?(f_path)   
          end         
       }
      }

# Upgrade 3.0.0 fine


  end

# Upgrade 2.2.0 inizio
  def update_sc2_second_level_relations
    tables =
    [
      {:table => "sc2_attribution_reasons", :parent_table => "sc2_authors", :foreign_key => "sc2_author_id" },
      {:table => "sc2_commission_names", :parent_table => "sc2_commissions", :foreign_key => "sc2_commission_id" }
    ]
    
    tables.each do |settings|
      table = settings[:table]
      parent_table = settings[:parent_table]
      if ((!table.nil? || table != "") && (!parent_table.nil? || parent_table != ""))
        foreign_key = settings[:foreign_key]
        if (foreign_key.nil? || foreign_key == "") then foreign_key = "#{parent_table}".singularize + "_id" end
        case adapter
        when 'sqlite'
          sql_stmt = "UPDATE #{table} SET #{foreign_key} = (SELECT id
                                 FROM #{parent_table}
                                 WHERE #{table}.legacy_id = #{parent_table}.legacy_current_id
                                 AND #{table}.db_source = #{parent_table}.db_source
                                 AND #{parent_table}.db_source = '#{self.identifier}')
                                 WHERE EXISTS (
                                  SELECT * FROM #{parent_table}
                                  WHERE #{table}.legacy_id = #{parent_table}.legacy_current_id
                                  AND #{table}.db_source = #{parent_table}.db_source
                                  AND #{parent_table}.db_source = '#{self.identifier}')"
        when 'mysql', 'mysql2'
          sql_stmt = "UPDATE #{table} r, #{parent_table} c SET r.#{foreign_key} = c.id
                                 WHERE r.legacy_id = c.legacy_current_id
                                 AND r.db_source = c.db_source
                                 AND c.db_source = '#{self.identifier}'"
        when 'postgresql'
          sql_stmt = "UPDATE #{table} SET #{foreign_key} = c.id FROM #{parent_table} c
                                 WHERE #{table}.legacy_id = c.legacy_current_id
                                 AND #{table}.db_source = c.db_source
                                 AND c.db_source = '#{self.identifier}'"
        else
          sql_stmt = ""
        end
        if (sql_stmt != "")
          ar_connection.execute(sql_stmt)
        end
      end
    end
  end
# Upgrade 2.2.0 fine

  def is_valid_file?
    begin
      extension = File.extname(data_file_name).downcase.gsub('.', '')
# Upgrade 3.0.0 inizio     
      raise Zip::ZipInternalError unless ['aef', 'csv', 'zip'].include? extension
      #raise Zip::ZipInternalError unless ['aef', 'csv'].include? extension
         
    rescue Zip::ZipInternalError
      raise 'Il file fornito non è di formato <code>aef</code> o <code>csv</code> o <code>zip</code>'
    end
# Upgrade 3.0.0 fine  
    if ['aef'].include? extension
      files = ["metadata.json", "data.json"]
      begin
  # Upgrade 2.0.0 inizio
  #      Zip::ZipFile.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") do |zipfile|
        Zip::File.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") do |zipfile|
  # Upgrade 2.0.0 fine
  # Upgrade 3.0.0 inizio
  # esclusi dal controllo di validità i file degli oggetti digitali
          zipfile.each do |entry|
            if (entry.directory?) && (entry.to_s.include? "public")
              next
            else
              if (entry.to_s.include? "public")
                next
              else
                raise Zip::ZipEntryNameError unless files.include? entry.to_s
                zipfile.extract(entry, TMP_IMPORTS + "/#{self.id}_#{entry.to_s}")
              end
            end
          end
  # Upgrade 3.0.0 fine
        end
      rescue Zip::ZipInternalError
        raise 'Il file fornito non è di formato <code>aef</code>'
      rescue Zip::ZipEntryNameError
        raise 'Il file fornito contiene dati non validi'
      rescue Zip::ZipCompressionMethodError
        raise 'Il file <code>aef</code> è danneggiato'
      rescue Zip::ZipDestinationFileExistsError
        raise "Errore interno di #{APP_NAME}, <em>stale files</em> nella directory tmp"
      rescue
        raise "Si è verificato un errore nell'elaborazione del file <code>aef</code>"
      end

      File.open(metadata_file) do |file|
        begin
          lines = file.enum_for(:each_line)
          lines.each do |line|
            next if line.blank?
            data = ActiveSupport::JSON.decode(line.strip)
            raise "Controllo di integrità fallito" unless data['checksum'] == Digest::SHA256.file(data_file).hexdigest
            unless AEF_COMPATIBLE_VERSIONS.include?(data['version'])
              aef_version = data['version'].to_s.scan(%r([0-9])).join(".")
              raise "File incompatibile con questa versione di #{APP_NAME} (#{APP_VERSION}).<br>
              Il file <code>aef</code> è stato prodotto con la versione #{aef_version}."
            end
            self.importable_type = data['attached_entity']

            self.imported_file_version = data['version'].to_s.scan(%r([0-9])).join(".")
          end
        rescue Exception => e
          raise e.message
        ensure
          file.close
        end
      end 
    elsif ['zip'].include? extension
      files = ["ca", "custodians", "sp", "sources"]
      @extracted_files = []

      metadata_files = ["metadata.json"]
      begin
  # Upgrade 2.0.0 inizio
  #      Zip::ZipFile.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") do |zipfile|
        Zip::File.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") do |zipfile1|
  # Upgrade 2.0.0 fine
  # Upgrade 3.0.0 inizio
  # esclusi dal controllo di validità i file degli oggetti digitali
          zipfile1.each do |entry1|
            if (entry1.directory?) && (entry1.to_s.include? "public")
              next
            else
              if ((entry1.to_s.include? "public") || (entry1.to_s.include? "ca") || (entry1.to_s.include? "custodians") || (entry1.to_s.include? "sp") || (entry1.to_s.include? "sources"))
                next
              else
                raise Zip::ZipEntryNameError unless metadata_files.include? entry1.to_s
                zipfile1.extract(entry1, TMP_IMPORTS + "/#{self.id}_#{entry1.to_s}")
              end
            end
          end
  # Upgrade 3.0.0 fine
        end
      rescue Zip::ZipInternalError
        raise 'Il file fornito non è di formato <code>zip</code>'
      rescue Zip::ZipEntryNameError
        raise 'Il file fornito contiene dati non validi'
      rescue Zip::ZipCompressionMethodError
        raise 'Il file <code>zip</code> è danneggiato'
      rescue Zip::ZipDestinationFileExistsError
        raise "Errore interno di #{APP_NAME}, <em>stale files</em> nella directory tmp"
      rescue
        raise "Si è verificato un errore nell'elaborazione del file <code>zip</code>"
      end

      File.open(metadata_file) do |file|
        begin
          lines = file.enum_for(:each_line)
          lines.each do |line|
            next if line.blank?
            data = ActiveSupport::JSON.decode(line.strip)
            unless AEF_COMPATIBLE_VERSIONS.include?(data['version'])
              aef_version = data['version'].to_s.scan(%r([0-9])).join(".")
              raise "File incompatibile con questa versione di #{APP_NAME} (#{APP_VERSION}).<br>
              Il file <code>zip</code> è stato prodotto con la versione #{aef_version}."
            end
            self.importable_type = data['attached_entity']

            self.imported_file_version = data['version'].to_s.scan(%r([0-9])).join(".")
          end
        rescue Exception => e
          raise e.message
        ensure
          file.close
        end
      end




      begin
  # Upgrade 2.0.0 inizio
  #      Zip::ZipFile.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") do |zipfile|
        Zip::File.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") do |zipfile|
  # Upgrade 2.0.0 fine
  # Upgrade 3.0.0 inizio
  # esclusi dal controllo di validità i file degli oggetti digitali
          zipfile.each do |entry|
            if (entry.directory?) && (entry.to_s.include? "public")
              next
            else
              if ((entry.to_s.include? "public") || (entry.to_s.include? "metadata"))
                next
              else
              	entry_name = ''
              	entry_array = entry.to_s.split('-')
              	if entry_array[0].include? 'data'
              		entry_secondary_array = entry_array[1].split('.')
              		entry_name = entry_secondary_array[0]
              	else
              		entry_name = entry_array[0]
              	end

                raise Zip::ZipEntryNameError unless files.include? entry_name.to_s
                zipfile.extract(entry, TMP_IMPORTS + "/#{self.id}_#{entry.to_s}")
                @extracted_files.push(TMP_IMPORTS + "/#{self.id}_#{entry.to_s}")
                #self.importable_type = "Fond"
                #case entry.to_s
                #  when /fond/
                #    self.importable_type = "Fond"
                #  when /custodian/
                #    self.importable_type = "Custodian"
                #  when /creator/
                #    self.importable_type = "Creator"
                #  when /source/
                #    self.importable_type = "Source"
                #end
                #self.imported_file_version = APP_VERSION
              end

            end
          end
  # Upgrade 3.0.0 fine
        end
      rescue Zip::ZipInternalError
        raise 'Il file fornito non è di formato <code>zip</code>'
      rescue Zip::ZipEntryNameError
        raise 'Il file fornito contiene dati non validi'
      rescue Zip::ZipCompressionMethodError
        raise 'Il file <code>zip</code> è danneggiato'
      rescue Zip::ZipDestinationFileExistsError
        raise "Errore interno di #{APP_NAME}, <em>stale files</em> nella directory tmp"
      rescue
        raise "Si è verificato un errore nell'elaborazione del file <code>zip</code>"
      end
    else 
      self.importable_type = "Unit"
    end
    # Upgrade 3.0.0 fine
  end

  def wipe_all_related_records
    tables = ar_connection.tables - ["schema_migrations"]
    begin
      ActiveRecord::Base.transaction do
# Upgrade 2.2.0 inizio
        importable_type = Import.where("identifier = '#{self.identifier}'").first.importable_type
        if (importable_type == "Unit")
          # l'idea è decrementare il campo units_count dei fondi che contengono le unità importate che si stanno cancellando.
          # i fondi di interesse potrebbero essere più di uno poiché le unità importate potrebbero essere state ricollocate sotto altri fondi dopo la loro importazione. Si selezionano i fond_id dei fondi coinvolti e per ciascuno il numero di unità di interesse che contiene. tale numero deve essere utilizzato per riassegnare correttamente il campo units_count dei fondi
          sql_stmt = "select fond_id, count(*) as n_units from units where db_source='#{self.identifier}' group by fond_id"
          result = ar_connection.execute(sql_stmt)
          result.each do |r|
            fond_id = r["fond_id"].to_s
            n_units = r["n_units"].to_s
            sql_stmt = "update fonds set units_count=units_count-#{n_units} where id=#{fond_id}"
            ar_connection.execute(sql_stmt)
          end
        end      
# Upgrade 2.2.0 fine
        tables.each do |table|
          model = table.classify.constantize
          object = model.new
          if object.has_attribute? 'db_source'
# Upgrade 3.0.0 inizio
# Vengono eliminati fisicamente gli oggetti digitali precedentemente importati   
# insieme alle cartelle corrispondenti e prima dell'eliminazione dei record corrispondenti su db
            if table.include? "digital_objects"
              digital_object_ids = DigitalObject.where(:db_source => self.identifier).map(&:access_token)
              digital_object_ids.each do |doi|
                delete_digital_folder(doi)
              end
            end
# Upgrade 3.0.0 fine
            model.delete_all("db_source = '#{self.identifier}'")
          end
        end
      end
      return true
    rescue Exception => e
Rails.logger.info "################ Errore=" + e.message
      return false
    end
  end

  private

  # Upgrade 2.2.0 inizio
  def prv_get_ref_root_fond_id
    if self.ref_root_fond_id.nil?
      ref_root_fond_id = self.ref_fond_id
    else
      ref_root_fond_id = self.ref_root_fond_id
    end
    return ref_root_fond_id
  end
# Upgrade 2.2.0 fine
  

  def sanitize_file_name
    extension = File.extname(data_file_name).downcase
    filename = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    self.data.instance_write(:file_name, "#{filename}#{extension}")
  end

  def prv_adjust_ante_210_project(key, ipdata)
    begin
      if key == "project"
        case ipdata["project_type"]
          when "riordino e schedatura"
            ipdata["project_type"] = "riordino"
          when "schedatura"
            ipdata["project_type"] = "recupero"
        end
      end
    rescue Exception => e
    end
    return key
  end

  def prv_adjust_ante_210_project_credits(key, ipdata)
    begin
      if key == "project_credit"
        if ipdata.has_key?("credit_name")
          ipdata["name"] = ipdata.delete("credit_name")
        end

        if ipdata.has_key?("credit_type")
          if ipdata["credit_type"] == "PS"
            if ipdata.has_key?("qualifier")
              case ipdata["qualifier"]
                when "coordinatore"
                  key = "project_stakeholder"
                  ipdata["qualifier"] = "coordinamento operativo"
                when "finanziatore"
                  key = "project_stakeholder"
                  ipdata["qualifier"] = "finanziamento"
                when "promotore"
                  key = "project_stakeholder"
                  ipdata["qualifier"] = "promozione"
                when "realizzatore"
                  key = "project_stakeholder"
                  ipdata["qualifier"] = "realizzazione"
                when "schedatore"
                  key = "project_manager"
                when "responsabile scientifico"
                  key = "project_manager"
# Upgrade 2.1.0 inizio
                else
                  key = "project_stakeholder"
# Upgrade 2.1.0 fine
              end
            end
          else
            # caso ipdata["credit_type"] == "PM" o ipdata["credit_type"] == qualsiasi altro valore
            if ipdata.has_key?("qualifier")
              case ipdata["qualifier"]
                when "coordinatore"
                  key = "project_manager"
                when "finanziatore"
                  key = "project_stakeholder"
                  ipdata["qualifier"] = "finanziamento"
                when "promotore"
                  key = "project_stakeholder"
                  ipdata["qualifier"] = "promozione"
                when "realizzatore"
                  key = "project_stakeholder"
                  ipdata["qualifier"] = "realizzazione"
                when "schedatore"
                  key = "project_manager"
                when "responsabile scientifico"
                  key = "project_manager"
# Upgrade 2.1.0 inizio
                else
                  key = "project_manager"
# Upgrade 2.1.0 fine
              end
            end
          end
        end
      end
    rescue
    end
    return key
  end
end
