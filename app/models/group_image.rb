# Upgrade 2.1.0 inizio
class GroupImage < ActiveRecord::Base
  include Rails.application.routes.url_helpers 

  cattr_reader :per_page
  @@per_page = 50

  belongs_to :group, :foreign_key => "related_group_id"
  belongs_to :updater, :class_name => "User", :foreign_key => "updated_by"

  acts_as_list

  before_create :generate_access_token

  # Paperclip
  has_attached_file :asset,
    :styles => { :thumb => '130x130>' },
    :url => '/group_images/:access_token/:style.:extension',
    :default_url => "/images/group_image_missing-:style.jpg"


  validates_attachment_presence :asset

  validates_attachment_content_type :asset, :content_type => ["image/jpeg", "image/jpg", "image/pjpeg"]

  validates_attachment_size :asset, :less_than => 8.megabytes

  before_post_process :is_image?

  # Methods
  def self.is_enabled?
    begin
      img = "#{Rails.root}/public/images/image_magick.jpg"
      Paperclip.run("identify", '"'+img+'"') # :-/ I hate MS Win
    rescue
      return false
    end
    return true
  end

  def is_image?
    ["image/jpeg", "image/jpg", "image/pjpeg"].include?(asset.content_type)
  end

  def is_video?
    return false
  end

  def is_carousel?
    return type == "GroupCarouselImage"
  end

  def is_logo?
    return type == "GroupLogoImage"
  end

  def to_jq_upload
    thumbnail_url = asset.url(:thumb)

    {
      "name" => read_attribute(:asset_file_name),
      "size" => read_attribute(:asset_file_size),
      "content_type" => read_attribute(:asset_content_type),
      "url" => asset.url(:original),
      "thumbnail_url" => thumbnail_url,
      "delete_url" => group_image_path(self),
      "delete_type" => "DELETE",
      "title" => title,
      "description" => description
    }
  end

  # wrappers degli helper methods
  def group_group_images_path(group)
    # group_group_carousel_images_path(group), group_group_logo_images_path(group)
    return self.send("group_#{self.class.name.underscore}s_path", group)
  end

  def new_group_group_image_path(group)
    # new_group_group_carousel_image_path(group), new_group_group_logo_image_path(group)
    return self.send("new_group_#{self.class.name.underscore}_path", group)
  end

  def edit_group_group_image_path(group)
    # edit_group_group_carousel_image_path(group), edit_group_group_logo_image_path(group)
    return self.send("edit_group_#{self.class.name.underscore}_path", group, self)
  end

  def group_image_description_field_key
    return is_carousel? ? "group_image_carousel_description" : "group_image_logo_url"
  end
  # fine wrappers

  private

  def generate_access_token
    self.access_token = Digest::SHA1.hexdigest("#{asset_file_name}#{Time.now.to_i}")
  end

  Paperclip.interpolates :access_token  do |attachment, style|
    attachment.instance.access_token
  end
end
# Upgrade 2.1.0 fine
