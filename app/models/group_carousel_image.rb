# Upgrade 2.0.0 inizio
class GroupCarouselImage < GroupImage
  has_attached_file :asset,
      :styles => { :carousel => '920x920>', :thumb => '130x130>' },
      :url => '/group_images/:access_token/:style.:extension',
      :default_url => "/images/group_image_missing-:style.jpg"
end
# Upgrade 2.0.0 fine
