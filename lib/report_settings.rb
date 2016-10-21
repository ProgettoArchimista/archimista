class ReportSettings
  EntityNameSeparator = "-"
  Report_attributes_control_name_suffix = EntityNameSeparator + "report_attributes[]"
  Report_dont_use_captions_control_name_suffix = EntityNameSeparator + "cfg_dont_use_captions"

  attr_accessor :rtf_rw
  attr_accessor :report_name
  attr_accessor :report_caption
  attr_accessor :action
  attr_accessor :rtf_stylesheet_codes
  attr_accessor :entities
  attr_accessor :rtf_stylesheet_code_archimista_label

  def initialize(rtf_rw, report_name, report_caption, action, rtf_stylesheet_codes)
    @rtf_rw = rtf_rw
    @report_name = report_name
    @report_caption = report_caption
    @action = action
    @rtf_stylesheet_codes = rtf_stylesheet_codes
    @entities = Array.new()
    @rtf_stylesheet_code_archimista_label = 0
  end

  def entity_add(ers)
    @entities << ers
  end

  def entity_search_by_name(entity_name)
    ersRef = nil
    @entities.each do |ers|
      if ers.entity_name.to_s == entity_name.to_s
        ersRef = ers
        break
      end
    end
    return ersRef
  end

  def entity_has_any_selected_attributes?(entity_name)
    ers = entity_search_by_name(entity_name)
    if ers.nil?
      status = false
    else
      status = ers.has_any_selected_attributes?
    end
    return status
  end

  def report_cookie_name
    return @report_name + "_report_settings"
  end

  def initialize_entities_selected_attribute_names(params, cookies)
    arrCookieValue = nil
    cookie_name = report_cookie_name.to_s
    if cookies[cookie_name].present?
      strCookieValue = cookies[cookie_name].to_s
      arrCookieValue = strCookieValue.split(",")
    end

    @entities.each do |ers|
      if params[ers.entity_control_names_basename].present?
        selected_attribute_names = params[ers.entity_control_names_basename]
      else
        selected_attribute_names = ers.default_attribute_names
      end
      if params[ers.dont_use_fld_caption_control_name].present?
        dont_use_fld_captions = true
      else
        dont_use_fld_captions = false
      end
      if !arrCookieValue.nil?
        selected_attribute_names = []
        dont_use_fld_captions = false
        attr_prefix = ers.attribute_control_id_prefix
        arrCookieValue.each do |attr_name|
          if attr_name.start_with?(attr_prefix)
            if attr_name == ers.dont_use_fld_caption_control_name
              dont_use_fld_captions = true
            else
              attr_basename = attr_name[attr_prefix.length, attr_name.length - 1]
              if ers.attribute_search?(attr_basename)
                selected_attribute_names << attr_basename
              end
            end
          end
        end
      end
      ers.selected_attribute_names = selected_attribute_names
      ers.dont_use_fld_captions = dont_use_fld_captions
    end
  end

  def get_attribute_rtf_stylesheet_code(stylesheet_codes_key)
    begin
      code = @rtf_stylesheet_codes[stylesheet_codes_key]
    rescue
      code = GCrwStyleCurrent
    end
    return code
  end

  def make_attribute_rtf_stylesheet_codes_key(entity_name, attr_name)
    if !attr_name.nil? and attr_name != ""
      name_parts = attr_name.split(".")
      if !entity_name.nil? and entity_name != ""
        stylesheet_codes_key = entity_name + "_" + name_parts[0]
      else
        stylesheet_codes_key = name_parts[0]
      end
    else
      stylesheet_codes_key = ""
    end
    return stylesheet_codes_key
  end
end

class EntityReportSettings
  attr_accessor :entity_name
  attr_accessor :available_attributes_info
  attr_accessor :selected_attribute_names
  attr_accessor :dont_use_fld_captions

  def initialize(entity_name, available_attributes_info, dont_use_fld_captions)
    @entity_name = entity_name
    @available_attributes_info = available_attributes_info
    @selected_attribute_names = nil
    @dont_use_fld_captions = true
  end

  def attribute_search?(attr_name)
    found = false
    @available_attributes_info.each do |key, ai|
      if ai.name == attr_name
        found = true
        break
      end
    end
    return found
  end

  def has_any_selected_attributes?
    if @selected_attribute_names.nil?
      status = false
    else
      status = (@selected_attribute_names.length > 0)
    end
    return status
  end

  def default_attribute_names
    attributes_name = []
    @available_attributes_info.each do |key, ai|
      if ai.is_default
        attributes_name << ai.name
      end
    end
    return attributes_name
  end
  
  def entity_control_names
    return @entity_name.to_s + ReportSettings::Report_attributes_control_name_suffix
  end

  def entity_control_names_basename
    return entity_control_names[0..entity_control_names.length - 3]
  end

  def attribute_control_id_prefix
    return @entity_name.to_s + ReportSettings::EntityNameSeparator
  end

  def attribute_control_id_full(attr_name)
    return attribute_control_id_prefix + attr_name.to_s
  end

  def dont_use_fld_caption_control_name
    return @entity_name.to_s + ReportSettings::Report_dont_use_captions_control_name_suffix
  end
end

class AttributeInfo
  attr_accessor :name
  attr_accessor :group_tag
  attr_accessor :name_caption
  attr_accessor :group_caption
# Upgrade 2.2.0 inizio
  attr_accessor :name_caption_list_note
# Upgrade 2.2.0 fine
  attr_accessor :is_value_translation
  attr_accessor :is_default
  attr_accessor :is_multi_instance
  attr_accessor :callback

# Upgrade 2.2.0 inizio
#  def initialize(name, group_tag, name_caption, group_caption, is_value_translation, is_default, is_multi_instance, callback)
  def initialize(name, group_tag, name_caption, group_caption, name_caption_list_note, is_value_translation, is_default, is_multi_instance, callback)
# Upgrade 2.2.0 fine
    @name = name
    @group_tag = group_tag
    @name_caption = name_caption
    @group_caption = group_caption
# Upgrade 2.2.0 inizio
    @name_caption_list_note = name_caption_list_note
# Upgrade 2.2.0 fine
    @is_value_translation = is_value_translation
    @is_default = is_default
    @is_multi_instance = is_multi_instance
    @callback = callback
  end

  def composed_caption
# Upgrade 2.2.0 inizio
=begin
    if group_tag.nil?
      composed_caption = name_caption
    else
      composed_caption = group_caption + "/" + name_caption
    end
=end		
		wrk_name_caption = name_caption
		if !name_caption_list_note.nil? then wrk_name_caption = wrk_name_caption + name_caption_list_note end
    if group_tag.nil?
      composed_caption = wrk_name_caption
    else
      composed_caption = group_caption + "/" + wrk_name_caption
    end
# Upgrade 2.2.0 fine
		
    return composed_caption
  end
end