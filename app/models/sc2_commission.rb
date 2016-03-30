# Upgrade 2.1.0 inizio
class Sc2Commission < ActiveRecord::Base
  belongs_to :unit

  has_many :sc2_commission_names, :dependent => :destroy

# nella soluzione che non usa sc2_commission_names_reject_if) non si cancella il record nel db con la seguente sequenza: salvo un record con un valore, poi lo svuoto nell'interfaccia senza usare il check per la cancellazione e salvo. Ma è un problema per tutti i campi ripetitivi di archimista, non solo per cmmn. E' più giusto usando sc2_commission_names_reject_if, ma si dovrebbe estendere anche a tutti gli altri casi. Per il momento si lascia la soluzione semplice e si fa in modoe che venga usato il check per cancellare i record vuoti
  accepts_nested_attributes_for :sc2_commission_names, :allow_destroy => true, :reject_if => proc { |a| a['cmmn'].blank? }
#  accepts_nested_attributes_for :sc2_commission_names, :allow_destroy => true, :reject_if => :sc2_commission_names_reject_if
  def sc2_commission_names_reject_if(attributes)
    exists = attributes[:id].present?
    empty = attributes[:cmmn].blank?
    attributes.merge!({_destroy: 1}) if exists and empty
    return (!exists and empty)
  end

end
# Upgrade 2.1.0 fine
