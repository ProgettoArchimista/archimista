# Upgrade 2.0.0 inizio
require 'csv'
# Upgrade 2.0.0 fine

class Unit < ActiveRecord::Base

  MAX_LEVEL_OF_NODES = 2

  cattr_reader :per_page
  @@per_page = 100

  # Modules

  extend Cleaner

  # Callbacks
  before_validation :set_root_fond_id
  before_save :cache_depth # force ancestry_depth update during move operations

  # remove_blank_iccd_tsk

  # Associations and custom modules

  include TreeExt::Debug

# Upgrade 2.0.0 inizio
  belongs_to :fond, :counter_cache => true
#  belongs_to :fond, -> { where.not db_source: nil }, :counter_cache => true
# Upgrade 2.0.0 fine

  has_ancestry :cache_depth => true

  extend HasArchidate
  has_many_archidates

  extend TreeExt::UpdateDescendants
  update_in_descendants :fond_id, :root_fond_id

  extend TreeExt::ActsAsExternalSequence
  acts_as_external_sequence :node_name => 'title', :external_parent => 'Fond'

  list_scope_fields :ancestry, :fond_id
  acts_as_list :scope => list_scope

  extend UnitSupport
  activate_unit_support

  belongs_to :updater,  :class_name => "User", :foreign_key => "updated_by"

  has_many :unit_identifiers, :dependent => :destroy
  has_many :unit_other_reference_numbers, :dependent => :destroy
  has_many :unit_langs, :dependent => :destroy
  has_many :unit_damages, :dependent => :destroy
  has_many :unit_urls, :dependent => :destroy
# Upgrade 2.0.0 inizio
#  has_many :unit_editors, :dependent => :destroy, :order => :edited_at
  has_many :unit_editors, -> { order(:edited_at) }, :dependent => :destroy
# Upgrade 2.0.0 fine

  has_many :digital_objects, :as => :attachable, :dependent => :destroy

  has_many :rel_unit_sources, :autosave => true, :dependent => :destroy
  has_many :sources, :through => :rel_unit_sources

  has_many :rel_unit_headings, :autosave => true, :dependent => :destroy
  has_many :headings, :through => :rel_unit_headings

  has_one :iccd_description
  has_one :iccd_tech_spec
  has_many :iccd_authors, :dependent => :destroy
  has_many :iccd_subjects, :dependent => :destroy
  has_many :iccd_damages, :dependent => :destroy

# Upgrade 2.1.0 inizio
  has_one :sc2
  has_many :sc2_textual_elements, :dependent => :destroy
  has_many :sc2_visual_elements, :dependent => :destroy
  has_many :sc2_authors, :dependent => :destroy
  has_many :sc2_attribution_reasons, :through => :sc2_authors, :dependent => :destroy
  has_many :sc2_commissions, :dependent => :destroy
  has_many :sc2_commission_names, :through => :sc2_commissions, :dependent => :destroy
	has_many :sc2_techniques, :dependent => :destroy
  has_many :sc2_scales, :dependent => :destroy

  accepts_nested_attributes_for :sc2, :allow_destroy => true
  accepts_nested_attributes_for :sc2_textual_elements, :allow_destroy => true, :reject_if => proc { |a| a['isri'].blank? }
  accepts_nested_attributes_for :sc2_visual_elements, :allow_destroy => true, :reject_if => proc { |a| a['stmd'].blank? }
  accepts_nested_attributes_for :sc2_authors, :allow_destroy => true, :reject_if => :sc2_authors_reject_if
	accepts_nested_attributes_for :sc2_attribution_reasons, :allow_destroy => true
	accepts_nested_attributes_for :sc2_commissions, :allow_destroy => true, :reject_if => :sc2_commissions_reject_if
	accepts_nested_attributes_for :sc2_commission_names, :allow_destroy => true, :reject_if => proc { |a| a['cmmn'].blank? }
	accepts_nested_attributes_for :sc2_techniques, :allow_destroy => true, :reject_if => proc { |a| a['mtct'].blank? }
  accepts_nested_attributes_for :sc2_scales, :allow_destroy => true, :reject_if => proc { |a| a['sca'].blank? }

  amoeba do
    enable
    exclude_association :events # necessario altrimenti duplica le date
    customize([
      lambda do |orig, copy|
        copy.position = orig.position + 1
      end
      ])
  end

  def sc2_authors_reject_if(attributes)
    exists = attributes[:id].present?
    empty = attributes[:autr].blank? && attributes[:autn].blank? && attributes[:auta].blank?
    attributes.merge!({_destroy: 1}) if exists and empty
    return (!exists and empty)
  end

  def sc2_commissions_reject_if_org(attributes)
    exists = attributes[:id].present?
    empty = attributes[:cmmc].blank?
    if (empty)
      begin
        sc2_commission_names = attributes[:sc2_commission_names_attributes]
        sc2_commission_names.each do |r|
          if !r[1][:cmmn].blank?
            empty = false
            break
          end
        end
      rescue Exception => e
        empty = false
      end
    end
    attributes.merge!({_destroy: 1}) if (exists and empty)
    return (!exists and empty)
  end

# gestisce i seguenti casi: 1) cmmc="" e tutti i cmmn="" 2) cmmc="" e tutti i cmmn hanno destroy=1 e almeno un cmmn<>""
  def sc2_commissions_reject_if(attributes)
    exists = attributes[:id].present?
    sc2_commissions_empty = attributes[:cmmc].blank?

    sc2_commission_names = attributes[:sc2_commission_names_attributes]
		sc2_commission_names_empty = (sc2_commission_names.size > 0)
    if (sc2_commissions_empty)
      begin
        sc2_commission_names.each do |r|
          if !r[1][:cmmn].blank? && (!r[1][:_destroy].present? || (r[1][:_destroy].present? && r[1][:_destroy] == "0"))
            sc2_commission_names_empty = false
            break
          end
        end
      rescue Exception => e
        sc2_commission_names_empty = false
      end
    end
    attributes.merge!({_destroy: 1}) if (exists and sc2_commissions_empty and sc2_commission_names_empty)
    return (!exists and (sc2_commissions_empty and sc2_commission_names_empty))
  end
# Upgrade 2.1.0 fine

  # Nested attributes
  accepts_nested_attributes_for :iccd_damages,
    :allow_destroy => true

  accepts_nested_attributes_for :iccd_subjects,
    :allow_destroy => true

  accepts_nested_attributes_for :iccd_description,
    :allow_destroy => true

  accepts_nested_attributes_for :iccd_tech_spec,
    :allow_destroy => true

  accepts_nested_attributes_for :iccd_authors,
    :allow_destroy => true,
    :reject_if => proc { |a| a['autn'].blank? }

  accepts_nested_attributes_for :unit_urls,
    :allow_destroy => true,
    :reject_if => proc { |a| a['url'].blank? }

  accepts_nested_attributes_for :unit_identifiers,
    :allow_destroy => true,
    :reject_if => proc { |a| a['identifier'].blank? or a['identifier_source'].blank? }

  accepts_nested_attributes_for :unit_other_reference_numbers,
    :allow_destroy => true,
    :reject_if => proc { |a| a['other_reference_number'].blank? }

  accepts_nested_attributes_for :unit_langs,
    :allow_destroy => true,
    :reject_if => proc { |a| a['code'].blank? }

  accepts_nested_attributes_for :unit_damages,
    :allow_destroy => true,
    :reject_if => proc { |a| a['code'].blank? }

  accepts_nested_attributes_for :unit_editors,
    :allow_destroy => true,
    :reject_if => Proc.new { |a| a['name'].blank? }

  accepts_nested_attributes_for :rel_unit_sources,
    :allow_destroy => true,
    :reject_if => Proc.new { |a| a['source_id'].blank? }

  accepts_nested_attributes_for :rel_unit_headings,
    :allow_destroy => true,
    :reject_if => Proc.new { |a| a['heading_id'].blank? }

  # Validations

  validates_presence_of :title
  validates_presence_of :fond_id, :root_fond_id, :ancestry_depth
  validates_inclusion_of :sequence_number, :in => 1..99999, :allow_blank => true

  squished_fields :reference_number,
    :tmp_reference_string,
    :title,
    :physical_container_title

  trimmed_fields :content,
    :arrangement_note,
    :related_materials,
    :note,
    :physical_description,
    :preservation_note,
    :restoration,
    :access_condition_note,
    :use_condition_note

  blank_default :title

  # Custom validations

  validate  :matching_parent_and_fond,
    :matching_fond_and_root_fond
    :allowed_ancestry_depth

  def matching_parent_and_fond
    errors.add_to_base :not_matching_parent_and_fond if parent && fond_id != parent.fond_id
  end

  def matching_fond_and_root_fond
    errors.add_to_base :not_matching_fond_and_root_fond unless fond_id && root_fond_id && root_fond_id == fond.root_id
  end

  def allowed_ancestry_depth
    errors.add_to_base :not_allowed_ancestry_depth if ancestry_depth > MAX_LEVEL_OF_NODES
  end

  # Scopes
# Upgrade 2.0.0 inizio
=begin
  named_scope :list, :select => "units.id, units.sequence_number, units.reference_number,
                                units.tmp_reference_number, units.title, units.ancestry".squish

  named_scope :search, lambda{|q|
    conditions = ["LOWER(units.title) LIKE :q", {:q => "%#{q.downcase.squish}%"}] if q.present?
    { :conditions => conditions }
  }

  named_scope :default_order, {:order => "units.title"}
=end
  scope :list, -> { select("units.id, units.sequence_number, units.reference_number, units.tmp_reference_number, units.title, units.ancestry").squish() }

  scope :search, ->(q) {
    conditions = ["LOWER(units.title) LIKE :q", {:q => "%#{q.downcase.squish}%"}] if q.present?
    where(conditions)
  }

  scope :default_order, -> {order("units.title")}
# Upgrade 2.0.0 fine

  # Virtual attributes

  alias_attribute :name, :title
  alias_attribute :display_name, :title

  # OPTIMIZE: usare :format. Verificare dove usato (dopo modifica su pagine member)
  def level_type(short=false)
    short ? suffix = "_short" : suffix = ""
    case ancestry_depth
    when 0
      "#{I18n.t('level_file'+suffix)}"
    when 1
      "#{I18n.t('level_subfile'+suffix)}"
    when 2
      "#{I18n.t('level_subsubfile'+suffix)}"
    end
  end

  # Methods

  def full_path
    fond.path_items
  end

  def is_leaf?
    ancestry_depth == MAX_LEVEL_OF_NODES
  end

  def has_local_siblings?
# Upgrade 2.0.0 inizio
#    siblings.all(:conditions => "fond_id = #{self.fond_id}").count > 1
    siblings.where("fond_id = #{self.fond_id}").count > 1
# Upgrade 2.0.0 fine
  end

  def is_movable_up?
    !is_root?
  end

  def is_movable_down?
    !is_leaf? &&
    has_local_siblings? &&
    !descendants.at_depth(MAX_LEVEL_OF_NODES).exists?
  end

  def is_not_movable?
    !is_movable_up? && !is_movable_down?
  end

  def is_iccd?
    tsk.present?
  end

  def formatted_title
# Upgrade 2.0.0 inizio
# OCIO : non si capisce perche' su given_title? si verifica ActionView::Template::Error (missing attribute: given_title)
#   given_title? ? "[#{title}]" : title
    title
# Upgrade 2.0.0 fine
  end

  # Methods related to sequence_number

  # Returns a hash of all the units of the *root_fond*,
  # where the key is the unit_id and the value is the display_sequence_number.
  # The hash is empty if the root_fond has no subunits.

  def self.display_sequence_numbers_of(root_fond, index = 0)
    display_sequence_numbers = {}
    if root_fond.has_subunits?
# Upgrade 2.0.0 inizio
=begin
      units = self.all(:select => "id, position, ancestry, ancestry_depth",
        :conditions => "root_fond_id = #{root_fond.id} AND sequence_number IS NOT NULL",
        :order => "sequence_number")
=end
      units = self.select("id, position, ancestry, ancestry_depth").
        where("root_fond_id = #{root_fond.id} AND sequence_number IS NOT NULL").
        order("sequence_number")
# Upgrade 2.0.0 fine
      units.map do |u|
        value = case u.ancestry_depth
                when 0
# Upgrade 2.0.0 inizio
#                  [index += 1].to_s
                  index += 1
                  index.to_s
# Upgrade 2.0.0 fine
                when 1
                  [index, u.position].join(".")
                when 2
                  [index, u.parent.position, u.position].join(".")
                end
        display_sequence_numbers[u.id] = value
      end
    end
    display_sequence_numbers
  end

  # Method to be used in collection actions.
  def display_sequence_number_from_hash(display_sequence_numbers)
    display_sequence_numbers.present? ? display_sequence_numbers[id] : sequence_number
  end

  # Method to be used in member actions.
  def display_sequence_number
    self.class.display_sequence_numbers_of(fond.root)[id] || sequence_number
  end

  def prev_in_sequence
# Upgrade 2.0.0 inizio
#    self.class.find(:first, :select => "id", :conditions => "root_fond_id = #{root_fond_id} AND sequence_number = #{sequence_number-1}")
    self.class.select("id").find_by("root_fond_id = #{root_fond_id} AND sequence_number = #{sequence_number-1}")
# Upgrade 2.0.0 fine
  end

  def next_in_sequence
# Upgrade 2.0.0 inizio
#    self.class.find(:first, :select => "id", :conditions => "root_fond_id = #{root_fond_id} AND sequence_number = #{sequence_number+1}")
    self.class.select("id").find_by("root_fond_id = #{root_fond_id} AND sequence_number = #{sequence_number+1}")
# Upgrade 2.0.0 fine
  end

  # Other methods

  def sorted_rel_unit_sources
# Upgrade 2.0.0 inizio
#    rel_unit_sources.all(:include => :source).sort_by{|rel| rel.source.try(:short_title) || 'zz'}
    rel_unit_sources.includes(:source).sort_by{|rel| rel.source.try(:short_title) || 'zz'}
# Upgrade 2.0.0 fine
  end

  def sorted_rel_unit_headings
# Upgrade 2.0.0 inizio
#    rel_unit_headings.all(:include => :heading).sort_by{|rel| rel.heading.try(:name) || 'zz'}
    rel_unit_headings.includes(:heading).sort_by{|rel| rel.heading.try(:name) || 'zz'}
# Upgrade 2.0.0 fine
  end

  def self.build_order_options(params)
    TreeExt::OrderOptionsBuilder.new(params, self).build_order_options
  end

  def self.classify(record_ids, new_external_parent_id)
    TreeExt::ActsAsExternalSequence::Classify.new(
      :model_class            => self,
      :record_ids             => record_ids,
      :new_external_parent_id => new_external_parent_id,
      :belongs_to             => :fond
    ).classify
  end

  def self.attributes_for_labels
    [
      "#",
      "sequence_number",
      "root_fond_id",
      "fond.name",
      "formatted_title",
      "preferred_event.full_display_date_with_place",
      "tmp_reference_number",
      "tmp_reference_string",
      "folder_number",
      "file_number",
      "reference_number"
    ]
  end

  def self.to_csv(units, root_fond_name, sequence_numbers, options = {})
    attributes = attributes_for_labels

    headers = []
    attributes.each do |attribute|
      if attribute == '#'
        headers << attribute
      else
        methods = attribute.split('.')
        headers << human_attribute_name(methods[0])
      end
    end

# Upgrade 2.0.0 inizio
#    FasterCSV.generate(options) do |csv|
    CSV.generate(options) do |csv|
# Upgrade 2.0.0 fine
      csv << headers
      units.each_with_index do |unit, index|
        data = []
        attributes.each do |attribute|
          methods = attribute.split('.')
          if attribute.include?('.')
            data << unit.send(methods[0].to_sym).try(methods[1].to_sym).to_s
          elsif attribute == "root_fond_id"
            data << root_fond_name
          elsif attribute == "sequence_number"
            data << unit.display_sequence_number_from_hash(sequence_numbers)
          elsif attribute == "#"
            data << index += 1
          else
            data << unit.try(attribute.to_sym).to_s
          end
        end
        csv << data
      end
    end
  end

  # Callbacks

  def set_root_fond_id
    self.root_fond_id = fond.root_id if root_fond_id.nil? && fond
  end

end
