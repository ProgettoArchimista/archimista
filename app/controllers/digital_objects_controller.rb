class DigitalObjectsController < ApplicationController
  helper_method :sort_column
  before_filter :require_image_magick, :except => [:disabled]
  load_and_authorize_resource

  def all
# Upgrade 2.0.0 inizio
=begin
    @digital_objects = DigitalObject.accessible_by(current_ability, :read).
      paginate(:include => :attachable, :page => params[:page],
      :order => sort_column + ' ' + sort_direction).
      delete_if {|o| o.attachable.nil? || (o.attachable.has_attribute?("sequence_number") && o.attachable.sequence_number.nil?) }
=end
    @digital_objects = DigitalObject.accessible_by(current_ability, :read).
      includes(:attachable).
      order(sort_column + ' ' + sort_direction).page(params[:page]).
      to_a.
      delete_if {|o| o.attachable.nil? || (o.attachable.has_attribute?("sequence_number") && o.attachable.sequence_number.nil?) }
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
      digital_object.group_id = current_user.group_id
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
