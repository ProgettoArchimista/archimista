class UsersController < ApplicationController

  load_and_authorize_resource

  def index
# Upgrade 2.0.0 inizio
#    @users = User.accessible_by(current_ability, :manage).all(:order => "group_id, username", :include => :group)
    @users = User.accessible_by(current_ability, :manage).includes(:group).order("group_id, username")
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
    @user.update(user_params)
    if @user.update_attributes(user_params)
      if current_user.is_at_least_admin?
        redirect_to(users_url, :notice => t('devise.messages.save_ok'))
      else
        redirect_to(root_url, :notice => t('devise.messages.save_ok'))
      end
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
      params.require(:user).permit!
    end
# Upgrade 2.0.0 fine

end
