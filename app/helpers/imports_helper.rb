# Upgrade 2.2.0 inizio
module ImportsHelper

  def importable_type_caption(import)
		if (import.is_unit_importable_type?)
			caption = "Unità archivistiche"
		else
			caption = t(import.importable_type.downcase)
		end
		return caption
  end

  def import_caption(import)
		if (import.is_unit_importable_type?)
			units_count = Unit.where({:db_source => import.identifier}).count("id")
			caption = "(#{units_count.to_s}) importate in: \"#{Fond.find(import.importable.fond_id).display_name}\""
		else
			caption = import.importable.display_name
		end
		return caption
  end

end
# Upgrade 2.2.0 fine