class Creator < ActiveRecord::Base

  before_validation :reset_associated_records_by_creator_type

  def is_person?
    creator_type == 'P'
  end

  def is_family?
    creator_type == 'F'
  end

  def is_corporate?
    creator_type == "C"
  end

  # Modules

  extend Cleaner
  extend HasArchidate

  has_many_archidates :events_can_have_places => true,
                      :events_have_places_when => :is_person?

  # Associations

  belongs_to :creator_corporate_type
  belongs_to :updater,  :class_name => "User", :foreign_key => "updated_by"

  has_many :creator_names, :dependent => :destroy
# Upgrade 2.0.0 inizio
=begin
  has_one  :preferred_name, :class_name => 'CreatorName', :conditions => {:qualifier => 'A', :preferred => true}
  has_many :other_names, :class_name => 'CreatorName', :conditions => {:preferred => false}
=end
  has_one  :preferred_name, -> { where({:qualifier => 'A', :preferred => true})}, :class_name => 'CreatorName'
  has_many :other_names, -> { where({:preferred => false}) }, :class_name => 'CreatorName'
# Upgrade 2.0.0 fine

  has_many :creator_legal_statuses, :dependent => :destroy
  has_many :creator_urls, :dependent => :destroy
  has_many :creator_identifiers, :dependent => :destroy
  has_many :creator_activities, :dependent => :destroy
# Upgrade 2.0.0 inizio
#  has_many :creator_editors, :dependent => :destroy, :order => :edited_at
  has_many :creator_editors, -> {order(:edited_at)}, :dependent => :destroy
# Upgrade 2.0.0 fine

  has_many :digital_objects, :as => :attachable, :dependent => :destroy

  # Many-to-many associations (rel)

  has_many :rel_creator_creators, :dependent => :destroy, :autosave => true
  has_many :related_creators, :through => :rel_creator_creators

  has_many :inverse_rel_creator_creators, :class_name => "RelCreatorCreator", :foreign_key => "related_creator_id"
  has_many :inverse_related_creators, :through => :inverse_rel_creator_creators, :source => :creator

  has_many :rel_creator_fonds, :dependent => :destroy, :autosave => true
# Upgrade 2.0.0 inizio
#  has_many :fonds, :through => :rel_creator_fonds, :include => :preferred_event, :order => "fonds.name"
  has_many :fonds, -> {order("fonds.name").includes(:preferred_event)}, :through => :rel_creator_fonds
# Upgrade 2.0.0 fine
# Upgrade 2.2.0 inizio
  has_many :projects, -> { distinct }, :through => :fonds
# Upgrade 2.2.0 fine

  has_many :rel_creator_institutions, :dependent => :destroy, :autosave => true
  has_many :institutions, :through => :rel_creator_institutions

  has_many :rel_creator_sources, :dependent => :destroy, :autosave => true
  has_many :sources, :through => :rel_creator_sources

# Upgrade 2.2.0 inizio
  belongs_to :group
# Upgrade 2.2.0 fine

  # Nested attributes

  accepts_nested_attributes_for :creator_names,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['name'].blank? }

  accepts_nested_attributes_for :preferred_name,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['preferred'].blank?}

  accepts_nested_attributes_for :other_names,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['name'].blank? || a['qualifier'].blank? }

  accepts_nested_attributes_for :creator_legal_statuses,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['legal_status'].blank? }

  accepts_nested_attributes_for :creator_urls,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['url'].blank? }

  accepts_nested_attributes_for :creator_identifiers,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['identifier'].blank? || a['identifier_source'].blank? }

  accepts_nested_attributes_for :creator_activities,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['activity'].blank? }

  accepts_nested_attributes_for :creator_editors,
                                :allow_destroy => true,
                                :reject_if => Proc.new { |a| a['name'].blank? }

  accepts_nested_attributes_for :rel_creator_fonds,
                                :allow_destroy => true,
                                :reject_if => Proc.new { |a| a['fond_id'].blank? }

  accepts_nested_attributes_for :rel_creator_institutions,
                                :allow_destroy => true,
                                :reject_if => Proc.new { |a| a['institution_id'].blank? }

  accepts_nested_attributes_for :rel_creator_creators,
                                :allow_destroy => true,
                                :reject_if => Proc.new { |a| a['related_creator_id'].blank? }

  accepts_nested_attributes_for :rel_creator_sources,
                                :allow_destroy => true,
                                :reject_if => Proc.new { |a| a['source_id'].blank? }
  # Validations

  validates_presence_of :creator_type
  validates_associated :preferred_name

  # Callbacks

  squished_fields :residence
  trimmed_fields  :abstract, :history, :note
  remove_blank_other_names

  # Scopes

# Upgrade 2.0.0 inizio
=begin
  named_scope :list, :select => "creators.id, creators.creator_type, creator_names.name, creators.residence, creators.updated_at",
                     :joins => :preferred_name

  named_scope :search, lambda{|q|
    conditions = ["creator_names.qualifier = 'A' AND LOWER(creator_names.name) LIKE :q", {:q => "%#{q.downcase.squish}%"}] if q.present?
    { :conditions => conditions }
  }

  named_scope :autocomplete_list, lambda{|*term|
    term = term.shift.to_s
    conditions    = ["creator_names.preferred = ?
                      AND creator_names.qualifier = ?
                      AND LOWER(creator_names.name) LIKE ?".squish,
                      true, 'A', "%#{term.downcase.squish}%"]
    {
      :select => "creators.id, creator_names.name",
      :joins => :creator_names,
      :include => :preferred_event,
      :conditions => conditions,
      :order => "creator_names.name ASC",
      :limit => 10
    }
  }
=end
# Upgrade 2.2.0 inizio
#  scope :list, -> { select("creators.id, creators.creator_type, creator_names.name, creators.residence, creators.updated_at").joins(:preferred_name) }
  scope :list, -> { select("creators.id, creators.creator_type, creator_names.name, creators.residence, creators.updated_at, creators.published, group_id, groups.short_name").joins(:preferred_name, :group) }
# Upgrade 2.2.0 fine

  # Upgrade 3.0.1 ICAR inizio
  scope :export_list, -> { select("creators.id, creator_names.name, creators.updated_at, creators.db_source, count(creators.id) AS num").joins([:fonds, :preferred_name]).group("creators.id, creator_names.name").order("creator_names.name") }
  # Upgrade 3.0.1 fine


  scope :search, ->(q) {
    conditions = ["creator_names.qualifier = 'A' AND LOWER(creator_names.name) LIKE :q", {:q => "%#{q.downcase.squish}%"}] if q.present?
    where(conditions)
  }

  scope :autocomplete_list, ->(*term){
    term = term.shift.to_s
    conditions    = ["creator_names.preferred = ?
                      AND creator_names.qualifier = ?
                      AND LOWER(creator_names.name) LIKE ?".squish,
                      true, 'A', "%#{term.downcase.squish}%"]
    select("creators.id, creator_names.name")
      .joins(:creator_names)
      .includes(:preferred_event)
      .where(conditions)
      .order("creator_names.name ASC")
      .limit(10)
  }
# Upgrade 2.0.0 fine


  # Virtual attributes

  def display_name
    preferred_name.name
  end

  # OPTIMIZE: rinominare in display_name_with_date (usato da relations)
  def name_with_preferred_date
    return unless preferred_name
    preferred_event ? "#{h preferred_name.name} (#{preferred_event.full_display_date})" : preferred_name.name
  end

  alias_attribute :value, :name_with_preferred_date

  # Custom validations and methods

  private

  def reset_associated_records_by_creator_type
    # legal status / creator_corporate_type_id
    unless is_corporate?
      self.creator_corporate_type_id = nil
      self.residence = nil
      self.creator_legal_statuses.clear
      self.rel_creator_institutions.clear
    end

    # preferred_names
    if is_person?
      preferred_name.creator_type = "P"
      preferred_name.name = [preferred_name.last_name.squish, preferred_name.first_name.squish].reject(&:blank?).join(", ")
      preferred_name.note_cf = nil
      preferred_name.note = preferred_name.note_p
    else
      preferred_name.creator_type = nil
      preferred_name.first_name = nil
      preferred_name.last_name = nil
      preferred_name.note_p = nil
      preferred_name.note = preferred_name.note_cf
    end
  end

  public

  def self.sorted_suggested
# Upgrade 2.0.0 inizio
#     all(:select => 'creators.id', :include => [:preferred_name, :preferred_event]).sort_by{|creator| creator.try(:preferred_name).try(:name)}
    select('creators.id').includes([:preferred_name, :preferred_event]).sort_by{|creator| creator.try(:preferred_name).try(:name)}
# Upgrade 2.0.0 fine
  end

  def sorted_rel_creator_fonds
# Upgrade 2.0.0 inizio
#    rel_creator_fonds.all(:include => :fond).sort_by{|rel| rel.fond.try(:name) || 'zz'}
    rel_creator_fonds.includes(:fond).sort_by{|rel| rel.fond.try(:name) || 'zz'}
# Upgrade 2.0.0 fine
  end

  def sorted_rel_creator_institutions
# Upgrade 2.0.0 inizio
#    rel_creator_institutions.all(:include => :institution).sort_by{|rel| rel.institution.try(:name) || 'zz'}
    rel_creator_institutions.includes(:institution).sort_by{|rel| rel.institution.try(:name) || 'zz'}
# Upgrade 2.0.0 fine
  end

  def sorted_rel_creator_creators
# Upgrade 2.0.0 inizio
#    rel_creator_creators.all(:include => :creator).sort_by{|rel| rel.creator.preferred_name.try(:name) || 'zz'}
    rel_creator_creators.includes(:creator).sort_by{|rel| rel.creator.preferred_name.try(:name) || 'zz'}
# Upgrade 2.0.0 fine
  end

  def sorted_rel_creator_sources
# Upgrade 2.0.0 inizio
#    rel_creator_sources.all(:include => :source).sort_by{|rel| rel.source.try(:short_title) || 'zz'}
    rel_creator_sources.includes(:source).sort_by{|rel| rel.source.try(:short_title) || 'zz'}
# Upgrade 2.0.0 fine
  end

end

