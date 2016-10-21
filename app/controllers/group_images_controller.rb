# Upgrade 2.1.0 inizio
class GroupImagesController < ApplicationController
  helper_method :sort_column
  helper_method :group_image_type_is_carousel?
  before_filter :prv_require_image_magick, :except => [:disabled]

# Upgrade 2.2.0 inizio
  load_and_authorize_resource
  skip_load_and_authorize_resource :only => [ :create ]

  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        if (["edit","update","destroy"].include?(params[:action]))
          gi = GroupImage.select("group_id").find(params[:id])
          @current_ability ||= Ability.new(current_user, gi.group_id)
        elsif (["all"].include?(params[:action]))
          @current_ability ||= Ability.new(current_user, -1)
        elsif (["new","create","index"].include?(params[:action]))
          if params[:group_id].present?
            group_id = str2int(params[:group_id])
            @current_ability ||= Ability.new(current_user, group_id)
          end
        end
      end
    end
    if @current_ability.nil?
      @current_ability = super
    end
    return @current_ability
  end
# Upgrade 2.2.0 fine

  def all
    @group_images = GroupImage.accessible_by(current_ability, :read).includes(:group).order(sort_column + ' ' + prv_sort_direction).page(params[:page])
  end

  def index
    @group = Group.find(params[:group_id])
		@group_image_type  = prv_get_group_image_type
    @group_images = prv_get_group_images_list(@group, @group_image_type).accessible_by(current_ability, :read).order("position").page(params[:page])
  end

  def new
    @group = Group.find(params[:group_id])
    if params[:type] == "carousel"
      @group_image = GroupCarouselImage.new
    else
      @group_image = GroupLogoImage.new
    end
  end

  def edit
    @group = Group.find(params[:group_id])
    @group_image = GroupImage.find(params[:id])
  end

  def create
    @group = Group.find(params[:group_id])
    @group_image = prv_get_group_images_list(@group, prv_get_group_image_type).build(prv_group_image_params).tap do |group_image|
      group_image.related_group_id = params[:group_id]
      group_image.created_by = current_user.id
      group_image.updated_by = current_user.id
# Upgrade 2.2.0 inizio
#      group_image.group_id = current_user.group_id
        if current_user.is_multi_group_user?()
          group_image.group_id = current_ability.target_group_id
        else
          group_image.group_id = current_user.rel_user_groups[0].group_id
        end
# Upgrade 2.2.0 fine
    end

    respond_to do |format|
      if @group_image.save
        format.html {
          render :json => [@group_image.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
      else
        format.html { render :json => @group_image.errors }
      end
    end
  end

  def update
    @group = Group.find(params[:group_id])
    @group_image = GroupImage.find(params[:id]).tap do |group_image|
      group_image.updated_by = current_user.id
    end

    if @group_image.update_attributes(prv_group_image_params)
      flash[:notice] = "Scheda modificata"
      redirect_to @group_image.group_group_images_path(@group)
    else
      render :action => "edit"
    end
  end

  def sort
    params["list"].each_with_index do |id, position|
      GroupImage.where("id = #{id}").update_all("position = #{position + 1}")
    end
    render :nothing => true
  end

  def bulk_destroy
    GroupImage.destroy_all({:id => params["group_image_ids"]})
    render :nothing => true
  end

  def destroy
    @group_image = GroupImage.find(params[:id])
    redirect = if request.referrer.split("/").last == "edit"
      group = Group.find(@group_image.related_group_id)
      @group_image.group_group_images_path(group)
    else
      request.referrer
    end
    @group_image.destroy

    if request.xhr?
      render :nothing => true
    else
      redirect_to redirect, :notice => "Oggetto digitale eliminato"
    end

  end

	def group_image_type_is_carousel?(group_image_type)
		return group_image_type == "carousel"
	end

  def sort_column
    params[:sort] || "updated_at"
  end
	
private

  def prv_sort_direction
    params[:direction] || "desc"
  end

  def prv_require_image_magick
    unless IM_ENABLED
      redirect_to disabled_group_images_url
    end
  end

	def prv_get_group_image_type
    return params[:type]
	end

	def prv_get_group_images_list(group, group_image_type)
    if group_image_type_is_carousel?(group_image_type)
      group_images_list = group.carousel_images
    else
      group_images_list = group.logo_images
    end
		return group_images_list
	end

	def prv_group_image_params
		params.require(:group_image).permit!
	end
end
# Upgrade 2.0.0 fine
