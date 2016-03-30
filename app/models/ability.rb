class Ability

  include CanCan::Ability

  def initialize(current_user)

    case current_user.role

    when "superadmin"
      can :manage, :all
      cannot [:destroy], User, :role => 'superadmin'
# Upgrade 2.1.0 inizio
#      cannot [:update, :destroy], Group, :name => 'default'
      cannot [:destroy], Group, :name => 'default'
# Upgrade 2.1.0 fine

    when "admin"
      can :manage, [Fond, Creator, Custodian, Source, DigitalObject, Institution, DocumentForm, Project, Editor, Heading, Import], :group_id => current_user.group_id
      can :manage, User, :group_id => current_user.group_id
      cannot [:update, :destroy], User, :role => 'superadmin'
# Upgrade 2.1.0 inizio
      can :manage, Group, :id => current_user.group_id
      cannot :create, Group
      can :manage, GroupImage, :group_id => current_user.group_id
# Upgrade 2.1.0 fine

    when "author"
      can :manage, [Fond, Creator, Custodian, Source, DigitalObject, Institution, DocumentForm, Project, Editor, Heading, Import], :group_id => current_user.group_id
      can :update, User, :id => current_user.id

    when "supervisor"
      can :read, :all
      can :update, User, :id => current_user.id
    end
  end

end

