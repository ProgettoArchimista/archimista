module FondsHelper
  
# Upgrade 3.0.0 inizio
# Aggiunte azioni helper di pubblicazione e rimozione pubblicazione a cascata. Vengono automaticamente aggiornate
# anche tutte le unità, i soggetti produttori, i soggetti conservatori e gli oggetti digitali ad essi collegati
  def publish_fond(id)
    @fond = Fond.find(id)
    @fond.update_attribute(:published, true)
    @related_fonds_ids = @fond.descendant_ids
    Fond.where(:id => @related_fonds_ids).update_all(:published => true)
    @fonds_subtree_ids = @fond.subtree_ids
    related_creator_to_fond_ids = RelCreatorFond.where(:fond_id => @fonds_subtree_ids).map(&:creator_id)
    related_creators_to_fond_creator_ids = RelCreatorCreator.where(:creator_id => related_creator_to_fond_ids).map(&:related_creator_id)
    related_creator_ids = related_creator_to_fond_ids | related_creators_to_fond_creator_ids
    Creator.where(:id => related_creator_ids).update_all(:published => true)
    related_custodian_to_fond_ids = RelCustodianFond.where(:fond_id => @fonds_subtree_ids).map(&:custodian_id)
    Custodian.where(:id => related_custodian_to_fond_ids).update_all(:published => true)
    Unit.where(:fond_id => @fonds_subtree_ids).update_all(:published => true)
    @related_units_ids = Unit.where(:fond_id => @fonds_subtree_ids).map(&:id)
    DigitalObject.where(:attachable_id => id, :attachable_type => "Fond").update_all(:published => true)
    DigitalObject.where(:attachable_id => @related_units_ids, :attachable_type => "Unit").update_all(:published => true)
  end

  def unpublish_fond(id)
    @fond = Fond.find(id)
    @fond.update_attribute(:published, false)
    @related_fonds_ids = @fond.descendant_ids
    Fond.where(:id => @related_fonds_ids).update_all(:published => false)
    @fonds_subtree_ids = @fond.subtree_ids
    related_creator_to_fond_ids = RelCreatorFond.where(:fond_id => @fonds_subtree_ids).map(&:creator_id)
    related_creators_to_fond_creator_ids = RelCreatorCreator.where(:creator_id => related_creator_to_fond_ids).map(&:related_creator_id)
    related_creator_ids = related_creator_to_fond_ids | related_creators_to_fond_creator_ids
    Creator.where(:id => related_creator_ids).update_all(:published => false)
    related_custodian_to_fond_ids = RelCustodianFond.where(:fond_id => @fonds_subtree_ids).map(&:custodian_id)
    Custodian.where(:id => related_custodian_to_fond_ids).update_all(:published => false)
    Unit.where(:fond_id => @fonds_subtree_ids).update_all(:published => false)
    @related_units_ids = Unit.where(:fond_id => @fonds_subtree_ids).map(&:id)
    DigitalObject.where(:attachable_id => id, :attachable_type => "Fond").update_all(:published => false)
    DigitalObject.where(:attachable_id => @related_units_ids, :attachable_type => "Unit").update_all(:published => false)
  end
# Upgrade 3.0.0 fine

end