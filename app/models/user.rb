class User < ActiveRecord::Base

  extend Cleaner

# Upgrade 2.0.0 inizio
#  devise :database_authenticatable, :rememberable
  devise :database_authenticatable, :rememberable, :encryptable
# Upgrade 2.0.0 fine

  ROLES = ['superadmin', 'admin', 'author', 'supervisor']
  roles = ROLES

# Upgrade 2.2.0 inizio
#  belongs_to :group
  has_many :rel_user_groups, :class_name => 'RelUserGroup', dependent: :destroy, :autosave => true
  has_many :groups, :through => :rel_user_groups

  accepts_nested_attributes_for :rel_user_groups, :allow_destroy => true, :reject_if => Proc.new { |a| a['id'] == -1 || a['role'].blank? }

# tentativo di impostare una validazione sul fatto che non ci sia più di un riferimento allo stesso gruppo: non ha funzionato (o meglio si rileva la situazione di errore ma i record di rel_user_groups vengono salvati lo stesso)
  validate do check_group_uniqueness end
  def check_group_uniqueness
    status = true
    rel_user_groups.each do |rug|
      n = rel_user_groups_count_group_references(rug.group_id)
      if status && n > 1 then status = false end
    end
    return status
  end
  def rel_user_groups_count_group_references(target_group_id)
    n = 0
    rel_user_groups.each do |rug|
      if rug.group_id == target_group_id
        n = n + 1
      end
    end
    return n
  end
# -------------------------

  def role(group_id)
    begin
      rug = rel_user_groups_search_by_group_id(group_id)
      if rug.nil?
        role = ""
      else
        role = rug.role
      end
    rescue Exception => e
      role = ""
    end
    return role
  end

  def rel_user_groups_search_by_group_id(group_id)
    rel_user_groups.each do |rug|
      if rug.group_id == group_id
        return rug
      end
    end
    return nil
  end

  def is_multi_group_user?()
    return rel_user_groups.length > 1
  end
  
  def name_and_role_of_groups(inst_separator=",", namevsrole_separator="/")
    s = ""
    groups.each do |group|
      if (s != "") then s = s + inst_separator end
      s = s + group.short_name + namevsrole_separator + role(group.id).to_s
    end
    return s
  end
# Upgrade 2.2.0 fine
  has_many :imports

#  validates_presence_of :username, :first_name, :last_name, :role, :group_id
  validates_presence_of :password, :on => :create

  validates_uniqueness_of :username, :email
  validates_confirmation_of :password

# Upgrade 2.0.0 inizio
# validates_format_of :email, :with => Devise::EMAIL_REGEX
# validates_format_of :username, :with => /^([a-zA-Z0-9_]+)$/
  validates_format_of :email, :with => Devise::email_regexp
  validates_format_of :username, :with => /^([a-zA-Z0-9_]+)$/, :multiline => true
# Upgrade 2.0.0 fine

  validates_exclusion_of :username, :in => roles

  # Setup accessible (or protected) attributes for your model
  attr_accessor :login

# Upgrade 2.0.0 inizio
# OCIO Strong type
# attr_accessible :email, :password, :password_confirmation, :remember_me, :remember_token,
#  :remember_created_at, :group_id, :role, :active, :username, :login,
#  :first_name, :last_name, :qualifier
# Upgrade 2.0.0 fine

  squished_fields :username, :first_name, :last_name, :qualifier

# Upgrade 2.2.0 inizio
#  roles.each do |role|
#    define_method "is_#{role}?" do
#      self.role == role
#    end
#    define_method "is_at_least_#{role}?" do
#      roles.index(self.role).to_i <= roles.index(role).to_i
#    end
#  end

  roles.each do |role|
    if (role != "superadmin")
      define_method("is_#{role}?") do |group_id| 
        self.role(group_id) == role
      end
      define_method("is_at_least_#{role}?") do |group_id|
        roles.index(self.role(group_id)).to_i <= roles.index(role).to_i
      end
    end
  end

  def is_superadmin?
    rel_user_groups.each do |rug|
      if rug.role == "superadmin"
        return true
      end
    end
    return false
  end
  
  def is_admin_for_some_group?
    rel_user_groups.each do |rug|
      if rug.role == "admin"
        return true
      end
    end
    return false
  end
# Upgrade 2.2.0 fine

# Upgrade 2.0.0 inizio
# OCIO vedi devise-3.5.1\lib\devise\models\authenticatable.rb
#  def valid_for_authentication?(attributes)
#      super && active?
#  end

  def active_for_authentication?
    super && active?
  end
# Upgrade 2.0.0 fine

# Upgrade 2.2.0 inizio
=begin
  def self.filter_roles_for(role)
    case role
    when 'superadmin' then
      ROLES.select {|r| r != 'superadmin'}
    when 'admin' then
      ROLES.select {|r| r == 'author' || r == 'admin'}
    else
      ROLES.select{|r| r == role}
    end
  end
=end
  def self.filter_roles_for(role, add_empty=false)
    wrk_roles = if (add_empty) then [""] else [] end
    case role
    when 'superadmin' then
      wrk_roles = wrk_roles.concat(ROLES.select {|r| r != 'superadmin'})
    when 'admin' then
      wrk_roles = wrk_roles.concat(ROLES.select {|r| r == 'author' || r == 'admin'})
    else
      wrk_roles = wrk_roles.concat(ROLES.select {|r| r == role})
    end
		return wrk_roles
  end
# Upgrade 2.2.0 fine
	
  # Virtual attributes

  def full_name
    "#{first_name} #{last_name}"
  end

  def reverse_full_name
    "#{last_name} #{first_name}"
  end

  protected

  def self.find_for_authentication(conditions={})
    login = conditions.delete(:login)
    conditions = "username = '#{login}' OR email = '#{login}'"
# Upgrade 2.0.0 inizio
#    find(:first, :conditions => conditions)
    find_by(conditions)
# Upgrade 2.0.0 fine
  end

# Upgrade 2.2.0 inizio
  def self.known_roles(add_empty=false)		
		if (add_empty)
			ret_roles = [""]
			ROLES.each do |r|
				ret_roles.push(r)
			end
		else
			ret_roles = ROLES
		end
		return ret_roles
  end
# Upgrade 2.2.0 fine

end

