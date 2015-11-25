class SourceType < ActiveRecord::Base

  has_many :sources, :foreign_key => :source_type_code

# Upgrade 2.0.0 inizio
=begin
  named_scope :roots, :conditions => { :parent_code => nil }, :order => "position"
  named_scope :subtypes_of, lambda { |parent_code| {
    :conditions => { :parent_code => parent_code },
    :order => "position" }
  }
=end
  scope :roots, -> { order("position").where({ :parent_code => nil }) }
  scope :subtypes_of, ->(parent_code) {
    where({ :parent_code => parent_code }).
    order("position")
  }
# Upgrade 2.0.0 fine

end

