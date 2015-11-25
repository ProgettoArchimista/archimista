class User < ActiveRecord::Base

  extend Cleaner

# Upgrade 2.0.0 inizio
#  devise :database_authenticatable, :rememberable
  devise :database_authenticatable, :rememberable, :encryptable
# Upgrade 2.0.0 fine

  ROLES = ['superadmin', 'admin', 'author', 'supervisor']
  roles = ROLES

  belongs_to :group
  has_many :imports

  validates_presence_of :username, :first_name, :last_name, :role, :group_id
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

  roles.each do |role|
    define_method "is_#{role}?" do
      self.role == role
    end

    define_method "is_at_least_#{role}?" do
      roles.index(self.role).to_i <= roles.index(role).to_i
    end
  end

# Upgrade 2.0.0 inizio
# OCIO vedi devise-3.5.1\lib\devise\models\authenticatable.rb
#  def valid_for_authentication?(attributes)
#      super && active?
#  end

  def active_for_authentication?
    super && active?
  end

# Upgrade 2.0.0 fine

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

end

