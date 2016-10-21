# Upgrade 2.1.0 inizio
module Sc2Restore

  def restore_d_f_s(ref_db_source)
    if ref_db_source.blank?
      unit_filter_clause = "tsk IN ('D','F','S') AND sc2_tsk IS NULL"
    else
      unit_filter_clause = "tsk IN ('D','F','S') AND sc2_tsk IS NULL AND db_source = '" + ref_db_source + "'"
    end

    # iccd_descriptions.*
    units = Unit.includes(:iccd_description).where(unit_filter_clause)
    units.each do |u|
      do_save = false

      # iccd_descriptions.ogtd accodato in units.physical_description
      if !u.iccd_description.ogtd.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "OGTD=" + u.iccd_description.ogtd)
        do_save = true
      end

      # iccd_descriptions.ogts accodato in units.physical_description
      if !u.iccd_description.ogts.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "OGTS=" + u.iccd_description.ogts)
        do_save = true
      end

      # iccd_descriptions.esc accodato in units.physical_description
      if !u.iccd_description.esc.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "ESC=" + u.iccd_description.esc)
        do_save = true
      end

      # iccd_descriptions.sgtd accodato in units.physical_description
      if !u.iccd_description.sgtd.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "SGTD=" + u.iccd_description.sgtd)
        do_save = true
      end

      # iccd_descriptions.pvc accodato in units.physical_description
      if !u.iccd_description.pvc.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "PVC=" + u.iccd_description.pvc)
        do_save = true
      end

      # iccd_descriptions.ldcn accodato in units.physical_description
      if !u.iccd_description.ldcn.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "LDCN=" + u.iccd_description.ldcn)
        do_save = true
      end

      # iccd_descriptions.ldcu accodato in units.physical_description
      if !u.iccd_description.ldcu.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "LDCU=" + u.iccd_description.ldcu)
        do_save = true
      end

      # iccd_descriptions.ldcm accodato in units.physical_description
      if !u.iccd_description.ldcm.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "LDCM=" + u.iccd_description.ldcm)
        do_save = true
      end

      if do_save
        u.save
      end
    end

    # iccd_subjects.sgti in sc2s.sgti
    units = Unit.includes(:iccd_subjects).where(unit_filter_clause)
    units.each do |u|
      first_sgti_found = false
      row_values = ""
      u.iccd_subjects.each do |s|
        if !s.sgti.blank?
          if !first_sgti_found
            sc2 = Sc2.new(unit_id: s.unit_id, sgti: s.sgti, db_source: s.db_source, legacy_id: s.legacy_id)
            sc2.save
            first_sgti_found = true
          else  
            row_values = prv_append(row_values, "\n", "SGTI=" + s.sgti)
          end
        end
      end
      if !row_values.blank?
        u.physical_description = prv_append(u.physical_description, "\n", row_values)
        u.save
      end
    end

    # iccd_tech_specs.misa, iccd_tech_specs.misl in sc2s.misa, sc2s.misl
    units = Unit.includes(:iccd_tech_spec).where(unit_filter_clause)
    units.each do |u|
      if !u.iccd_tech_spec.misa.blank? || !u.iccd_tech_spec.misl.blank?
        misa_value = u.iccd_tech_spec.misa
        misl_value = u.iccd_tech_spec.misl
        if !u.iccd_tech_spec.misu.blank?
          case u.iccd_tech_spec.misu.downcase
            when 'mm'
            when 'cm'
              misa_value = prv_convert_measure(misa_value, 10.0)
              misl_value = prv_convert_measure(misl_value, 10.0)
            when 'm'
              misa_value = prv_convert_measure(misa_value, 1000.0)
              misl_value = prv_convert_measure(misl_value, 1000.0)
            when 'px'
          end
        end

        sc2 = Sc2.where(:unit_id => u.id).first
        if sc2.nil?
          sc2 = Sc2.new(unit_id: u.id, misa: misa_value, misl: misl_value, db_source: u.db_source, legacy_id: u.legacy_id)
        else
          sc2.misa = misa_value
          sc2.misl = misl_value
        end
        sc2.save
      end
    end

    # iccd_authors.autn in sc2_authors.autn, iccd_authors.autk in sc2_authors.autr, iccd_authors.autm in sc2_attribution_reasons.autm
    units = Unit.includes(:iccd_authors).where(unit_filter_clause)
    units.each do |u|
      u.iccd_authors.each do |a|
        if !a.autn.blank? || !a.autk.blank? || !a.autm.blank?
          sc2_aut = Sc2Author.new(unit_id: a.unit_id, autn: a.autn, autr: a.autk, db_source: a.db_source, legacy_id: a.legacy_id)
          sc2_aut.save
          if !a.autm.blank?
            sc2_autm = Sc2AttributionReason.new(sc2_author_id: sc2_aut.id, autm: a.autm, db_source: a.db_source, legacy_id: a.legacy_id)
            sc2_autm.save
          end
        end
      end
    end

    # iccd_tech_specs.*
    units = Unit.includes(:iccd_tech_spec).where(unit_filter_clause)
    units.each do |u|
      do_save = false

      # iccd_tech_specs.misu accodato in units.physical_description
      if !u.iccd_tech_spec.misu.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "MISU=" + u.iccd_tech_spec.misu)
        do_save = true
      end

      # iccd_tech_specs.miss accodato in units.physical_description
      if !u.iccd_tech_spec.miss.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "MISS=" + u.iccd_tech_spec.miss)
        do_save = true
      end

      # iccd_tech_specs.mtx accodato in units.physical_description
      if !u.iccd_tech_spec.mtx.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "MTX=" + u.iccd_tech_spec.mtx)
        do_save = true
      end

      # iccd_tech_specs.mtc in units.medium
      if !u.iccd_tech_spec.mtc.blank?
        u.medium = u.iccd_tech_spec.mtc
        do_save = true
      end
      if do_save
        u.save
      end
    end

    # iccd_damages.stcs accodato in units.physical_description
    units = Unit.includes(:iccd_damages).where(unit_filter_clause)
    units.each do |u|
      row_values = ""
      u.iccd_damages.each do |d|
        if !d.stcs.blank?
          row_values = prv_append(row_values, "\n", "STCS=" + d.stcs)
        end
      end
      if !row_values.blank?
        u.physical_description = prv_append(u.physical_description, "\n", row_values)
        u.save
      end
    end

    # units.tsk in units.sc2_tsk
    units = Unit.where(unit_filter_clause)
    units.each do |u|
      u.sc2_tsk = u.tsk
      u.save
    end
  end

  def restore_bdm_oa(ref_db_source)
    if ref_db_source.blank?
      unit_filter_clause = "tsk IN ('BDM','OA') AND sc2_tsk IS NULL"
    else
      unit_filter_clause = "tsk IN ('BDM','OA') AND sc2_tsk IS NULL AND db_source = '" + ref_db_source + "'"
    end

    # iccd_descriptions.*
    units = Unit.includes(:iccd_description).where(unit_filter_clause)
    units.each do |u|
      do_save = false

      # iccd_descriptions.ogtd accodato in units.physical_description
      if !u.iccd_description.ogtd.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "OGTD=" + u.iccd_description.ogtd)
        do_save = true
      end

      # iccd_descriptions.ogts accodato in units.physical_description
      if !u.iccd_description.ogts.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "OGTS=" + u.iccd_description.ogts)
        do_save = true
      end

      # iccd_descriptions.esc accodato in units.physical_description
      if !u.iccd_description.esc.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "ESC=" + u.iccd_description.esc)
        do_save = true
      end

      # iccd_descriptions.sgtd accodato in units.physical_description
      if !u.iccd_description.sgtd.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "SGTD=" + u.iccd_description.sgtd)
        do_save = true
      end

      # iccd_descriptions.pvc accodato in units.physical_description
      if !u.iccd_description.pvc.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "PVC=" + u.iccd_description.pvc)
        do_save = true
      end

      # iccd_descriptions.ldcn accodato in units.physical_description
      if !u.iccd_description.ldcn.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "LDCN=" + u.iccd_description.ldcn)
        do_save = true
      end

      # iccd_descriptions.ldcu accodato in units.physical_description
      if !u.iccd_description.ldcu.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "LDCU=" + u.iccd_description.ldcu)
        do_save = true
      end

      # iccd_descriptions.ldcm accodato in units.physical_description
      if !u.iccd_description.ldcm.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "LDCM=" + u.iccd_description.ldcm)
        do_save = true
      end

      # iccd_descriptions.utf accodato in units.physical_description
      if !u.iccd_description.utf.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "UTF=" + u.iccd_description.utf)
        do_save = true
      end

      # iccd_descriptions.uto accodato in units.physical_description
      if !u.iccd_description.uto.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "UTO=" + u.iccd_description.uto)
        do_save = true
      end

      if do_save
        u.save
      end
    end

    # iccd_subjects.sgti accodato in units.physical_description
    units = Unit.includes(:iccd_subjects).where(unit_filter_clause)
    units.each do |u|
      row_values = ""
      u.iccd_subjects.each do |s|
        if !s.sgti.blank?
          row_values = prv_append(row_values, "\n", "SGTI=" + s.sgti)
        end
      end
      if !row_values.blank?
        u.physical_description = prv_append(u.physical_description, "\n", row_values)
        u.save
      end
    end

    # iccd_authors.autn, iccd_authors.autk, iccd_authors.autm in units.physical_description
    units = Unit.includes(:iccd_authors).where(unit_filter_clause)
    units.each do |u|
      row_values = ""
      u.iccd_authors.each do |a|
        if !a.autn.blank? || !a.autk.blank? || !a.autm.blank?
          if !a.autn.blank?
            row_values = prv_append(row_values, "\n", "AUTN=" + a.autn)
          end
          if !a.autk.blank?
            row_values = prv_append(row_values, "\n", "AUTK=" + a.autk)
          end
          if !a.autm.blank?
            row_values = prv_append(row_values, "\n", "AUTM=" + a.autm)
          end
        end
      end
      if !row_values.blank?
        u.physical_description = prv_append(u.physical_description, "\n", row_values)
        u.save
      end
    end

    # iccd_tech_specs.* in units.physical_description
    units = Unit.includes(:iccd_tech_spec).where(unit_filter_clause)
    units.each do |u|
      do_save = false

      # iccd_tech_specs.misu accodato in units.physical_description
      if !u.iccd_tech_spec.misu.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "MISU=" + u.iccd_tech_spec.misu)
        do_save = true
      end

      # iccd_tech_specs.misa accodato in units.physical_description
      if !u.iccd_tech_spec.misa.blank?
# Upgrade 2.2.0 inizio
#        u.physical_description = prv_append(u.physical_description, "\n", "MISA=" + u.iccd_tech_spec.misa)
        u.physical_description = prv_append(u.physical_description, "\n", "MISA=" + u.iccd_tech_spec.misa.to_s)
# Upgrade 2.2.0 fine
        do_save = true
      end

      # iccd_tech_specs.misa accodato in units.physical_description
      if !u.iccd_tech_spec.misl.blank?
# Upgrade 2.2.0 inizio
#        u.physical_description = prv_append(u.physical_description, "\n", "MISL=" + u.iccd_tech_spec.misl)
        u.physical_description = prv_append(u.physical_description, "\n", "MISL=" + u.iccd_tech_spec.misl.to_s)
# Upgrade 2.2.0 fine
        do_save = true
      end

      # iccd_tech_specs.miss accodato in units.physical_description
      if !u.iccd_tech_spec.miss.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "MISS=" + u.iccd_tech_spec.miss)
        do_save = true
      end

      # iccd_tech_specs.mtx accodato in units.physical_description
      if !u.iccd_tech_spec.mtx.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "MTX=" + u.iccd_tech_spec.mtx)
        do_save = true
      end

      # iccd_tech_specs.mtc accodato in units.physical_description
      if !u.iccd_tech_spec.mtc.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "MTC=" + u.iccd_tech_spec.mtc)
        do_save = true
      end

      # iccd_tech_specs.mtct accodato in units.physical_description
      if !u.iccd_tech_spec.mtct.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "MTCT=" + u.iccd_tech_spec.mtct)
        do_save = true
      end

      # iccd_tech_specs.mtcm accodato in units.physical_description
      if !u.iccd_tech_spec.mtcm.blank?
        u.physical_description = prv_append(u.physical_description, "\n", "MTCM=" + u.iccd_tech_spec.mtcm)
        do_save = true
      end

      if do_save
        u.save
      end
    end

    # iccd_damages.stcs accodato in units.physical_description
    units = Unit.includes(:iccd_damages).where(unit_filter_clause)
    units.each do |u|
      row_values = ""
      u.iccd_damages.each do |d|
        if !d.stcs.blank?
          row_values = prv_append(row_values, "\n", "STCS=" + d.stcs)
        end
      end
      if !row_values.blank?
        u.physical_description = prv_append(u.physical_description, "\n", row_values)
        u.save
      end
    end

    # units.tsk in units.sc2_tsk
    units = Unit.where(unit_filter_clause)
    units.each do |u|
      u.sc2_tsk = u.tsk
      u.save
    end
  end

private

  def prv_append(str, separator, str_append)
    if str.blank? then str = "" end
    if !str.blank? then str = str + separator end
    str = str + str_append
    return str
  end

  def prv_convert_measure(ipvalue, scale_factor)
    begin
      opvalue = ipvalue * scale_factor
    rescue Exception => e
      opvalue = ipvalue
    end
    return opvalue
  end

end

# Upgrade 2.1.0 fine
