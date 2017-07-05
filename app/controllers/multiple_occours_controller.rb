class MultipleOccoursController < ApplicationController
  
  # Upgrade 3.0.0 inizio
  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        if (["index"].include?(params[:action]))
        	@current_ability ||= Ability.new(current_user, -1)
        end
      end
    end
    
    if @current_ability.nil?
      @current_ability = super
    end
    return @current_ability
  end
# Upgrade 3.0.0 fine

  def index
 # FIXME: capire se accessible_by funziona con altri tipi di utenza
  	@multiple_sources = Source.accessible_by(current_ability, :read).group(:short_title).having("COUNT(*)>1").map(&:short_title)
  end

  def merge
    @source_choosen = Source.find("#{params[:id]}")
    @multiple_sources_ids = Source.where("id != #{params[:id]} AND short_title LIKE '#{@source_choosen.short_title}'").map(&:id)
    @failed = false
    rel_creator_sources_merge
    rel_custodian_sources_merge
    rel_unit_sources_merge
    rel_fond_sources_merge
    source_merge

    if @failed == false
      flash[:notice] = t('delete_ok')
      redirect_to multiple_occours_url
    else
      flash[:alert] = t('delete_ko')
      redirect_to multiple_occours_url
    end   
  end

  def source_merge
    SourceUrl.where(:source_id => @multiple_sources_ids).destroy_all
    DigitalObject.where(:attachable_id => @multiple_sources_ids, :attachable_type => 'Source').destroy_all
    Source.delete(@multiple_sources_ids)
  end

  def rel_creator_sources_merge
    @failed = true
    @relCreatorSources = RelCreatorSource.all
    @originalSourceArray = Array.new
    @relatedSourceArray = Array.new
    @finalRelatedSourceArray = Array.new
    @deleteRelatedSourceArrayIds = Array.new

# Separazione degli oggetti RelCreatorSource: original contiene gli oggetti associati alla fonte selezionata,
# related contiene gli oggetti associati alle fonti ritenute duplicati della fonte selezionata.
# I restanti oggetti non vengono presi in considerazione
    @relCreatorSources.each do |relCreator|     
      if relCreator.source_id == params[:id].to_i
        @originalSourceArray.push(relCreator)
      elsif @multiple_sources_ids.include? relCreator.source_id
        @relatedSourceArray.push(relCreator)
      end
    end

# In caso di relazioni già presenti per la fonte selezionata, si eliminano dal processo possibili relazioni duplicate
# provenienti dalle fonti ritenute duplicate
    if @originalSourceArray.length > 0
      @originalCreatorArrayIds = Array.new
      @originalSourceArray.each do |originalElements|
        @originalCreatorArrayIds.push(originalElements.creator_id)
      end
      @originalCreatorArrayIds.each do |originalCreatorId|
        @relatedSourceArray.each do |relElement|
          if relElement.creator_id == originalCreatorId and @multiple_sources_ids.include? relElement.source_id
            @relatedSourceArray.delete(relElement)
            @deleteRelatedSourceArrayIds.push(relElement.id)
          end
        end
      end
    end

# Controllo delle relazioni rimanenti: potrebbero essere duplicati tra essi stessi.
    if @relatedSourceArray.length > 1
      @finalRelatedSourceArray = @relatedSourceArray.uniq{ |x| x.creator_id}
    end
    @deleteRelatedSourceArrayIds = @deleteRelatedSourceArrayIds + (@relatedSourceArray - @finalRelatedSourceArray).map(&:id)
    @updateRelatedSourceIds = @finalRelatedSourceArray.map(&:id)

# Eliminazione dei duplicati
    if @deleteRelatedSourceArrayIds.length > 0
      RelCreatorSource.delete(@deleteRelatedSourceArrayIds)
    end
# Aggiornamento relazioni verso fonte selezionata
    if @updateRelatedSourceIds.length > 0
      RelCreatorSource.where(:id => @updateRelatedSourceIds).update_all(:source_id => params[:id])
    end
    @failed = false
  end

  def rel_custodian_sources_merge
    @failed = true
    @relCustodianSources = RelCustodianSource.all
    @originalSourceArray = Array.new
    @relatedSourceArray = Array.new
    @finalRelatedSourceArray = Array.new
    @deleteRelatedSourceArrayIds = Array.new

# Separazione degli oggetti RelCustodianSource: original contiene gli oggetti associati alla fonte selezionata,
# related contiene gli oggetti associati alle fonti ritenute duplicati della fonte selezionata.
# I restanti oggetti non vengono presi in considerazione
    @relCustodianSources.each do |relCustodian|     
      if relCustodian.source_id == params[:id].to_i
        @originalSourceArray.push(relCustodian)
      elsif @multiple_sources_ids.include? relCustodian.source_id
        @relatedSourceArray.push(relCustodian)
      end
    end

# In caso di relazioni già presenti per la fonte selezionata, si eliminano dal processo possibili relazioni duplicate
# provenienti dalle fonti ritenute duplicate
    if @originalSourceArray.length > 0
      @originalCustodianArrayIds = Array.new
      @originalSourceArray.each do |originalElements|
        @originalCustodianArrayIds.push(originalElements.custodian_id)
      end
      @originalCustodianArrayIds.each do |originalCustodianId|
        @relatedSourceArray.each do |relElement|
          if relElement.custodian_id == originalCustodianId and @multiple_sources_ids.include? relElement.source_id
            @relatedSourceArray.delete(relElement)
            @deleteRelatedSourceArrayIds.push(relElement.id)
          end
        end
      end
    end

# Controllo delle relazioni rimanenti: potrebbero essere duplicati tra essi stessi.
    if @relatedSourceArray.length > 1
      @finalRelatedSourceArray = @relatedSourceArray.uniq{ |x| x.custodian_id}
    end
    @deleteRelatedSourceArrayIds = @deleteRelatedSourceArrayIds + (@relatedSourceArray - @finalRelatedSourceArray).map(&:id)
    @updateRelatedSourceIds = @finalRelatedSourceArray.map(&:id)

# Eliminazione dei duplicati
    if @deleteRelatedSourceArrayIds.length > 0
      RelCustodianSource.delete(@deleteRelatedSourceArrayIds)
    end
# Aggiornamento relazioni verso fonte selezionata
    if @updateRelatedSourceIds.length > 0
      RelCustodianSource.where(:id => @updateRelatedSourceIds).update_all(:source_id => params[:id])
    end
    @failed = false
  end

  def rel_unit_sources_merge
    @failed = true
    @relUnitSources = RelUnitSource.all
    @originalSourceArray = Array.new
    @relatedSourceArray = Array.new
    @finalRelatedSourceArray = Array.new
    @deleteRelatedSourceArrayIds = Array.new

# Separazione degli oggetti RelUnitSource: original contiene gli oggetti associati alla fonte selezionata,
# related contiene gli oggetti associati alle fonti ritenute duplicati della fonte selezionata.
# I restanti oggetti non vengono presi in considerazione
    @relUnitSources.each do |relUnit|     
      if relUnit.source_id == params[:id].to_i
        @originalSourceArray.push(relUnit)
      elsif @multiple_sources_ids.include? relUnit.source_id
        @relatedSourceArray.push(relUnit)
      end
    end

# In caso di relazioni già presenti per la fonte selezionata, si eliminano dal processo possibili relazioni duplicate
# provenienti dalle fonti ritenute duplicate
    if @originalSourceArray.length > 0
      @originalUnitArrayIds = Array.new
      @originalSourceArray.each do |originalElements|
        @originalUnitArrayIds.push(originalElements.unit_id)
      end
      @originalUnitArrayIds.each do |originalUnitId|
        @relatedSourceArray.each do |relElement|
          if relElement.unit_id == originalUnitId and @multiple_sources_ids.include? relElement.source_id
            @relatedSourceArray.delete(relElement)
            @deleteRelatedSourceArrayIds.push(relElement.id)
          end
        end
      end
    end

# Controllo delle relazioni rimanenti: potrebbero essere duplicati tra essi stessi.
    if @relatedSourceArray.length > 1
      @finalRelatedSourceArray = @relatedSourceArray.uniq{ |x| x.unit_id}
    end
    @deleteRelatedSourceArrayIds = @deleteRelatedSourceArrayIds + (@relatedSourceArray - @finalRelatedSourceArray).map(&:id)
    @updateRelatedSourceIds = @finalRelatedSourceArray.map(&:id)

# Eliminazione dei duplicati
    if @deleteRelatedSourceArrayIds.length > 0
      RelUnitSource.delete(@deleteRelatedSourceArrayIds)
    end
# Aggiornamento relazioni verso fonte selezionata
    if @updateRelatedSourceIds.length > 0
      RelUnitSource.where(:id => @updateRelatedSourceIds).update_all(:source_id => params[:id])
    end
    @failed = false
  end  

  def rel_fond_sources_merge
    @failed = true
    @relFondSources = RelFondSource.all
    @originalSourceArray = Array.new
    @relatedSourceArray = Array.new
    @finalRelatedSourceArray = Array.new
    @deleteRelatedSourceArrayIds = Array.new

# Separazione degli oggetti RelFondSource: original contiene gli oggetti associati alla fonte selezionata,
# related contiene gli oggetti associati alle fonti ritenute duplicati della fonte selezionata.
# I restanti oggetti non vengono presi in considerazione
    @relFondSources.each do |relFond|     
      if relFond.source_id == params[:id].to_i
        @originalSourceArray.push(relFond)
      elsif @multiple_sources_ids.include? relFond.source_id
        @relatedSourceArray.push(relFond)
      end
    end

# In caso di relazioni già presenti per la fonte selezionata, si eliminano dal processo possibili relazioni duplicate
# provenienti dalle fonti ritenute duplicate
    if @originalSourceArray.length > 0
      @originalFondArrayIds = Array.new
      @originalSourceArray.each do |originalElements|
        @originalFondArrayIds.push(originalElements.fond_id)
      end
      @originalFondArrayIds.each do |originalFondId|
        @relatedSourceArray.each do |relElement|
          if relElement.fond_id == originalFondId and @multiple_sources_ids.include? relElement.source_id
            @relatedSourceArray.delete(relElement)
            @deleteRelatedSourceArrayIds.push(relElement.id)
          end
        end
      end
    end

# Controllo delle relazioni rimanenti: potrebbero essere duplicati tra essi stessi.
    if @relatedSourceArray.length > 1
      @finalRelatedSourceArray = @relatedSourceArray.uniq{ |x| x.fond_id}
    end
    @deleteRelatedSourceArrayIds = @deleteRelatedSourceArrayIds + (@relatedSourceArray - @finalRelatedSourceArray).map(&:id)
    @updateRelatedSourceIds = @finalRelatedSourceArray.map(&:id)

# Eliminazione dei duplicati
    if @deleteRelatedSourceArrayIds.length > 0
      RelFondSource.delete(@deleteRelatedSourceArrayIds)
    end
# Aggiornamento relazioni verso fonte selezionata
    if @updateRelatedSourceIds.length > 0
      RelFondSource.where(:id => @updateRelatedSourceIds).update_all(:source_id => params[:id])
    end
    @failed = false
  end
end
