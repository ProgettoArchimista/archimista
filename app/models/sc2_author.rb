# Upgrade 2.1.0 inizio
class Sc2Author < ActiveRecord::Base
  belongs_to :unit

  has_many :sc2_attribution_reasons, :dependent => :destroy

	accepts_nested_attributes_for :sc2_attribution_reasons, :allow_destroy => true, :reject_if => :sc2_attribution_reasons_reject_if

  def sc2_attribution_reasons_reject_if(attributes)
    exists = attributes[:id].present?
    empty = attributes[:autm].blank?
    attributes.merge!({_destroy: 1}) if exists and empty
    return (!exists and empty)
  end

end
# Upgrade 2.1.0 fine
