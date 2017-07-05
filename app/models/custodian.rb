class Custodian < ActiveRecord::Base

  # Modules

  extend Cleaner

  # Associations

  belongs_to :custodian_type
  belongs_to :updater, :class_name => "User", :foreign_key => "updated_by"
  has_one :import, :as => :importable, :dependent => :destroy

  has_many  :custodian_names, :dependent => :destroy
# Upgrade 2.0.0 inizio
=begin
  has_one   :preferred_name, :class_name => 'CustodianName', :conditions => {:qualifier => 'AU', :preferred => true}
  has_many  :other_names, :class_name => 'CustodianName', :conditions => {:preferred => false}
=end
  has_one   :preferred_name, -> { where({:qualifier => 'AU', :preferred => true}) }, :class_name => 'CustodianName'
  has_many  :other_names, -> { where({:preferred => false}) }, :class_name => 'CustodianName'
# Upgrade 2.0.0 fine

  has_many  :custodian_identifiers, :dependent => :destroy
  has_many  :custodian_contacts, :dependent => :destroy
# Upgrade 2.0.0 inizio
=begin
  has_one   :custodian_headquarter, :class_name => 'CustodianBuilding', :conditions => {:custodian_building_type => 'sede legale'}
  has_many  :custodian_other_buildings, :class_name => 'CustodianBuilding', :conditions => "custodian_building_type != '' AND custodian_building_type != 'sede legale'"
=end
  has_one   :custodian_headquarter, -> { where({:custodian_building_type => 'sede legale'}) }, :class_name => 'CustodianBuilding'
  has_many  :custodian_other_buildings, -> { where("custodian_building_type IS NULL OR custodian_building_type != 'sede legale'") }, :class_name => 'CustodianBuilding'
# Upgrade 2.0.0 fine
  has_many  :custodian_buildings, :class_name => 'CustodianBuilding', :dependent => :destroy
  has_many  :custodian_owners, :dependent => :destroy
  has_many  :custodian_urls, :dependent => :destroy
# Upgrade 2.0.0 inizio
#  has_many  :custodian_editors, :dependent => :destroy, :order => :edited_at
  has_many  :custodian_editors, -> {order(:edited_at)}, :dependent => :destroy
# Upgrade 2.0.0 fine

  has_many  :digital_objects, :as => :attachable, :dependent => :destroy

  # Many-to-many associations (rel)

  has_many  :rel_custodian_fonds, :dependent => :destroy, :autosave => true
# Upgrade 2.0.0 inizio
#  has_many  :fonds, :through => :rel_custodian_fonds, :include => :preferred_event, :order => "fonds.name"
  has_many  :fonds, -> {order("fonds.name").includes(:preferred_event)}, :through => :rel_custodian_fonds
# Upgrade 2.0.0 fine

  has_many :rel_custodian_sources, :autosave => true, :dependent => :destroy
  has_many :sources, :through => :rel_custodian_sources

# Upgrade 2.2.0 inizio
  belongs_to :group
# Upgrade 2.2.0 fine

  # Nested attributes

  accepts_nested_attributes_for :custodian_names,
    :allow_destroy => true,
    :reject_if => proc { |a| a['name'].blank? }

  accepts_nested_attributes_for :preferred_name,
    :allow_destroy => true,
    :reject_if => proc { |a| a['preferred'].blank?}

  accepts_nested_attributes_for :other_names,
    :allow_destroy => true,
    :reject_if => proc { |a| a['name'].blank? }

  accepts_nested_attributes_for :custodian_urls,
    :allow_destroy => true,
    :reject_if => proc { |a| a['url'].blank? }

  accepts_nested_attributes_for :custodian_owners,
    :allow_destroy => true,
    :reject_if => proc { |a| a['owner'].blank? }

  accepts_nested_attributes_for :custodian_identifiers,
    :allow_destroy => true,
    :reject_if => proc { |a| a['identifier'].blank? || a['identifier_source'].blank? }

  accepts_nested_attributes_for :custodian_contacts,
    :allow_destroy => true,
    :reject_if => proc {|a| a['contact'].blank? || a['contact_type'].blank? }

  accepts_nested_attributes_for :custodian_buildings,
    :allow_destroy => true

  accepts_nested_attributes_for :custodian_editors,
    :allow_destroy => true,
    :reject_if => Proc.new { |a| a['name'].blank? }

  accepts_nested_attributes_for :rel_custodian_fonds,
    :allow_destroy => true,
    :reject_if => Proc.new { |a| a['fond_id'].blank? }

  accepts_nested_attributes_for :rel_custodian_sources,
    :allow_destroy => true,
    :reject_if => Proc.new { |a| a['source_id'].blank? }

  # Validations

  validates_associated :preferred_name

  # Callbacks

  squished_fields :contact_person, :owner
  trimmed_fields  :administrative_structure,
    :collecting_policies,
    :holdings,
    :accessibility,
    :services

  remove_blank_other_names

  # Scopes
# Upgrade 2.0.0 inizio
=begin
  named_scope :list, :select => "custodians.id, custodian_names.name, custodians.updated_at",
    :joins => :preferred_name

  named_scope :export_list, :select => "custodians.id, custodian_names.name, custodians.updated_at, custodians.db_source, count(custodians.id) AS num",
    :joins => [:fonds, :preferred_name],
    :group => "custodians.id, custodian_names.name",
    :order => "custodian_names.name"

  named_scope :search, lambda{|q|
    conditions = ["custodian_names.qualifier = 'AU' AND LOWER(custodian_names.name) LIKE :q", {:q => "%#{q.downcase.squish}%"}] if q.present?
    { :conditions => conditions }
  }

  named_scope :autocomplete_list, lambda{|term|
    {
      :select => "custodians.id AS id, custodian_names.name AS value, custodian_names.name AS name",
      :joins => :custodian_names,
      :conditions => ["custodian_names.preferred = ? AND custodian_names.qualifier = ? AND LOWER(custodian_names.name) LIKE ?",
        true, 'AU', "%#{term}%"],
      :order => "custodian_names.name ASC",
      :limit => 10
    }
  }
=end
# Upgrade 2.2.0 inizio
#  scope :list, -> { select("custodians.id, custodian_names.name, custodians.updated_at").joins(:preferred_name) }
  scope :list, -> { select("custodians.id, custodian_names.name, custodians.updated_at, custodians.published, group_id, groups.short_name").joins(:preferred_name, :group) }
# Upgrade 2.2.0 fine

  scope :export_list, -> { select("custodians.id, custodian_names.name, custodians.updated_at, custodians.db_source, count(custodians.id) AS num").joins([:fonds, :preferred_name]).group("custodians.id, custodian_names.name").order("custodian_names.name") }

  scope :search, ->(q) {
    conditions = ["custodian_names.qualifier = 'AU' AND LOWER(custodian_names.name) LIKE :q", {:q => "%#{q.downcase.squish}%"}] if q.present?
    where(conditions)
  }

  scope :autocomplete_list, ->(term) {
    select("custodians.id AS id, custodian_names.name AS value, custodian_names.name AS name").
    joins(:custodian_names).
    where(["custodian_names.preferred = ? AND custodian_names.qualifier = ? AND LOWER(custodian_names.name) LIKE ?", true, 'AU', "%#{term}%"]).
    order("custodian_names.name ASC").
    limit(10)
  }
# Upgrade 2.0.0 fine

  # Virtual attributes

  def display_name
    preferred_name.name
  end

  def headquarter_address
    if custodian_headquarter.present?
      [
        custodian_headquarter.address,
        custodian_headquarter.postcode,
        custodian_headquarter.city,
        custodian_headquarter.country
      ].
        delete_if{|fragment| fragment.blank?}.
        join(" ")
    end
  end

  # TODO: dry
  def sorted_rel_custodian_fonds
# Upgrade 2.0.0 inizio
#    rel_custodian_fonds.all(:include => :fond).sort_by{|rel| rel.fond.try(:name) || 'zz'}
    rel_custodian_fonds.includes(:fond).sort_by{|rel| rel.fond.try(:name) || 'zz'}
# Upgrade 2.0.0 fine
  end

  # OPTIMIZE: verificare che questo metodo non inneschi da quelche parte query
  # pesanti e inutili, come rilevato per metodo omonimo Creator
  # self.sorted_suggested
  def self.sorted_suggested
# Upgrade 2.0.0 inizio
#    all(:select => 'custodians.id', :include => :preferred_name).sort_by{|c| c.try(:preferred_name).try(:name) || 'zz'}
    select('custodians.id').includes(:preferred_name).sort_by{|c| c.try(:preferred_name).try(:name) || 'zz'}
# Upgrade 2.0.0 fine
  end

  def sorted_rel_custodian_sources
# Upgrade 2.0.0 inizio
#    rel_custodian_sources.all(:include => :source).sort_by{|rel| rel.source.try(:short_title) || 'zz'}
    rel_custodian_sources.includes(:source).sort_by{|rel| rel.source.try(:short_title) || 'zz'}
# Upgrade 2.0.0 fine
  end

end

