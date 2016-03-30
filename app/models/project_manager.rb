# Upgrade 2.1.0 inizio
class ProjectManager < ActiveRecord::Base

  extend Cleaner

  belongs_to :project

  squished_fields :name

end
# Upgrade 2.1.0 fine

