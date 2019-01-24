class Export < ActiveRecord::Base
  # See: http://railscasts.com/episodes/193-tableless-model
  # See: http://codetunes.com/2008/07/20/tableless-models-in-rails
# Upgrade 2.0.0 inizio
#  require 'zip/zip'
# nella versione rubyzip-1.1.6 zip.rb non è nella sottocartella zip dove invece era nella rubyzip-0.9.9 usata prima
  require 'zip'
  require 'builder'
# Upgrade 2.0.0 fine

  TMP_EXPORTS = "#{Rails.root}/tmp/exports"

  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :metadata_file, :string
  column :data_file, :string
  column :dest_file, :string
  column :target_id, :integer
  column :target_class, :string
  column :mode, :string
  column :group_id, :integer
  column :inc_digit, :boolean

# Upgrade 2.0.0 inizio
#  attr_accessor :fond_ids, :unit_ids, :creator_ids, :custodian_ids, :document_form_ids, :project_ids, :institution_ids, :source_ids, :group_id
  attr_accessor :fond_ids, :unit_ids, :creator_ids, :custodian_ids, :document_form_ids, :project_ids, :institution_ids, :source_ids, :group_id, :metadata_file, :data_file, :dest_file, :target_id, :target_class, :mode, :inc_digit
# Upgrade 2.0.0 fine

  def tables
    {
      :fonds => ["fond_events", "fond_identifiers", "fond_langs", "fond_names", "fond_owners", "fond_urls", "fond_editors"],
# Upgrade 2.2.0 inizio
#      :units => ["unit_events", "unit_identifiers", "unit_damages", "unit_langs", "unit_other_reference_numbers", "unit_urls", "unit_editors", "iccd_authors", "iccd_descriptions", "iccd_tech_specs", "iccd_damages", "iccd_subjects"],
      :units => ["unit_events", "unit_identifiers", "unit_damages", "unit_langs", "unit_other_reference_numbers", "unit_urls", "unit_editors", "iccd_authors", "iccd_descriptions", "iccd_tech_specs", "iccd_damages", "iccd_subjects", "sc2s", "sc2_textual_elements", "sc2_visual_elements", "sc2_authors", "sc2_commissions", "sc2_techniques", "sc2_scales", "fsc_organizations", "fsc_nationalities", "fsc_codes", "fsc_opens", "fsc_closes",  "fe_identifications", "fe_contexts", "fe_operas", "fe_designers", "fe_cadastrals", "fe_land_parcels", "fe_fract_land_parcels", "fe_fract_edil_parcels"],
# Upgrade 2.2.0 fine
      :creators => ["creator_events", "creator_identifiers","creator_legal_statuses", "creator_names", "creator_urls", "creator_activities", "creator_editors"],
      :custodians => ["custodian_buildings", "custodian_contacts","custodian_identifiers", "custodian_names", "custodian_owners", "custodian_urls", "custodian_editors"],
# Upgrade 2.0.0 inizio
#      :projects => ["project_credits", "project_urls"],
      :projects => ["project_managers", "project_stakeholders", "project_urls"],
# Upgrade 2.0.0 fine
      :sources => ["source_urls"],
      :institutions => ["institution_editors"],
      :headings => [],
      :editors => [],
      :document_forms => ["document_form_editors"],
      :digital_objects => []
    }
  end

  def fonds_and_units
    self.unit_ids = Array.new
    self.fond_ids = @fond_ids.map(&:id).join(',')
# Upgrade 2.0.0 inizio
#    fonds = Fond.all(:conditions => "id IN (#{self.fond_ids})", :include => [:units], :order => "sequence_number")
    fonds = Fond.where("id IN (#{self.fond_ids})").includes([:units]).order("sequence_number")
# Upgrade 2.0.0 fine

    File.open(self.data_file, "a") do |file|
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
          self.unit_ids.push(unit.id)
        end
      end

      unless self.fond_ids.empty?
        self.tables[:fonds].each do |table|
          model = table.singularize.camelize.constantize
# Upgrade 2.0.0 inizio
#          set = model.all(:conditions => "fond_id IN (#{self.fond_ids})")
          set = model.where("fond_id IN (#{self.fond_ids})")
# Upgrade 2.0.0 fine
          set.each do |e|
            e.legacy_id = e.fond_id
            file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
            file.write("\r\n")
          end
        end
      end

# Upgrade 2.2.0 inizio
=begin
      #TODO considerare each_slice su unit_ids per grandi quantitativi di unità (+query ma meno memoria).
      unless self.unit_ids.empty?
        self.tables[:units].each do |table|
          model = table.singularize.camelize.constantize
# Upgrade 2.0.0 inizio
#          set = model.all(:conditions => "unit_id IN (#{self.unit_ids.join(',')})")
          set = model.where("unit_id IN (#{self.unit_ids.join(',')})")
# Upgrade 2.0.0 fine
          set.each do |e|
            e.legacy_id = e.unit_id
            file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
            file.write("\r\n")
          end
        end
      end
=end
      export_units_related_entities(file, self.unit_ids, self.tables[:units])
# Upgrade 2.2.0 fine
    end
  end

  def major_entities
    entities = ['creator', 'custodian', 'project']
    File.open(self.data_file, "a") do |file|
      entities.each do |entity|
        container = Array.new
        relation = "rel_#{entity}_fond".camelize.constantize
        model = entity.camelize.constantize
        index = entity.pluralize.to_sym

# Upgrade 2.0.0 inizio
#        set = relation.all(:conditions => "fond_id IN (#{self.fond_ids})")
        set = relation.where("fond_id IN (#{self.fond_ids})")
# Upgrade 2.0.0 fine
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
# Upgrade 2.0.0 inizio
#            set = RelCreatorCreator.all(:conditions => "creator_id IN (#{direct_creators}) OR related_creator_id IN (#{direct_creators})")
            set = RelCreatorCreator.where("creator_id IN (#{direct_creators}) OR related_creator_id IN (#{direct_creators})")
# Upgrade 2.0.0 fine
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
# Upgrade 2.0.0 inizio
#          set = model.all(:conditions => "id IN (#{ids})")
          set = model.where("id IN (#{ids})")
# Upgrade 2.0.0 fine
          set.each do |ent|
            ent.legacy_id = ent.id
            file.write(ent.to_json(:except => [:id, :group_id, :db_source, :created_by, :updated_by, :created_at, :updated_at]))
            file.write("\r\n")
          end

          self.tables[index].each do |table|
            attached_model = table.singularize.camelize.constantize
# Upgrade 2.0.0 inizio
#            set = attached_model.all(:conditions => "#{entity}_id IN (#{ids})")
            set = attached_model.where("#{entity}_id IN (#{ids})")
# Upgrade 2.0.0 fine
            set.each do |e|
              e.legacy_id = e.send("#{entity}_id")
              file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
              file.write("\r\n")
            end
          end
        end
        self.send("#{entity}_ids=", container.uniq)
      end
    end
  end

  def institutions
    i = Array.new
    unless self.creator_ids.blank?
      File.open(self.data_file, "a") do |file|
# Upgrade 2.0.0 inizio
#        set = RelCreatorInstitution.all(:conditions => "creator_id IN (#{self.creator_ids.join(',')})")
        set = RelCreatorInstitution.where("creator_id IN (#{self.creator_ids.join(',')})")
# Upgrade 2.0.0 fine
        set.each do |rel|
          rel.legacy_creator_id = rel.creator_id
          rel.legacy_institution_id = rel.institution_id
          file.write(rel.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
          file.write("\r\n")
          i.push(rel.institution_id)
        end

        self.institution_ids = i.uniq
        unless self.institution_ids.blank?
# Upgrade 2.0.0 inizio
#          set = Institution.all(:conditions => "id IN (#{self.institution_ids.join(',')})")
          set = Institution.where("id IN (#{self.institution_ids.join(',')})")
# Upgrade 2.0.0 fine
          set.each do |institution|
            institution.legacy_id = institution.id
            file.write(institution.to_json(:except => [:id, :db_source, :group_id, :created_by, :updated_by, :created_at, :updated_at]))
            file.write("\r\n")
          end

          self.tables[:institutions].each do |table|
            model = table.singularize.camelize.constantize
# Upgrade 2.0.0 inizio
#            set = model.all(:conditions => "institution_id IN (#{self.institution_ids.join(',')})")
            set = model.where("institution_id IN (#{self.institution_ids.join(',')})")
# Upgrade 2.0.0 fine
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

  def headings
    entities = ['fond', 'unit']
    container = Array.new

    File.open(self.data_file, "a") do |file|
      entities.each do |entity|
        relation = "rel_#{entity}_heading".camelize.constantize
        ids = self.send("#{entity}_ids")
        ids = ids.join(',') unless entity == 'fond'
        unless ids.blank?
# Upgrade 2.0.0 inizio
#          set = relation.all(:conditions => "#{entity}_id IN (#{ids})")
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
# Upgrade 2.0.0 inizio
#        set = Heading.all(:conditions => "id IN (#{headings.join(',')})")
        set = Heading.where("id IN (#{headings.join(',')})")
# Upgrade 2.0.0 fine
        set.each do |heading|
          heading.legacy_id = heading.id
          file.write(heading.to_json(:except => [:id, :db_source, :group_id, :created_at, :updated_at]))
          file.write("\r\n")
        end
      end
    end
  end

  def document_forms
    df = Array.new
    File.open(self.data_file, "a") do |file|
# Upgrade 2.0.0 inizio
#      set = RelFondDocumentForm.all(:conditions => "fond_id IN (#{self.fond_ids})")
      set = RelFondDocumentForm.where("fond_id IN (#{self.fond_ids})")
# Upgrade 2.0.0 fine
      set.each do |rel|
        rel.legacy_fond_id = rel.fond_id
        rel.legacy_document_form_id = rel.document_form_id
        file.write(rel.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
        file.write("\r\n")
        df.push(rel.document_form_id)
      end

      self.document_form_ids = df.uniq
      unless self.document_form_ids.blank?
# Upgrade 2.0.0 inizio
#        set = DocumentForm.all(:conditions => "id IN (#{self.document_form_ids.join(',')})")
        set = DocumentForm.where("id IN (#{self.document_form_ids.join(',')})")
# Upgrade 2.0.0 fine
        set.each do |document_form|
          document_form.legacy_id = document_form.id
          file.write(document_form.to_json(:except => [:id, :db_source, :created_by, :updated_by, :group_id, :created_at, :updated_at]))
          file.write("\r\n")
        end

        self.tables[:document_forms].each do |table|
          model = table.singularize.camelize.constantize
# Upgrade 2.0.0 inizio
#          set = model.all(:conditions => "document_form_id IN (#{self.document_form_ids.join(',')})")
          set = model.where("document_form_id IN (#{self.document_form_ids.join(',')})")
# Upgrade 2.0.0 fine
          set.each do |e|
            e.legacy_id = e.document_form_id
            file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
            file.write("\r\n")
          end
        end
      end
    end
  end

  def sources
    entities = ['creator', 'custodian', 'fond', 'unit']
    container = Array.new

    File.open(self.data_file, "a") do |file|
      entities.each do |entity|
        relation = "rel_#{entity}_source".camelize.constantize
        ids = self.send("#{entity}_ids")
        ids = ids.join(',') unless entity == 'fond'
        unless ids.blank?
# Upgrade 2.0.0 inizio
#          set = relation.all(:conditions => "#{entity}_id IN (#{ids})")
          set = relation.where("#{entity}_id IN (#{ids})")
# Upgrade 2.0.0 fine
          set.each do |rel|
            rel.send("legacy_#{entity}_id=", rel.send("#{entity}_id"))
            rel.legacy_source_id = rel.source_id
            file.write(rel.to_json(:except => [:id, :db_source, :source_id, "#{entity}_id".to_sym, :created_at, :updated_at]))
            file.write("\r\n")
            container.push(rel.source_id)
          end
        end
      end

      self.source_ids = container.uniq
      unless self.source_ids.blank?
# Upgrade 2.0.0 inizio
#        set = Source.all(:conditions => "id IN (#{self.source_ids.join(',')})")
        set = Source.where("id IN (#{self.source_ids.join(',')})")
# Upgrade 2.0.0 fine
        set.each do |source|
          source.legacy_id = source.id
          file.write(source.to_json(:except => [:id, :db_source, :created_by, :updated_by, :group_id, :created_at, :updated_at]))
          file.write("\r\n")
        end

        self.tables[:sources].each do |table|
          model = table.singularize.camelize.constantize
# Upgrade 2.0.0 inizio
#          set = model.all(:conditions => "source_id IN (#{self.source_ids.join(',')})")
          set = model.where("source_id IN (#{self.source_ids.join(',')})")
# Upgrade 2.0.0 fine
          set.each do |e|
            e.legacy_id = e.source_id
            file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
            file.write("\r\n")
          end
        end
      end
    end
  end

  def editors
    File.open(self.data_file, "a") do |file|
# Upgrade 2.0.0 inizio
#      set = Editor.all(:conditions => "group_id = #{self.group_id}")
      set = Editor.where("group_id = #{self.group_id}")
# Upgrade 2.0.0 fine
      set.each do |editor|
        editor.legacy_id = editor.id
        file.write(editor.to_json(:except => [:id, :db_source, :group_id, :created_at, :updated_at]))
        file.write("\r\n")
      end
    end
  end

  def digital_objects
    entities = {
      'Fond' => self.fond_ids,
      'Unit' => self.unit_ids,
      'Creator' => self.creator_ids,
      'Custodian' => self.custodian_ids,
      'Source' => self.source_ids
    }
    File.open(self.data_file, "a") do |file|
      entities.each do |type, ids|
# Upgrade 2.2.0 inizio
=begin
        unless ids.blank?
          ids = ids.join(',') unless type == 'Fond'
# Upgrade 2.0.0 inizio
#          set = DigitalObject.all(:conditions => "attachable_id IN (#{ids}) AND attachable_type = '#{type}'")
          set = DigitalObject.where("attachable_id IN (#{ids}) AND attachable_type = '#{type}'")
# Upgrade 2.0.0 fine
          set.each do |digital_object|
            digital_object.legacy_id = digital_object.attachable_id
            file.write(digital_object.to_json(:except => [:id, :group_id, :db_source, :created_by, :updated_by, :created_at, :updated_at]))
            file.write("\r\n")
          end
        end
=end
        export_entity_related_digital_objects(file, type, ids)
# Upgrade 2.2.0 fine
      end
    end
  end

  def create_export_xml_ead_file
    @data_names = Array.new
    if self.mode == 'full'
      case self.target_class
        when "fond"
          set_fonds(self.target_id)
          stream_ead(@fonds, self.target_id)
          related_to_eadfond
        when "custodian"
          set_custodians(self.target_id)
          stream_ead(@custodians, self.target_id)
          related_to_eadcustodian
        when "creator"
          set_ead_creators(self.target_id)
          @rel_ead_creator_ids.each do |reci|
            intreci = [reci.to_i]
            @creators = Creator.where("id = ?", intreci).sort_by { |u| intreci.index(u.id) }
            stream_ead(@creators, selected_fond_ids)
          end 
          related_to_eadcreator
        when "source"
          set_sources(self.target_id)
          stream_ead(@sources, self.target_id)
          related_to_eadsource
        else
          Rails.logger.info("scelto altro")
      end
    else
      case self.target_class
        when "fond"
          set_fonds(self.target_id)
          stream_ead(@fonds, self.target_id)
        when "custodian"
          set_custodians(self.target_id)
          stream_ead(@custodians, self.target_id)
        when "creator"
          set_ead_creators(self.target_id)
          @rel_ead_creator_ids.each do |reci|
            intreci = [reci.to_i]
            @creators = Creator.where("id = ?", intreci).sort_by { |u| intreci.index(u.id) }
            stream_ead(@creators, selected_fond_ids)
          end 
        when "source"
          set_sources(self.target_id)
          stream_ead(@sources, self.target_id)
        else
          Rails.logger.info("scelto altro")
      end
    end

    create_xml_ead_export_file
  end
  
  def create_export_xml_san_file
    @data_names = Array.new
    if self.mode == 'full'
      case self.target_class
        when "fond"
          set_fonds(self.target_id)
          stream(@fonds, self.target_id)
          if self.inc_digit == 'true'
            set_units(self.target_id)
            stream_mets(@units)
          end
          related_to_fond
        when "custodian"
          set_custodians(self.target_id)
          stream(@custodians, self.target_id)
          related_to_custodian
        when "creator"
          set_creators(self.target_id)
          stream(@creators, selected_fond_ids)
          related_to_creator
        when "source"
          set_sources(self.target_id)
          stream(@sources, self.target_id)
          related_to_source
        else
          Rails.logger.info("scelto altro")
      end
    else
      case self.target_class
        when "fond"
          set_fonds(self.target_id)
          stream(@fonds, self.target_id)
          if self.inc_digit == 'true'
            set_units(self.target_id)
            stream_mets(@units)
          end
        when "custodian"
          set_custodians(self.target_id)
          stream(@custodians, self.target_id)
        when "creator"
          set_creators(self.target_id)
          stream(@creators, selected_fond_ids)
        when "source"
          set_sources(self.target_id)
          stream(@sources, self.target_id)
        else
          Rails.logger.info("scelto altro")
      end
    end

    create_xml_export_file
  end

  def related_to_fond
    custodians = RelCustodianFond.where("fond_id IN (#{self.target_id})")
    custodians.each do |c|
      set_custodians(c.custodian_id)
      stream(@custodians, self.target_id)
    end
    set_fond_creators(self.target_id)
    stream(@creators, selected_fond_ids)
    fond_sources = Fond.find(self.target_id)
    sources = fond_sources.sources.where("source_type_code = 2")
    stream(sources, self.target_id)
  end

  def related_to_eadfond
    custodians = RelCustodianFond.where("fond_id IN (#{self.target_id})")
    custodians.each do |c|
      set_custodians(c.custodian_id)
      stream_ead(@custodians, self.target_id)
    end
    set_ead_fond_creators(self.target_id)
    @rel_ead_creator_ids.each do |reci|
      intreci = [reci.to_i]
      @creators = Creator.where("id = ?", intreci).sort_by { |u| intreci.index(u.id) }
      stream_ead(@creators, selected_fond_ids)
    end  
    
    fond_sources = Fond.find(self.target_id)
    sources = fond_sources.sources.where("source_type_code = 2")
    stream_ead(sources, self.target_id)
  end

  def related_to_source
    source = Source.find(self.target_id)
    source_fonds_ids = source.fond_ids
    set_fonds(source_fonds_ids)
    stream(@fonds, source_fonds_ids)
    if self.inc_digit == 'true'
      set_units(source_fonds_ids)
      stream_mets(@units)
    end
  end

  def related_to_eadsource
    source = Source.find(self.target_id)
    source_fonds_ids = source.fond_ids
    source_fonds_ids.each do |sfi|
      intsfi = [sfi.to_i]
      @fonds = Fond.where("id IN (?) AND trashed = 0", intsfi).sort_by { |u| intsfi.index(u.id) }
      stream_ead(@fonds, sfi)
    end  
  end

  def related_to_creator
    creator = Creator.find(self.target_id)
    c_fond_ids = creator.fond_ids
    creator_root_fond_ids = c_fond_ids & selected_fond_ids
    set_fonds(creator_root_fond_ids)
    stream(@fonds, creator_root_fond_ids)
    if self.inc_digit == 'true'
      set_units(creator_root_fond_ids)
      stream_mets(@units)
    end
    custodian_ids = RelCustodianFond.where("fond_id IN (?)", creator_root_fond_ids).map(&:custodian_id).uniq
    custodians = Custodian.where("id IN (?)", custodian_ids).sort_by { |u| custodian_ids.index(u.id) }
    stream(custodians, self.target_id)
    fond_source_ids = Array.new
    creator_root_fond_ids.each do |crfi|
      fond_sources = Fond.find(crfi)
      sources_ids = fond_sources.sources.where("source_type_code = 2").map(&:id)
      fond_source_ids = (fond_source_ids + sources_ids).uniq
    end
    sources = Source.where("id IN (?)", fond_source_ids).sort_by { |u| fond_source_ids.index(u.id) }
    stream(sources, self.target_id)
  end

  def related_to_eadcreator
    creator = Creator.find(self.target_id)
    c_fond_ids = creator.fond_ids
    creator_root_fond_ids = c_fond_ids & selected_fond_ids
    creator_root_fond_ids.each do |crfi|
      intcrfi = [crfi.to_i]
      @fonds = Fond.where("id IN (?) AND trashed = 0", intcrfi).sort_by { |u| intcrfi.index(u.id) }
      stream_ead(@fonds, crfi)
    end  
    custodian_ids = RelCustodianFond.where("fond_id IN (?)", creator_root_fond_ids).map(&:custodian_id).uniq
    custodians = Custodian.where("id IN (?)", custodian_ids).sort_by { |u| custodian_ids.index(u.id) }
    stream_ead(custodians, self.target_id)
    fond_source_ids = Array.new
    creator_root_fond_ids.each do |crfi|
      fond_sources = Fond.find(crfi)
      sources_ids = fond_sources.sources.where("source_type_code = 2").map(&:id)
      fond_source_ids = (fond_source_ids + sources_ids).uniq
    end
    sources = Source.where("id IN (?)", fond_source_ids).sort_by { |u| fond_source_ids.index(u.id) }
    stream_ead(sources, self.target_id)
  end

  def related_to_custodian
    custodian = Custodian.find(self.target_id)
    custodian_fonds_ids = custodian.fond_ids
    set_fonds(custodian_fonds_ids)
    stream(@fonds, custodian_fonds_ids)
    if self.inc_digit == 'true'
      set_units(custodian_fonds_ids)
      stream_mets(@units)
    end
    set_custodian_fonds_creators(custodian_fonds_ids)
    stream(@creators, selected_fond_ids)
    fond_source_ids = Array.new
    custodian_fonds_ids.each do |cfi|
      fond_sources = Fond.find(cfi)
      sources_ids = fond_sources.sources.where("source_type_code = 2").map(&:id)
      fond_source_ids = (fond_source_ids + sources_ids).uniq
    end
    sources = Source.where("id IN (?)", fond_source_ids).sort_by { |u| fond_source_ids.index(u.id) }
    stream(sources, self.target_id)
  end

  def related_to_eadcustodian
    custodian = Custodian.find(self.target_id)
    custodian_fonds_ids = custodian.fond_ids
    custodian_fonds_ids.each do |cfi|
      intcfi = [cfi.to_i]
      @fonds = Fond.where("id IN (?) AND trashed = 0", intcfi).sort_by { |u| intcfi.index(u.id) }
      stream_ead(@fonds, cfi)
    end  
    set_ead_custodian_fonds_creators(custodian_fonds_ids)
    @rel_ead_creator_ids.each do |reci|
      intreci = [reci.to_i]
      @creators = Creator.where("id = ?", intreci).sort_by { |u| intreci.index(u.id) }
      stream_ead(@creators, selected_fond_ids)
    end  
    fond_source_ids = Array.new
    custodian_fonds_ids.each do |cfi|
      fond_sources = Fond.find(cfi)
      sources_ids = fond_sources.sources.where("source_type_code = 2").map(&:id)
      fond_source_ids = (fond_source_ids + sources_ids).uniq
    end
    sources = Source.where("id IN (?)", fond_source_ids).sort_by { |u| fond_source_ids.index(u.id) }
    stream_ead(sources, self.target_id)
  end

  def views_path(record)
    File.join(File.dirname(__FILE__), "..", "views", record)
  end

  def set_units(id)
    @units = Unit.where("id IN (?) AND root_fond_id IN (?)", DigitalObject.distinct.select(:attachable_id).where("attachable_type = 'Unit' AND asset_content_type LIKE 'image%'"), id).order(:sequence_number)
  end

  def set_fonds(id)
    @fonds = Fond.where('id IN (?) AND trashed = 0', id)
    id.kind_of?(Array) ? fond_ids = id : fond_ids = [id.to_i]
  end

  def set_fond_creators(f_id)
      fond_creator_ids = Array.new
      fond = Fond.find(f_id)
      fond_creator_ids = (fond_creator_ids + fond.creator_ids).uniq
      creators = Creator.find(fond_creator_ids).sort_by { |u| fond_creator_ids.index(u.id) }
      fond_creator_creator_ids = Array.new
      creators.each do |c|
        fond_creator_creator_ids = (fond_creator_creator_ids + c.related_creator_ids).uniq
      end
      rel_creator_ids = (fond_creator_ids + fond_creator_creator_ids).uniq
      @creators = Creator.where("id IN (?)", rel_creator_ids).sort_by { |u| rel_creator_ids.index(u.id) }
  end

  def set_ead_fond_creators(f_id)
      fond_creator_ids = Array.new
      fond = Fond.find(f_id)
      fond_creator_ids = (fond_creator_ids + fond.creator_ids).uniq
      creators = Creator.find(fond_creator_ids).sort_by { |u| fond_creator_ids.index(u.id) }
      fond_creator_creator_ids = Array.new
      creators.each do |c|
        fond_creator_creator_ids = (fond_creator_creator_ids + c.related_creator_ids).uniq
      end
      @rel_ead_creator_ids = (fond_creator_ids + fond_creator_creator_ids).uniq
  end

  def set_ead_custodian_fonds_creators(c_ids)
    fond_creator_ids = Array.new
    c_ids.each do |cfi|
      cust_fond = Fond.find(cfi)
      fond_creator_ids = (fond_creator_ids + cust_fond.creator_ids).uniq
    end
    creators = Creator.find(fond_creator_ids).sort_by { |u| fond_creator_ids.index(u.id) }
    custodian_fond_creator_ids = Array.new
    creators.each do |c|
      custodian_fond_creator_ids = (custodian_fond_creator_ids + c.related_creator_ids).uniq
    end
    @rel_ead_creator_ids = (fond_creator_ids + custodian_fond_creator_ids).uniq
  end

  def set_custodian_fonds_creators(c_ids)
    fond_creator_ids = Array.new
    c_ids.each do |cfi|
      cust_fond = Fond.find(cfi)
      fond_creator_ids = (fond_creator_ids + cust_fond.creator_ids).uniq
    end
    creators = Creator.find(fond_creator_ids).sort_by { |u| fond_creator_ids.index(u.id) }
    custodian_fond_creator_ids = Array.new
    creators.each do |c|
      custodian_fond_creator_ids = (custodian_fond_creator_ids + c.related_creator_ids).uniq
    end
    rel_creator_ids = (fond_creator_ids + custodian_fond_creator_ids).uniq
    @creators = Creator.where("id IN (?)", rel_creator_ids).sort_by { |u| rel_creator_ids.index(u.id) }
  end

  def set_ead_creators(id)
    creator = Creator.find("#{id}")
    rel_creator_ids = creator.related_creator_ids
    @rel_ead_creator_ids = [id.to_i] + rel_creator_ids
  end

  def set_creators(id)
    creator = Creator.find("#{id}")
    rel_creator_ids = creator.related_creator_ids
    ids = [id.to_i] + rel_creator_ids
    @creators = Creator.where("id IN (?)", ids).sort_by { |u| ids.index(u.id) }
  end

  def set_custodians(id)
    @custodians = Custodian.where("id = #{id}")
    custodian_ids = [id.to_i]
  end

  def set_sources(id)
    @sources = Source.where("id = #{id}")
    source_ids = [id.to_i]
  end

  def set_all_fonds
    @fonds = Fond.roots.order(:name).all
  end

  def selected_fond_ids
    set_all_fonds
    fond_ids = @fonds.map(&:id)
  end
  
  def stream_ead(records, ids = [])
    if records.present?
      
      suffix = Time.now.strftime("%Y%m%d%H%M%S")
      file = "#{records[0].class.name.tableize}_ead.xml"
      view = ActionView::Base.new(views_path(records[0].class.name.tableize))
      if records[0].class.name.tableize == 'creators'
        data_file_name = TMP_EXPORTS + "/sp-#{records[0].id}-#{suffix}.xml"
      elsif records[0].class.name.tableize == 'fonds'
        data_file_name = TMP_EXPORTS + "/ca-#{records[0].id}-#{suffix}.xml"
      elsif records[0].class.name.tableize == 'custodians'
        data_file_name = TMP_EXPORTS + "/sc-#{records[0].id}-#{suffix}.xml"
      else
        data_file_name = TMP_EXPORTS + "/data-#{records[0].class.name.tableize}-#{suffix}.xml"
      end

      self.data_file = data_file_name
      @data_names.push(data_file_name)
      file_dest = File.new(data_file_name, 'w+')

      xml = ::Builder::XmlMarkup.new(target: file_dest, :indent => 2)

      xml =  view.render(:partial => "#{file}.builder", :locals => {:records => records, :fond_ids => ids})
      File.open(file_dest, 'w+') { |f| f.write(xml) }
    else
      puts "Nessun risultato"
    end
  end

  def stream(records, fond_ids = [])
    if records.present?
      eval File.read('/usr/local/webapps/archimista/tmp/Configurazione_dl.rb')
      dl_metadata = {'DL_FOND_ID' => DL_FOND_ID, 'PROVIDER_DL' => PROVIDER_DL, 
                    'DL_HACONSERVATORE' => DL_HACONSERVATORE, 'DL_REPOSITORYID' => DL_REPOSITORYID,
                    'DL_ABBR' => DL_ABBR, 'DL_CORPNAME' => DL_CORPNAME,
                    'DL_HAPROGETTO' => DL_HAPROGETTO, 'DL_HACOMPLESSO' => DL_HACOMPLESSO,
                    'DL_UNITID' => DL_UNITID, 'DL_UNITTITLE' => DL_UNITTITLE
                  }

      suffix = Time.now.strftime("%Y%m%d%H%M%S")
      file = "#{records[0].class.name.tableize}.xml"
      view = ActionView::Base.new(views_path(records[0].class.name.tableize))
      
      #file_dest = File.new(self.data_file, 'w+')
      data_file_name = TMP_EXPORTS + "/data-#{records[0].class.name.tableize}-#{suffix}.xml"

      self.data_file = data_file_name
      @data_names.push(data_file_name)
      file_dest = File.new(data_file_name, 'w+')
      xml = ::Builder::XmlMarkup.new(target: file_dest, :indent => 2)

      xml =  view.render(:partial => "#{file}.builder", :locals => {:records => records, :fond_ids => fond_ids, :metadata => dl_metadata})
      File.open(file_dest, 'w+') { |f| f.write(xml) }
    else
      puts "Nessun risultato"
    end
  end

  def stream_mets(records)
    if records.present?
      eval File.read('/usr/local/webapps/archimista/tmp/Configurazione_dl.rb')
      dl_metadata = {'DL_FOND_ID' => DL_FOND_ID, 'PROVIDER_DL' => PROVIDER_DL, 
                    'DL_HACONSERVATORE' => DL_HACONSERVATORE, 'DL_REPOSITORYID' => DL_REPOSITORYID,
                    'DL_ABBR' => DL_ABBR, 'DL_CORPNAME' => DL_CORPNAME,
                    'DL_HAPROGETTO' => DL_HAPROGETTO, 'DL_HACOMPLESSO' => DL_HACOMPLESSO,
                    'DL_UNITID' => DL_UNITID, 'DL_UNITTITLE' => DL_UNITTITLE
                  }

      file = "digital_objects.xml"
      file_mets = TMP_EXPORTS + "/digital_objects_CL.xml"
      @data_names.push(file_mets)
      view = ActionView::Base.new(views_path("digital_objects"))

      file_dest_mets = File.new(file_mets, 'w+')
      xml_mets = ::Builder::XmlMarkup.new(target: file_dest_mets, :indent => 2)

      xml_mets =  view.render(:partial => "#{file}.builder", :locals => {:records => records, :metadata => dl_metadata})
      File.open(file_dest_mets, 'w+') { |f| f.write(xml_mets) }
    else
      puts "Nessun risultato"
    end
  end

  def create_export_file
    create_data_file
    create_metadata_file
# Upgrade 2.2.0 inizio
=begin
    files = {"metadata.json" => self.metadata_file, "data.json" => self.data_file}
# Upgrade 2.0.0 inizio
#    Zip::ZipFile.open(self.dest_file, Zip::ZipFile::CREATE) do |zipfile|
    Zip::File.open(self.dest_file, Zip::File::CREATE) do |zipfile|
# Upgrade 2.0.0 fine
      files.each do |dst, src|
        zipfile.add(dst, src)
      end
    end
=end
    create_aef_file
# Upgrade 2.2.0 fine
  end

  def create_xml_export_file
    create_metadata_file
    create_aef_for_xml_file
  end

  def create_xml_ead_export_file
    create_metadata_file
    create_aef_for_xml_ead_file
  end

# Upgrade 2.2.0 inizio
  def create_units_export_file(unit_ids)
    create_units_data_file(unit_ids)
    create_metadata_file
    create_aef_file
  end
# Upgrade 2.2.0 fine

# Upgrade 2.2.0 inizio
  def create_units_export_file_csv(unit_ids, fond_id, dest_folder)
    create_units_data_file_csv(unit_ids, fond_id)
    create_csv_file(dest_folder)
  end
# Upgrade 2.2.0 fine

  private

# Upgrade 3.0.0 inizio
  def create_csv_file(dest_folder)
    FileUtils.cp(self.data_file, dest_folder)
  end
# Upgrade 3.0.0 fine

  def create_aef_for_xml_ead_file
    files = {}
    @data_names.each do |dn|
      case dn
      when /fond/
        files["data-fond.xml"] = dn
      when /ca/
        url_split = dn.split("/")
        ca_name = url_split[-1]
        name_split = ca_name.split("-")
        fond_name = name_split[0] + "-" + name_split[1] + ".xml"
        files[fond_name] = dn
      when /custodian/
        files["data-custodian.xml"] = dn
      when /sp/
        url_split = dn.split("/")
        sp_name = url_split[-1]
        name_split = sp_name.split("-")
        creator_name = name_split[0] + "-" + name_split[1] + ".xml"
        files[creator_name] = dn
      when /digital/
        files["data-digital-object.xml"] = dn   
      when /source/
        files["data-source.xml"] = dn       
      end
    end
    
# Upgrade 3.0.0 inizio
# definizione directory oggetti digitali
    @dir = "#{Rails.root}/public/digital_objects"
    @dir.sub!(%r[/$],'')
    include_digital_objects = self.inc_digit
# Upgrade 3.0.0 fine

# Upgrade 2.0.0 inizio
#    Zip::ZipFile.open(self.dest_file, Zip::ZipFile::CREATE) do |zipfile|
    Zip::File.open(self.dest_file, Zip::File::CREATE) do |zipfile|
# Upgrade 2.0.0 fine
      files.each do |dst, src|
        zipfile.add(dst, src)
      end
# Upgrade 3.0.0 inizio
# recupero degli access tokens corrispondenti alle cartelle degli oggetti digitali da importare se selezionato checkbox
    if include_digital_objects == 'true'
      fond_access_tokens = DigitalObject.select("access_token").where(:attachable_id => self.fond_ids, :attachable_type => "Fond").map(&:access_token)
      unit_access_tokens = DigitalObject.select("access_token").where(:attachable_id => self.unit_ids, :attachable_type => "Unit").map(&:access_token)
      entries = fond_access_tokens + unit_access_tokens
      writeEntries(entries, "", zipfile )
    end
# Upgrade 3.0.0 fine
    end
  end

  def create_aef_for_xml_file
    files = {}
    @data_names.each do |dn|
      case dn
      when /fond/
        files["data-fond.xml"] = dn
      when /custodian/
        files["data-custodian.xml"] = dn
      when /creator/
        files["data-creator.xml"] = dn
      when /digital/
        files["data-digital-object.xml"] = dn   
      when /source/
        files["data-source.xml"] = dn       
      end
    end
    
# Upgrade 3.0.0 inizio
# definizione directory oggetti digitali
    @dir = "#{Rails.root}/public/digital_objects"
    @dir.sub!(%r[/$],'')
    include_digital_objects = self.inc_digit
# Upgrade 3.0.0 fine

# Upgrade 2.0.0 inizio
#    Zip::ZipFile.open(self.dest_file, Zip::ZipFile::CREATE) do |zipfile|
    Zip::File.open(self.dest_file, Zip::File::CREATE) do |zipfile|
# Upgrade 2.0.0 fine
      files.each do |dst, src|
        zipfile.add(dst, src)
      end
# Upgrade 3.0.0 inizio
# recupero degli access tokens corrispondenti alle cartelle degli oggetti digitali da importare se selezionato checkbox
    if include_digital_objects == 'true'
      fond_access_tokens = DigitalObject.select("access_token").where(:attachable_id => self.fond_ids, :attachable_type => "Fond").map(&:access_token)
      unit_access_tokens = DigitalObject.select("access_token").where(:attachable_id => self.unit_ids, :attachable_type => "Unit").map(&:access_token)
      entries = fond_access_tokens + unit_access_tokens
      writeEntries(entries, "", zipfile )
    end
# Upgrade 3.0.0 fine
    end
  end

# Upgrade 2.2.0 inizio
  def create_aef_file
    files = {"metadata.json" => self.metadata_file, "data.json" => self.data_file}
# Upgrade 3.0.0 inizio
# definizione directory oggetti digitali
    @dir = "#{Rails.root}/public/digital_objects"
    @dir.sub!(%r[/$],'')
    include_digital_objects = self.inc_digit
# Upgrade 3.0.0 fine

# Upgrade 2.0.0 inizio
#    Zip::ZipFile.open(self.dest_file, Zip::ZipFile::CREATE) do |zipfile|
    Zip::File.open(self.dest_file, Zip::File::CREATE) do |zipfile|
# Upgrade 2.0.0 fine
      files.each do |dst, src|
        zipfile.add(dst, src)
      end
# Upgrade 3.0.0 inizio
# recupero degli access tokens corrispondenti alle cartelle degli oggetti digitali da importare se selezionato checkbox
    if include_digital_objects == 'true'
      fond_access_tokens = DigitalObject.select("access_token").where(:attachable_id => self.fond_ids, :attachable_type => "Fond").map(&:access_token)
      unit_access_tokens = DigitalObject.select("access_token").where(:attachable_id => self.unit_ids, :attachable_type => "Unit").map(&:access_token)
      entries = fond_access_tokens + unit_access_tokens
      writeEntries(entries, "", zipfile )
    end
# Upgrade 3.0.0 fine
    end
  end

# Upgrade 3.0.0 inizio
# metodo di import delle cartelle digital object
  def writeEntries(entries, path, io)
    entries.each { |e|
      zipFilePath = path == "" ? e : File.join(path, e)
      destZipFilePath = "public/digital_objects/" + zipFilePath
      diskFilePath = File.join(@dir, zipFilePath)
      if  File.directory?(diskFilePath)
        io.mkdir(destZipFilePath)
        subdir =Dir.entries(diskFilePath); subdir.delete("."); subdir.delete("..")
        writeEntries(subdir, zipFilePath, io)
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
# Upgrade 3.0.0 fine

  def create_units_data_file(unit_ids)
    ActiveRecord::Base.include_root_in_json = true
    units = Unit.order("sequence_number").find(unit_ids)
    File.open(self.data_file, "a") do |file|
      unit_sequence_number_index = 1
      units.each do |unit|
        # le relazioni con i fondi (legacy_root_fond_id, legacy_parent_fond_id) non vengono esportate perché il fondo in cui si effettuerà l'importazione dei dati avrà
        # in generale una struttura diversa da quella di origine (e comunque è prevista l'esportazione di unità appartenenti ad un unico livello (fondo)). 
        # Per lo stesso motivo non si esportano i campi fond_id, root_fond_id
        #
        # ancestry non viene esportato perché lo si ricostruisce in import
        #
        # si forza sequence_number in modo che sia un progressivo da 1 a N unità esportate
        
        unit.legacy_id = unit.id
        unit.legacy_parent_unit_id = unit.is_root? ? nil : unit.parent_id.to_s

        unit.sequence_number = unit_sequence_number_index
        
        file.write(unit.to_json(:except => [:id, :fond_id, :root_fond_id, :position, :ancestry, :db_source, :created_by, :updated_by, :legacy_sequence_number, :legacy_parent_fond_id, :legacy_root_fond_id, :created_at, :updated_at]).gsub("\\r",""))
        file.write("\r\n")
        unit_sequence_number_index += 1
      end
      export_units_related_entities(file, unit_ids, self.tables[:units])
      export_entity_related_digital_objects(file, "Unit", unit_ids)
    end
  end

  def create_units_data_file_csv(unit_ids, fond_id)
    fond = Fond.select("id, ancestry, name").find(fond_id)
    display_sequence_numbers = Unit.display_sequence_numbers_of(fond.root)
    File.open(self.data_file, "a") do |file|
      file.write(create_csv(unit_ids, display_sequence_numbers))
      export_units_related_entities_csv(file, unit_ids, self.tables[:units])
    end
  end

   def create_csv(ids, sequence_numbers, options = {})
    conditionParam = "#{:id} IN (#{ids.join(',')})"
    ucsv = Unit.where(conditionParam).order("sequence_number")
    attributes_all = Unit.column_names
    attributes_except = ["id", "fond_id", "root_fond_id", "position", "ancestry", "db_source", "created_by", "updated_by", "legacy_sequence_number", "legacy_parent_fond_id", "legacy_root_fond_id", "created_at", "updated_at"]
    attributes = attributes_all - attributes_except
    attr_names = attributes.collect { |x| "units_" + x }

    CSV.generate(options) do |new_csv|
      new_csv << attr_names
      ucsv.each_with_index do |csv_unit, index|
        csv_data = []
        attributes.each do |attribute|
          if attribute == "legacy_id"
            csv_data << csv_unit.id
          elsif attribute == "legacy_parent_unit_id"
            csv_data << csv_unit.is_root? ? nil : csv_unit.parent_id.to_s
          elsif attribute == "sequence_number"
            csv_data << csv_unit.display_sequence_number_from_hash(sequence_numbers)
          else
            csv_data << csv_unit.try(attribute.to_sym).to_s
          end
        end
        new_csv << csv_data
      end
      new_csv << []
    end
  end

  def create_related_csv(table, set_element, options = {})
    related_attributes_all = table.singularize.camelize.constantize.column_names
    related_attributes_except = ["id", "db_source", "created_at", "updated_at"]
    related_attributes = related_attributes_all - related_attributes_except
    related_attr_names = related_attributes.collect { |j| table + "_" + j }

    CSV.generate(options) do |new_related_csv|
      new_related_csv << related_attr_names
      set_element.each_with_index do |csv_related_unit, index|
        csv_related_data = []
        if (["sc2_authors","sc2_commissions"].include?(table)) then
          csv_related_unit.legacy_current_id = csv_related_unit.id
          if (table == "sc2_authors") then @sc2_attribution_reasons_ids.push(csv_related_unit.id) end
          if (table == "sc2_commissions") then @sc2_commission_names_ids.push(csv_related_unit.id) end
        end
        related_attributes.each do |attribute|
          if attribute == "legacy_id"
            if table == "sc2_attribution_reasons"
              csv_related_data << csv_related_unit.sc2_author_id
            elsif table == "sc2_commission_names"
              csv_related_data << csv_related_unit.sc2_commission_id
            else
              csv_related_data << csv_related_unit.unit_id
            end
          else
            csv_related_data << csv_related_unit.try(attribute.to_sym).to_s
          end
        end
        new_related_csv << csv_related_data
      end
      new_related_csv << []
    end

  end

  def export_units_related_entities_csv(file, unit_ids, unit_related_tables)
    @sc2_attribution_reasons_ids = Array.new
    @sc2_commission_names_ids = Array.new
    
    unless unit_ids.empty?
      unit_related_tables.each do |table|
        model = table.singularize.camelize.constantize
        set = model.where("unit_id IN (#{unit_ids.join(',')})")
        if set.count > 0
          file.write(create_related_csv(table, set))
        end
      end
    end
    unless @sc2_attribution_reasons_ids.empty?
      set = Sc2AttributionReason.where("sc2_author_id IN (#{@sc2_attribution_reasons_ids.join(',')})")
      table = "sc2_attribution_reasons"
      if set.count > 0
        file.write(create_related_csv(table, set))
      end
    end
    unless @sc2_commission_names_ids.empty?
      set = Sc2CommissionName.where("sc2_commission_id IN (#{@sc2_commission_names_ids.join(',')})")
      table = "sc2_commission_names"
      if set.count > 0
        file.write(create_related_csv(table, set))
      end
    end
  end
  
  def export_units_related_entities(file, unit_ids, unit_related_tables)
    #TODO considerare each_slice su unit_ids per grandi quantitativi di unità (+query ma meno memoria).
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
# Upgrade 2.0.0 inizio
#          set = DigitalObject.all(:conditions => "attachable_id IN (#{entity_ids}) AND attachable_type = '#{type}'")
      set = DigitalObject.where("attachable_id IN (#{entity_ids}) AND attachable_type = '#{type}'")
# Upgrade 2.0.0 fine
      set.each do |digital_object|
        digital_object.legacy_id = digital_object.attachable_id
        file.write(digital_object.to_json(:except => [:id, :group_id, :db_source, :created_by, :updated_by, :created_at, :updated_at]))
        file.write("\r\n")
      end
    end
  end

  def create_metadata_file
    metadata = Hash.new
    metadata.store('version', APP_VERSION.gsub('.', '').to_i)
    metadata.store('checksum', Digest::SHA256.file(self.data_file).hexdigest)
    metadata.store('date', Time.now)
    metadata.store('producer', RbConfig::CONFIG['host'])
    metadata.store('attached_entity', self.target_class.capitalize)
    metadata.store('mode', self.mode)
    File.open(self.metadata_file, "w+") do |file|
      file.write(metadata.to_json)
    end
  end

  def create_data_file
    self.fond_ids = Array.new
    ActiveRecord::Base.include_root_in_json = true
    #TODO valutare la sostituzione di 'all' con 'active' per i fondi (non esportiamo elementi cestinati)
    if self.mode == 'full'
      case self.target_class
      when 'fond'
# Upgrade 2.0.0 inizio
#        self.fond_ids = Fond.subtree_of(self.target_id).all(:select => :id, :order => "sequence_number")
        self.fond_ids = Fond.subtree_of(self.target_id).select(:id).order("sequence_number")
# Upgrade 2.0.0 fine
      when 'custodian'
# Upgrade 2.0.0 inizio
#        custodian = Custodian.find(self.target_id, :select => :id)
        custodian = Custodian.select(:id).find(self.target_id)
# Upgrade 2.0.0 fine
# Upgrade 2.0.0 inizio
#        fonds = custodian.fonds.all(:select => :fond_id)
        fonds = custodian.fonds.select(:fond_id)
# Upgrade 2.0.0 fine
        fonds.each do |f|
# Upgrade 2.0.0 inizio
#          tmp = Fond.subtree_of(f.fond_id).all(:select => :id, :order => "sequence_number")
          tmp = Fond.subtree_of(f.fond_id).select(:id).order("sequence_number")
# Upgrade 2.0.0 fine
          self.fond_ids += tmp
        end
      when 'project'
# Upgrade 2.0.0 inizio
#        project = Project.find(self.target_id, :select => :id)
        project = Project.select(:id).find(self.target_id)
# Upgrade 2.0.0 fine
# Upgrade 2.0.0 inizio
#        fonds = project.fonds.all(:select => :fond_id)
        fonds = project.fonds.select(:fond_id)
# Upgrade 2.0.0 fine
        fonds.each do |f|
# Upgrade 2.0.0 inizio
#          tmp = Fond.subtree_of(f.fond_id).all(:select => :id, :order => "sequence_number")
          tmp = Fond.subtree_of(f.fond_id).select(:id).order("sequence_number")
# Upgrade 2.0.0 fine
          self.fond_ids += tmp
        end
      end
      fonds_and_units 
      major_entities
      headings
      document_forms
      institutions
      sources
      digital_objects
    else
      if self.target_class == 'fond'
# Upgrade 2.0.0 inizio
#        self.fond_ids = Fond.subtree_of(self.target_id).all(:select => :id, :order => "sequence_number")
        self.fond_ids = Fond.subtree_of(self.target_id).select(:id).order("sequence_number")
# Upgrade 2.0.0 fine
        fonds_and_units
      else
        File.open(self.data_file, "a") do |file|
          model = self.target_class.camelize.constantize
          entity = model.find(self.target_id)
          entity.legacy_id = entity.id
          file.write(entity.to_json(:except => [:id, :db_source, :group_id, :created_at, :updated_at]))
          file.write("\r\n")
          self.tables[self.target_class.pluralize.to_sym].each do |table|
            model = table.singularize.camelize.constantize
# Upgrade 2.0.0 inizio
#            set = model.all(:conditions => "#{target_class}_id = #{self.target_id}")
            set = model.where("#{target_class}_id = #{self.target_id}")
# Upgrade 2.0.0 fine
            set.each do |e|
              e.send("legacy_id=", e.send("#{target_class}_id"))
              file.write(e.to_json(:except => [:id, :db_source, :created_at, :updated_at]))
              file.write("\r\n")
            end
          end
        end
      end
    end
  end

end