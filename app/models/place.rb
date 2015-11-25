class Place < ActiveRecord::Base
# Upgrade 2.0.0 inizio
=begin
  #named_scope :list, :select => "places.id, places.display_name", :limit => 10
  
  named_scope :list, lambda { |field| { :select => "id, #{field} AS value", :limit => 10 }}

  named_scope :by_qualifier, lambda { |qualifier| { :conditions => "qualifier = '#{qualifier}'" }}

  named_scope :search, lambda { |term, field| {:conditions => "lower(#{field}) LIKE '#{term}%'"}}
=end
  scope :list, ->(field) { select("id, #{field} AS value").limit(10) }

  scope :by_qualifier, ->(qualifier) { where("qualifier = '#{qualifier}'") }

  scope :search, ->(term, field) { where("lower(#{field}) LIKE '#{term}%'") }
# Upgrade 2.0.0 fine
  
end

