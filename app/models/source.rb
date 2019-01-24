class Source < ActiveRecord::Base

  cattr_reader :per_page
  @@per_page = 100

  # Modules
  extend Cleaner

  # Callbacks
  before_save :set_year

  # Associations
  belongs_to :source_type, :primary_key => :code, :foreign_key => :source_type_code
  belongs_to :updater, :class_name => "User", :foreign_key => "updated_by"

  has_many :source_urls, :dependent => :destroy
  has_many :digital_objects, :as => :attachable, :dependent => :destroy
  
# Upgrade 2.2.0 inizio
  has_one :first_digital_object, -> { where({:position => 1}) }, :as => :attachable, :class_name => DigitalObject
# Upgrade 2.2.0 fine
    
  # Many-to-many associations (rel)
  # OPTIMIZE: valutare uso di Polymorphic Association. Quali pro/contro ?
  has_many :rel_creator_sources, :dependent => :destroy, :autosave => true
  has_many :rel_custodian_sources, :dependent => :destroy, :autosave => true
  has_many :rel_fond_sources, :dependent => :destroy, :autosave => true
  has_many :rel_unit_sources, :dependent => :destroy

# Upgrade 2.0.0 inizio
  has_many :creators, :through => :rel_creator_sources
  has_many :custodians, :through => :rel_custodian_sources
  has_many :fonds, -> {order("fonds.name").includes(:preferred_event)}, :through => :rel_fond_sources
# Upgrade 2.0.0 fine

# Upgrade 2.2.0 inizio
  belongs_to :group
# Upgrade 2.2.0 fine

  # Nested attributes

  accepts_nested_attributes_for :source_urls,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['url'].blank? }

  accepts_nested_attributes_for :rel_creator_sources,
                                :allow_destroy => true,
                                :reject_if => Proc.new { |a| a['creator_id'].blank? }

  accepts_nested_attributes_for :rel_custodian_sources,
                                :allow_destroy => true,
                                :reject_if => Proc.new { |a| a['custodian_id'].blank? }

  accepts_nested_attributes_for :rel_fond_sources,
                                :allow_destroy => true,
                                :reject_if => Proc.new { |a| a['fond_id'].blank? }

  # Validations
  validates_presence_of :source_type_code, :short_title, :title
  # OPTIMIZE: rivedi questa e altre possibili validazioni
  # validates_uniqueness_of :short_title, :on => :create, :message => :taken
  alias_attribute :display_name, :short_title

  # Callbacks
  squished_fields :short_title,
                  :author,
                  :title,
                  :editor,
                  :institution,
                  :publisher,
                  :volume,
                  :pages,
                  :book_title,
                  :date_string

  trimmed_fields :abstract

  # Upgrade 3.0.1 ICAR inizio
  scope :export_list, -> { select("sources.id, sources.title, sources.short_title, sources.db_source, sources.updated_at, count(sources.id) AS num").joins([:fonds]).group("sources.id").order("sources.short_title")}
  # Upgrade 3.0.1 fine

  def set_year
    if date_string.present?
      self.year = date_string.guess_year
    end
  end

  # Named scopes
# Upgrade 2.0.0 inizio
=begin
  named_scope :autocomplete_list, lambda{|*term|
    term = term.shift
    if term.present?
      conditions = ["LOWER(title) LIKE :term OR LOWER(short_title) LIKE :term", {:term => "%#{term}%"}]
      limit = 10
    else
      conditions = nil
      limit = nil
    end

    {
      :select => "id, author, title, short_title, place, publisher, year, date_string",
      :conditions => conditions,
      :order => "short_title",
      :limit => limit
    }
  }

  named_scope :search, lambda{|q|
    conditions = ["LOWER(sources.short_title) LIKE :q OR LOWER(sources.title) LIKE :q", {:q => "%#{q.downcase.squish}%"}] if q.present?
    { :conditions => conditions }
  }
=end
  scope :autocomplete_list, ->(*term) {
    term = term.shift
    if term.present?
      conditions = ["LOWER(title) LIKE :term OR LOWER(short_title) LIKE :term", {:term => "%#{term}%"}]
      limit = 10
    else
      conditions = nil
      limit = nil
    end

    select("id, use_legacy, author, title, short_title, place, publisher, year, date_string, legacy_description").
    where(conditions).
    order("short_title").
    limit(limit)
  }

  scope :search, ->(q) {
    conditions = ["LOWER(sources.short_title) LIKE :q OR LOWER(sources.title) LIKE :q", {:q => "%#{q.downcase.squish}%"}] if q.present?
    where(conditions)
  }
# Upgrade 3.0.1 ICAR inizio
  scope :autocomplete_export_list, ->(*term){
    term = term.shift.to_s
    conditions = ["LOWER(title) LIKE :term OR LOWER(short_title) LIKE :term", {:term => "%#{term}%"}]
    select("id, CONCAT(short_title,' (', title, ') ') AS value").
    where(conditions).
    order("short_title").
    limit(10)
  }
  # Upgrade 3.0.1 ICAR fine
# Upgrade 2.0.0 fine


# TAI fonti
  def sorted_rel_creator_sources
    rel_creator_sources.includes({:creator => [:preferred_name, :preferred_event]}).sort_by{|rel| rel.creator.try(:preferred_name).try(:name) || 'zz'}
  end

  def sorted_rel_custodian_sources
    rel_custodian_sources.includes({:custodian => :preferred_name}).sort_by{|rel| rel.custodian.try(:preferred_name).try(:name) || 'zz'}
  end

  def sorted_rel_fond_sources
    rel_fond_sources.includes(:fond).sort_by{|rel| rel.fond.try(:name) || 'zz'}
  end

end

