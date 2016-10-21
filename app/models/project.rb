class Project < ActiveRecord::Base
  # Modules

  extend Cleaner

  # Associations
  belongs_to :updater,  :class_name => "User", :foreign_key => "updated_by"
  has_one :import, :as => :importable, :dependent => :destroy

# Upgrade 2.1.0 inizio
#  has_many  :project_credits, :dependent => :destroy
# Upgrade 2.1.0 fine
  has_many  :project_urls, :dependent => :destroy
# Upgrade 2.1.0 inizio
=begin 1.2.1
  has_many  :project_managers, :class_name => 'ProjectCredit', :conditions => {:credit_type => 'PM'}
  has_many  :project_stakeholders, :class_name => 'ProjectCredit', :conditions => {:credit_type => 'PS'}
=end
=begin 2.0.0
  has_many  :project_managers, -> { where({:credit_type => 'PM'}) }, :class_name => 'ProjectCredit'
  has_many  :project_stakeholders, -> { where({:credit_type => 'PS'}) }, :class_name => 'ProjectCredit'
=end
  has_many  :project_managers, :dependent => :destroy
  has_many  :project_stakeholders, :dependent => :destroy
# Upgrade 2.1.0 fine

# Upgrade 2.2.0 inizio
  belongs_to :group
# Upgrade 2.2.0 fine

  # Many-to-many associations (rel)

  has_many :rel_project_fonds, :dependent => :destroy, :autosave => true
# Upgrade 2.0.0 inizio
#  has_many :fonds, :through => :rel_project_fonds, :include => :preferred_event, :order => "fonds.name"
  has_many :fonds, -> { order("fonds.name").includes(:preferred_event) }, :through => :rel_project_fonds
# Upgrade 2.0.0 fine

  # Nested attributes

  accepts_nested_attributes_for :project_urls,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['url'].blank? }

# Upgrade 2.1.0 inizio
=begin
  accepts_nested_attributes_for :project_credits,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['credit_name'].blank? }
  accepts_nested_attributes_for :project_managers,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['credit_name'].blank? }

  accepts_nested_attributes_for :project_stakeholders,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['credit_name'].blank? }
=end
  accepts_nested_attributes_for :project_managers,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['name'].blank? }

  accepts_nested_attributes_for :project_stakeholders,
                                :allow_destroy => true,
                                :reject_if => proc { |a| a['name'].blank? }
# Upgrade 2.1.0 fine

  accepts_nested_attributes_for :rel_project_fonds,
                                :allow_destroy => true,
                                :reject_if => Proc.new { |a| a['fond_id'].blank? }

  # Named scopes
# Upgrade 2.0.0 inizio
=begin
  named_scope :autocomplete_list, lambda{|term|
    {
      :select => "id, name, name AS value",
      :conditions => ["LOWER(name) LIKE ?", "%#{term.downcase.squish}%"],
      :order => "name ASC",
      :limit => 10
    }
  }

  named_scope :export_list, :select => "projects.id, projects.name, projects.updated_at, count(projects.id) AS num",
              :joins => [:fonds],
              :group => "projects.id",
              :order => "projects.name"
=end

# Upgrade 2.2.0 inizio
=begin
  scope :autocomplete_list, ->(term) {
    select("id, name, name AS value").
    where(["LOWER(name) LIKE ?", "%#{term.downcase.squish}%"]).
    order("name ASC").
    limit(10)
  }
=end
  scope :autocomplete_list, ->(term) {
    select("id, name, name AS value").
    where(["LOWER(name) LIKE ?", "%#{if term.nil? then "" else term.downcase.squish end}%"]).
    order("name ASC").
    limit(10)
  }

  scope :search, ->(q, qpt, qps) {
    sql_stmt = ""
    params_hash = {}
    if q.present?
      if (sql_stmt != "") then sql_stmt = sql_stmt + " AND " end
      sql_stmt = sql_stmt + "LOWER(name) LIKE :q"
      params_hash[:q] = "%#{q.downcase.squish}%"
    end
    if qpt.present?
      if (sql_stmt != "") then sql_stmt = sql_stmt + " AND " end
      sql_stmt = sql_stmt + "project_type = :qpt"
      params_hash[:qpt] = "#{qpt}"
    end
    if qps.present?
      if (sql_stmt != "") then sql_stmt = sql_stmt + " AND " end
      sql_stmt = sql_stmt + "status = :qps"
      params_hash[:qps] = "#{qps}"
    end
    where(sql_stmt, params_hash)
  }  
# Upgrade 2.2.0 fine

  scope :export_list, -> { select("projects.id, projects.name, projects.updated_at, count(projects.id) AS num").joins([:fonds]).group("projects.id").order("projects.name") }
# Upgrade 2.0.0 fine

  # Callbacks

  squished_fields :name
  trimmed_fields :description, :note

  # Validations

  validates_presence_of :name
  validate :end_year_greater_than_start_year

  # Virtual attributes
  alias_attribute :display_name, :name
  
  public

  def display_date
    if start_year == end_year
      "#{start_year.to_s}"
    else
      "#{start_year.to_s}-#{end_year.to_s}"
    end
  end

  # TODO: dry
  def sorted_rel_project_fonds
# Upgrade 2.0.0 inizio
#    rel_project_fonds.all(:include => :fond).sort_by{|rel| rel.fond.try(:name) || 'zz'}
    rel_project_fonds.includes(:fond).sort_by{|rel| rel.fond.try(:name) || 'zz'}
# Upgrade 2.0.0 fine
  end

  private

  def end_year_greater_than_start_year
    unless self.end_year >= self.start_year
      errors.add(:start_year, "should be prior to the end date")
      errors.add(:end_year, "should be greater than end date")
    end
  end

end

