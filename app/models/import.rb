class Import < ActiveRecord::Base
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
  def import_csv_file(user, ability)
    begin
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
        lines.each do |line|
          if prev_line.blank?
            elements = line.delete("\n").split(',')
            elem_count > elements.count - 1 ? elem_count = elem_count : elem_count = elements.count - 1
            separator = ","*elem_count
            elem = elements[0].split('_')
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
            model = key.camelize.constantize
            headers = elements.map!{ |element| element.gsub(key + 's_', '') }
            prev_line = "not_blank"
          else
            line = line.delete("\n")
            if (line.include? separator) || (line.blank?)
              prev_line = ""
              next
            else
              values = line.delete("\n").split(',')
              values = values.map!{ |element| element.gsub('""', '') }
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
      Rails.logger.info "import_csv_file Errore=" + e.message.to_s
      return false
    ensure
    end
  end
# Upgrade 3.0.0 fine    

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
#					data[key].delete_if{|k, v| not model.column_names.include? k}
#					object = model.new(data[key])
					ipdata.delete_if{|k, v| not model.column_names.include? k}
					object = model.new(ipdata)
# Upgrade 2.1.0 fine
					object.db_source = self.identifier
# Upgrade 2.2.0 inizio
#					object.group_id = user.group_id if object.has_attribute? 'group_id'
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
    rescue Exception => e
      Rails.logger.info "Errore update statements=" + e.message.to_s
      return false
    ensure
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
      :units => ["unit_events", "unit_identifiers", "unit_damages", "unit_langs", "unit_other_reference_numbers", "unit_urls", "unit_editors", "iccd_authors", "iccd_descriptions", "iccd_tech_specs", "iccd_damages", "iccd_subjects", "sc2s", "sc2_textual_elements", "sc2_visual_elements", "sc2_authors", "sc2_commissions",	"sc2_techniques", "sc2_scales"],
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
    begin
     Zip::File.open("#{Rails.root}/public/imports/#{self.id}/#{self.data_file_name}") { |zip_file|
         zip_file.each { |f|
          if (f.name.include? "public") && (f.name.include? "digital_objects")
             f_path=File.join("#{Rails.root}/", f.name)
             FileUtils.mkdir_p(File.dirname(f_path))
             zip_file.extract(f, f_path){ true } unless File.exist?(f_path)   
          end         
       }
      }
    rescue Exception => e
      Rails.logger.info "Errore apertura file=" + e.message.to_s
      return false
    ensure
    end

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
      raise Zip::ZipInternalError unless ['aef', 'csv'].include? extension
         
    rescue Zip::ZipInternalError
      raise 'Il file fornito non è di formato <code>aef</code> o <code>csv</code>'
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
