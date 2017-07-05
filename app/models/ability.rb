class Ability

  include CanCan::Ability

# Upgrade 2.2.0 inizio
# Upgrade 3.0.0 inizio
  attr_accessor :target_group_id
  @target_group_id = -1

  def initialize(user, targetGroupId)
    @target_group_id = targetGroupId

    if (targetGroupId == -1)
      roles = []
      maxRole = ''
      supervisorRole = false
      user.rel_user_groups.each do |rug|
        if !roles.include?(rug.role)
          roles << rug.role
        end
      end
      if roles.include?('supervisor')
        maxRole = 'supervisor'
        supervisorRole = true
      end
      if roles.include?('author')
        maxRole = 'author'
      end
      if roles.include?('admin')
        maxRole = 'admin'
      end
      if roles.include?('superadmin')
        maxRole = 'superadmin'
      end
      roles.each do |r|
        userRelatedGroupIds = []
        user.rel_user_groups.each do |rug|
          if rug.role == r
            userRelatedGroupIds << rug.group_id
          end
        end
        if supervisorRole
          prv_initialize(user.id, r, -1, userRelatedGroupIds)
        else
          prv_initialize(user.id, maxRole, -1, userRelatedGroupIds)
        end
      end
    else
      user.rel_user_groups.each do |rug|
        if rug.group_id == targetGroupId
          prv_initialize(user.id, rug.role, rug.group_id, nil)
          break
        end
      end
    end
  end

  private

  def prv_initialize(user_id, role, group_id, userRelatedGroupIds)
    case role

    when "superadmin"
      can :manage, :all
      cannot [:destroy], User, :role => 'superadmin'
      cannot [:destroy], Group, :name => 'default'

    when "admin"
      if (group_id == -1)
        can :manage, [Fond, Creator, Custodian, Source, DigitalObject, Institution, DocumentForm, Project, Editor, Heading, Import, Unit], :group_id => userRelatedGroupIds

        can :manage, User, :rel_user_groups => { :group_id => userRelatedGroupIds }
        can :manage, RelUserGroup, :group_id => userRelatedGroupIds

        can :manage, Group, :id => userRelatedGroupIds
        cannot :create, Group
        can :manage, GroupImage, :group_id => userRelatedGroupIds
      else
        can :manage, [Fond, Creator, Custodian, Source, DigitalObject, Project, Editor, Heading, Import, Institution, DocumentForm, Unit], :group_id => group_id

        can :manage, User, :rel_user_groups => { :group_id => group_id }
        cannot [:update, :destroy], User, :rel_user_groups => { :role => 'superadmin' }

        can :manage, Group, :id => group_id
        cannot :create, Group
        can :manage, GroupImage, :group_id => group_id
      end

    when "author"
      if (group_id == -1)
        can :manage, [Fond, Creator, Custodian, Source, DigitalObject, Institution, DocumentForm, Project, Editor, Heading, Import, Unit], :group_id => userRelatedGroupIds
      else
        can :manage, [Fond, Creator, Custodian, Source, DigitalObject, Project, Editor, Heading, Import, Institution, DocumentForm, Unit], :group_id => group_id
      end
     can :update, User, :id => user_id

    when "supervisor"
    	if (group_id == -1)
        can :read, [Fond, Creator, Custodian, Source, DigitalObject, Project, Editor, Heading, Import, Institution, DocumentForm, Unit], :group_id => userRelatedGroupIds
        can :update, User, :id => user_id
      else
        can :read, [Fond, Creator, Custodian, Source, DigitalObject, Project, Editor, Heading, Import, Institution, DocumentForm, Unit], :group_id => group_id
      	can :update, User, :id => user_id
      end
    end
  end
# Upgrade 3.0.0 fine
# Upgrade 2.2.0 fine

# Upgrade 2.1.0 inizio
  def initialize_210(user)

    case user.role

    when "superadmin"
      can :manage, :all
      cannot [:destroy], User, :role => 'superadmin'
      cannot [:destroy], Group, :name => 'default'

    when "admin"
      can :manage, [Fond, Creator, Custodian, Source, DigitalObject, Institution, DocumentForm, Project, Editor, Heading, Import], :group_id => user.group_id
      can :manage, User, :group_id => user.group_id
      cannot [:update, :destroy], User, :role => 'superadmin'
      can :manage, Group, :id => user.group_id
      cannot :create, Group
      can :manage, GroupImage, :group_id => user.group_id

    when "author"
      can :manage, [Fond, Creator, Custodian, Source, DigitalObject, Institution, DocumentForm, Project, Editor, Heading, Import], :group_id => user.group_id
      can :update, User, :id => user.id

    when "supervisor"
      can :read, :all
      can :update, User, :id => user.id
    end
  end
# Upgrade 2.1.0 fine

end