class Group < ActiveRecord::Base

  extend Cleaner

  before_destroy :is_empty?
# Upgrade 2.2.0 inizio
#  has_many :users
  has_many :rel_user_groups, dependent: :destroy
  has_many :users, :through => :rel_user_groups
# Upgrade 2.2.0 fine

# Upgrade 2.0.0 inizio
  has_many :carousel_images, :dependent => :destroy, :class_name => 'GroupCarouselImage', :foreign_key => "related_group_id"
  has_many :logo_images, :dependent => :destroy, :class_name => 'GroupLogoImage', :foreign_key => "related_group_id"
# Upgrade 2.0.0 fine

  validates_presence_of :name
  validates_uniqueness_of :name
  squished_fields :name

# Upgrade 2.1.0 inizio
  validates_presence_of :short_name
  validates_length_of :short_name, :maximum => 30, :message => :too_long_value
  validates_uniqueness_of :short_name, :message => :not_unique_value
  validates_format_of :short_name, :with => /\A[a-zA-Z]([a-zA-Z0-9_-]*)\z/, :message => :illegal_format
# Upgrade 2.1.0 fine

  def is_empty?
# Upgrade 2.2.0 inizio
#    users.empty?
    rel_user_groups.empty?
# Upgrade 2.2.0 fine
  end

  def self.filter(group=1)
# Upgrade 2.0.0 inizio
=begin
    case group
    when 1 then
      self.all(:order => :name).map{|g| [ g.name, g.id ] }
    else
      self.all(:conditions => "id = #{group}", :order => :name).map {|g| [ g.name, g.id ] }
    end
=end
    case group
    when 1 then
      self.order(:name).map{|g| [ g.name, g.id ] }
    else
      self.where("id = #{group}").order(:name).map {|g| [ g.name, g.id ] }
    end
# Upgrade 2.0.0 fine
  end

end

