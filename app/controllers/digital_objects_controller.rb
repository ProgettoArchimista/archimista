class DigitalObjectsController < ApplicationController
  helper_method :sort_column
  before_filter :require_image_magick, :except => [:disabled]
  load_and_authorize_resource

# Upgrade 2.2.0 inizio

  skip_load_and_authorize_resource :only => [ :all ]

  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        group_id = -1
        if (["destroy"].include?(params[:action]))
          group_id = DigitalObject.find(params[:id]).group_id
        elsif (["bulk_destroy"].include?(params[:action]))
          if params["digital_object_ids"].present?
            if params["digital_object_ids"].length > 0
              group_id = DigitalObject.find(params["digital_object_ids"][0]).group_id
            end
          end
        else
          @attachable = find_attachable
          if !@attachable.nil?
            begin
              if @attachable.class.name.to_s == "Unit"
                group_id = Fond.find(@attachable.fond_id).group_id
              else
                group_id = @attachable.group_id
              end
            rescue Exception => e
              group_id = -1
            end
          end
        end
        if group_id != -1
          @current_ability ||= Ability.new(current_user, group_id)
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
# Upgrade 2.0.0 inizio
=begin
    @digital_objects = DigitalObject.accessible_by(current_ability, :read).
      paginate(:include => :attachable, :page => params[:page],
      :order => sort_column + ' ' + sort_direction).
      delete_if {|o| o.attachable.nil? || (o.attachable.has_attribute?("sequence_number") && o.attachable.sequence_number.nil?) }
=end
# Upgrade 2.2.0 inizio
=begin
    @digital_objects = DigitalObject.accessible_by(current_ability, :read).
      includes(:attachable).
      order(sort_column + ' ' + sort_direction).page(params[:page]).
      to_a.
      delete_if {|o| o.attachable.nil? || (o.attachable.has_attribute?("sequence_number") && o.attachable.sequence_number.nil?) }
=end
    @digital_objects = DigitalObject.accessible_by(current_ability, :read).
      joins(:group).
      includes(:attachable).
      order(sort_column + ' ' + sort_direction).page(params[:page]).
      to_a.
      delete_if {|o| o.attachable.nil? || (o.attachable.has_attribute?("sequence_number") && o.attachable.sequence_number.nil?) }
# Upgrade 2.2.0 fine
# Upgrade 2.0.0 fine

    # FIXME: retrieving del path di fonds/units è query intensive. Ma per ora teniamocelo...
  end

  # Polymorphic association - nested resource
  # Riferimento: http://asciicasts.com/episodes/154-polymorphic-association
  def index
    @attachable = find_attachable
# Upgrade 2.0.0 inizio
=begin
    @digital_objects = @attachable.digital_objects.accessible_by(current_ability, :read).
      paginate(:page => params[:page],
      :order => "position")
=end
    @digital_objects = @attachable.digital_objects.accessible_by(current_ability, :read).order("position").page(params[:page])
# Upgrade 2.0.0 fine
  end

  def new
    @attachable = find_attachable
    @digital_object = DigitalObject.new
  end

  def edit
    @attachable = find_attachable
    @digital_object = DigitalObject.find(params[:id])
  end

  def create
    @attachable = find_attachable
# Upgrade 2.0.0 inizio Strong parameters
=begin
    @digital_object = @attachable.digital_objects.build(params[:digital_object]).tap do |digital_object|
      digital_object.created_by = current_user.id
      digital_object.updated_by = current_user.id
      digital_object.group_id = current_user.group_id
    end
=end
    @digital_object = @attachable.digital_objects.build(digital_object_params).tap do |digital_object|
      digital_object.created_by = current_user.id
      digital_object.updated_by = current_user.id
# Upgrade 2.2.0 inizio
#      digital_object.group_id = current_user.group_id
        if current_user.is_multi_group_user?()
          digital_object.group_id = current_ability.target_group_id
        else
          digital_object.group_id = current_user.rel_user_groups[0].group_id
        end
# Upgrade 2.2.0 fine
			
    end
# Upgrade 2.0.0 fine

    respond_to do |format|
      if @digital_object.save
        format.html {
          render :json => [@digital_object.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
      else
        format.html { render :json => @digital_object.errors }
      end
    end
  end

  def update
    @attachable = find_attachable
    @digital_object = DigitalObject.find(params[:id]).tap do |digital_object|
      digital_object.updated_by = current_user.id
    end

# Upgrade 2.0.0 inizio Strong parameters
=begin
    if @digital_object.update_attributes(params[:digital_object])
      flash[:notice] = "Oggetto digitale modificato"
      redirect_to polymorphic_url([@attachable, "digital_objects"])
    else
      render :action => "edit"
    end
=end
    if @digital_object.update_attributes(digital_object_params)
      flash[:notice] = "Oggetto digitale modificato"
      redirect_to polymorphic_url([@attachable, "digital_objects"])
    else
      render :action => "edit"
    end
# Upgrade 2.0.0 fine
  end

  def sort
    params["list"].each_with_index do |id, position|
# Upgrade 2.0.0 inizio
#      DigitalObject.update_all("position = #{position + 1}", "id = #{id}")
      DigitalObject.where("id = #{id}").update_all("position = #{position + 1}")
# Upgrade 2.0.0 fine
    end
    render :nothing => true
  end

  def bulk_destroy
    DigitalObject.destroy_all({:id => params["digital_object_ids"]})
    render :nothing => true
  end

  def destroy
    @digital_object = DigitalObject.find(params[:id])
    redirect = if request.referrer.split("/").last == "edit"
      @attachable = @digital_object.attachable
      polymorphic_url([@attachable, "digital_objects"])
    else
      request.referrer
    end
    @digital_object.destroy

    if request.xhr?
      render :nothing => true
    else
      redirect_to redirect, :notice => "Oggetto digitale eliminato"
    end

  end

  private

  def find_attachable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end

  def sort_column
    params[:sort] || "updated_at"
  end

  def sort_direction
    params[:direction] || "desc"
  end

  def require_image_magick
    unless IM_ENABLED
      redirect_to disabled_digital_objects_url
    end
  end

# Upgrade 2.0.0 inizio Strong parameters
private
    def digital_object_params
      params.require(:digital_object).permit!
    end
# Upgrade 2.0.0 fine

end
