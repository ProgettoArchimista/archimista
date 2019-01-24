class Anagraphic < ActiveRecord::Base

  cattr_reader :per_page
  @@per_page = 100

  extend Cleaner

  belongs_to :updater,  :class_name => "User", :foreign_key => "updated_by"

  # Many-to-many associations (rel)

  has_many :rel_unit_anagraphics, :autosave => true, :dependent => :destroy
  has_many :anag_identifiers, :dependent => :destroy
  has_many :units, :through => :rel_unit_anagraphics

  belongs_to :group

  
  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:anagraphic_type, :surname, :db_source, :group_id], :case_sensitive => false

  accepts_nested_attributes_for :anag_identifiers,
    :allow_destroy => true,
    :reject_if => Proc.new { |a| a['identifier'].blank? }

  # Virtual attributes
  def full_string
    if start_date.nil?
      date = ""
    else
      date = start_date.strftime("%d-%m-%Y")
    end
      
    [ name, surname, date ].
      delete_if { |fragment| fragment.blank? }.
      join(", ")
  end

  alias_attribute :value, :full_string

  # Callbacks
  squished_fields :name, :dates, :qualifier

  scope :autocomplete_list, -> (*term) {
    term = term.shift
    if term.present?
      conditions = ["LOWER(anagraphic_type) LIKE :term
                      OR LOWER(name) LIKE :term
                      OR LOWER(surname) LIKE :term",
        {:term => "%#{term}%"}]
      limit = 20
    else
      conditions = nil
      limit = nil
    end

    select("id, anagraphic_type, name, surname").
    where(conditions).
    order("anagraphic_type, name, surname").
    limit(limit)
  }

  scope :list, -> { select("anagraphics.id, anagraphics.anagraphic_type, anagraphics.name, anagraphics.surname, anagraphics.start_date, anagraphics.end_date, group_id, groups.short_name").joins(:group) }

  def self.find_or_initialize(params)
    self.find_or_initialize_by(params)
  end
end

