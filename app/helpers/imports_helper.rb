module ImportsHelper

  def importable_type_caption(import)
    if (import.is_unit_importable_type?)
      caption = "Unità archivistiche"
    elsif (import.is_institution_importable_type?)
      caption = "Profilo istituzionale"
    elsif (import.is_anagraphic_importable_type?)
      caption = "Scheda anagrafica"
    elsif (import.is_source_importable_type?)
      caption = "Strumento di ricerca"
    else
      caption = t(import.importable_type.downcase)
    end
    return caption
  end

  def import_caption(import)
    if (import.is_unit_importable_type?)
      units_count = Unit.where({:db_source => import.identifier}).count("id")
      caption = "(#{units_count.to_s}) importate in: \"#{Fond.find(import.importable.fond_id).display_name}\""
    elsif (import.is_institution_importable_type?)
      caption = import.importable.name
    elsif (import.is_creator_importable_type? || import.is_custodian_importable_type?)
      caption = import.importable.try(:preferred_name).try(:name).to_s
      #if (caption.empty?)
      #  caption = import.importable.try(:display_name).to_s
      #end 
      if (caption.empty?)
        caption = import.importable.try(:name).to_s
      end
      if (caption.empty?)
        caption = "(Denominazione non trovata)"
      end 
    elsif (import.is_anagraphic_importable_type?)
      caption = import.importable.name
      if !import.importable.surname.nil? && !import.importable.surname.empty?
        caption += " " + import.importable.surname
      end
    elsif (import.is_source_importable_type?)
      caption = import.importable.short_title
    else
      caption = import.importable.display_name
    end
    return caption
  end
end
