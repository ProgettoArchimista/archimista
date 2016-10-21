class UsersController < ApplicationController

  load_and_authorize_resource
# Upgrade 2.2.0 inizio
  skip_load_and_authorize_resource :only => [ :new ]
# Upgrade 2.2.0 fine

  def index
# Upgrade 2.0.0 inizio
#    @users = User.accessible_by(current_ability, :manage).all(:order => "group_id, username", :include => :group)
# Upgrade 2.2.0 inizio
#    @users = User.accessible_by(current_ability, :manage).includes(:group).order("group_id, username")
    @users = User.accessible_by(current_ability, :manage).includes(:rel_user_groups).order("rel_user_groups.group_id, username")
# Upgrade 2.2.0 fine
# Upgrade 2.0.0 fine
    @active_users = @users.select { |u| u.active? }
    @inactive_users = @users.select { |u| u.active? == false }
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
# Upgrade 2.0.0 inizio Strong parameters
#    @user = User.new(params[:user])
    @user = User.new(user_params)
# Upgrade 2.0.0 fine

    if @user.save
      redirect_to(users_url, :notice => t('devise.messages.create_ok'))
    else
      render :action => "new"
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
# Upgrade 2.0.0 inizio Strong parameters
=begin
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      if current_user.is_at_least_admin?
        redirect_to(users_url, :notice => t('devise.messages.save_ok'))
      else
        redirect_to(root_url, :notice => t('devise.messages.save_ok'))
      end
    else
      render :action => "edit"
    end
=end
#    @user.update(user_params)
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
# Upgrade 2.2.0 inizio
=begin
      if current_user.is_at_least_admin?
        redirect_to(users_url, :notice => t('devise.messages.save_ok'))
      else
        redirect_to(root_url, :notice => t('devise.messages.save_ok'))
      end
=end
      target_url = ""
      @user.rel_user_groups.each do |rug|
        if current_user.is_at_least_admin?(rug.group_id)
          target_url = users_url
        end
      end
      if target_url == "" then target_url = root_url end
      redirect_to(target_url, :notice => t('devise.messages.save_ok'))
# Upgrade 2.2.0 fine
    else
      render :action => "edit"
    end
# Upgrade 2.0.0 fine
  end

  def toggle_active
    @user = User.find(params[:id])
    @user.toggle!(:active)

    redirect_to(users_url, :notice => t('devise.messages.save_ok'))
  end

# Upgrade 2.0.0 inizio Strong parameters
  private
    def user_params
# Upgrade 2.2.0 inizio
=begin
      wrk_params = params.dup
      rugas = wrk_params[:user][:rel_user_groups_attributes]
      wrk_params[:user].delete :rel_user_groups_attributes

      idx = 0
      rugas_new = {}
      rugas.each do |ruga|
        if str2int(ruga[1][:id]) > 0
          rugas_new = rugas_new.merge!({"#{idx}" => ruga[1]})
          idx = idx + 1
        end
      end
      wrk_params[:user].merge!(:rel_user_groups_attributes => rugas_new)
      params = wrk_params
=end
# Upgrade 2.2.0 fine
      params.require(:user).permit!
    end
# Upgrade 2.0.0 fine

end
