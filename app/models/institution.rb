class Institution < ActiveRecord::Base

  extend Cleaner

  belongs_to :updater,  :class_name => "User", :foreign_key => "updated_by"
# Upgrade 2.0.0 inizio
#  has_many :institution_editors, :dependent => :destroy, :order => :edited_at
  has_many :institution_editors, -> { order(:edited_at) }, :dependent => :destroy
# Upgrade 2.0.0 fine

# Upgrade 2.2.0 inizio
  belongs_to :group
# Upgrade 2.2.0 fine

  validates_presence_of :name

  squished_fields :name
  trimmed_fields :description, :note

  accepts_nested_attributes_for :institution_editors,
    :allow_destroy => true,
    :reject_if => Proc.new { |a| a['name'].blank? }

end

