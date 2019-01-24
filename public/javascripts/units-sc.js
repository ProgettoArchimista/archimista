/* Upgrade 2.1.0 inizio */
var mcUnitTypeControlId = "unit_unit_type";
var mcSc2TypeControlId = "unit_sc2_tsk";
var mcUnitFileTypeControlId = "unit_file_type";
var mcSc2TypeLabelId = "lbl_unit_sc2_tsk";
var mcFscTypeLabelId = "lbl_unit_fsc";
var mcOpenedVocEmptyValue = "[Vuoto]";

$(document).ready(
  function()
  {
    try
    {
      //
      $(".sc2_openedvoc_link").on("click", function() { pbl_openedvoc_open($(this)); } );
      $('#sc2-openvoc-dialog').on("hidden", function () { prv_openedvoc_empty(); });

      //
      $("#" + mcUnitTypeControlId).on("change", prv_unit_type_change);
      $("#" + mcSc2TypeControlId).on("change", prv_unit_sc2_tsk_change);
      $("#" + mcUnitFileTypeControlId).on("change", prv_unit_fsc_change);

      if (prv_is_unit_documentaria($("#" + mcUnitTypeControlId)))
      {
        prv_get_unit_fascicolo_container().hide();
        prv_get_lbl_unit_fascicolo_container().hide(); 
        prv_get_unit_sc2_tsk_container().show();
        prv_get_lbl_unit_sc2_tsk_container().show();
      }
      else
      {
        prv_get_unit_sc2_tsk_container().hide();
        prv_get_lbl_unit_sc2_tsk_container().hide();

        if (prv_is_unit_fascicolo($("#" + mcUnitTypeControlId))){
          prv_get_unit_fascicolo_container().show();
          prv_get_lbl_unit_fascicolo_container().show();
        }else{
          prv_get_unit_fascicolo_container().hide();
          prv_get_lbl_unit_fascicolo_container().hide();
        }
      }
      prv_unit_sc2_tsk_change();
      prv_unit_fsc_change();
      prv_fsc_compiled();
    }
    catch (e)
    {
      prv_error("ready", e);
    }
  }
);

function prv_fsc_compiled(){
  organization = $("#unit_fsc_organizations");

  organization.find(".fsc_field").each(
      function()
      {
        if($(this).val() == ""){
          organization.hide();
        }else{
          organization.show();
        }
      }
    );

  nationality = $("#unit_fsc_nationalities");

  nationality.find(".fsc_field").each(
      function()
      {
        if($(this).val() == ""){
          nationality.hide();
        }else{
          nationality.show();
        }
      }
    );

  code = $("#unit_fsc_codes");

  code.find(".fsc_field").each(
      function()
      {
        if($(this).val() == ""){
          code.hide();
        }else{
          code.show();
        }
      }
    );

  open = $("#unit_fsc_opens");

  open.find(".fsc_field").each(
      function()
      {
        if($(this).val() == ""){
          open.hide();
        }else{
          open.show();
        }
      }
    );

  close = $("#unit_fsc_closes");

  close.find(".fsc_field").each(
      function()
      {
        if($(this).val() == ""){
          close.hide();
        }else{
          close.show();
        }
      }
    );

  
}

function prv_unit_type_change()
{
  try
  {
    if (prv_is_unit_documentaria($("#" + mcUnitTypeControlId)))
    {
      prv_get_unit_fascicolo_container().hide();
      prv_get_lbl_unit_fascicolo_container().hide();
      $("#" + mcUnitFileTypeControlId).val("");
      prv_get_unit_sc2_tsk_container().show();
      prv_get_lbl_unit_sc2_tsk_container().show();
    }
    else
    {
      prv_get_unit_sc2_tsk_container().hide();
      prv_get_lbl_unit_sc2_tsk_container().hide();

      $("#" + mcSc2TypeControlId).val("");

      if (prv_is_unit_fascicolo($("#" + mcUnitTypeControlId))){
        prv_get_unit_fascicolo_container().show();
        prv_get_lbl_unit_fascicolo_container().show();
      }else{
        prv_get_unit_fascicolo_container().hide();
        prv_get_lbl_unit_fascicolo_container().hide();
        $("#" + mcUnitFileTypeControlId).val("");
      }
    }
    prv_unit_sc2_tsk_change();
    prv_unit_fsc_change();
  }
  catch (e)
  {
    prv_error("prv_unit_type_change", e);
  }
}

function prv_unit_sc2_tsk_change()
{
  var jqCtl;
  var jqCtlValue;
  var jqCtlPhysicalType;
  try
  {
    jqCtlPhysicalType = $("#div_physical_type_wrapper");

    jqCtl = $("#" + mcSc2TypeControlId);
    jqCtlValue = jqCtl.val().toLowerCase();
    if (jqCtlValue == "")
    {
      jqCtlPhysicalType.show();
      $(".sc2_container").each(
        function()
        {
          if (!prv_is_unit_sc2_tsk_container($(this)) && !prv_is_lbl_unit_sc2_tsk_container($(this))) prv_hide_and_clean($(this));
        }
      );
    }
    else
    {
      jqCtlPhysicalType.val("");
      jqCtlPhysicalType.hide();
      
      $(".sc2_container").each(
        function()
        {
          if (!prv_is_unit_sc2_tsk_container($(this)) && !prv_is_lbl_unit_sc2_tsk_container($(this)))
          {
            if ($(this).hasClass("sc2_all") || $(this).hasClass("sc2_" + jqCtlValue))
              prv_show_and_build($(this));
            else
              prv_hide_and_clean($(this));
          }
        }
      );
      $(".sc2_openedvoc_link").each(
        function()
        {
          if ($(this).hasClass("sc2_all") || $(this).hasClass("sc2_" + jqCtlValue))
            $(this).show();
          else
            $(this).hide();
        }
      );
    }
  }
  catch (e)
  {
    prv_error("prv_unit_sc2_tsk_change", e);
  }
}

function prv_unit_fsc_change()
{
  var jqCtl;
  var jqCtlValue;
  try
  {
    jqCtl = $("#" + mcUnitFileTypeControlId);
    jqCtlValue = jqCtl.val().toLowerCase();
    if (jqCtlValue == "")
    {
      $(".fsc_container").each(
        function()
        {
          if (!prv_is_unit_fascicolo_container($(this)) && !prv_is_lbl_unit_fascicolo_container($(this))) prv_fsc_hide_and_clean($(this));
        }
      );

      $(".fe_container").each(
        function()
        {
          if (!prv_is_unit_edilizia_container($(this))) prv_fe_hide_and_clean($(this));
        }
      );
    }
    else
    {
      if(new RegExp("personale").test(jqCtlValue)){
        $(".fe_container").each(
          function()
          {
            if (!prv_is_unit_edilizia_container($(this))) prv_fe_hide_and_clean($(this));
          }
        );
        $(".fsc_container").each(
          function()
          {
            if (!prv_is_unit_fascicolo_container($(this)) && !prv_is_lbl_unit_fascicolo_container($(this)))
            {
              if ($(this).hasClass("fsc_container")){
                prv_show_and_build($(this));
              }
              else{
                prv_hide_and_clean($(this));
              }
            }
          }
        );
      }else{
        $(".fsc_container").each(
          function()
          {
            if (!prv_is_unit_fascicolo_container($(this)) && !prv_is_lbl_unit_fascicolo_container($(this))) prv_fsc_hide_and_clean($(this));
          }
        );
        $(".fe_container").each(
          function()
          {
            if (!prv_is_unit_edilizia_container($(this)))
            {
              if ($(this).hasClass("fe_container")){
                prv_show_and_build($(this));
              }
              else{
                prv_hide_and_clean($(this));
              }
            }
          }
        );
      }
      
    }
  }
  catch (e)
  {
    prv_error("prv_unit_fsc_change", e);
  }
}

function prv_is_unit_documentaria(jqCtl)
{
  var status;
  try
  {
    status = new RegExp("unit.* documentaria").test(jqCtl.val());
  }
  catch(e)
  {
    status = false;
  }
  return status;
}

function prv_is_unit_fascicolo(jqCtl)
{
  var status;
  try
  {
    status = new RegExp("fascicolo").test(jqCtl.val());
  }
  catch(e)
  {
    status = false;
  }
  return status;
}

function prv_is_unit_sc2_tsk_container(jqCtl)
{
  var is_target;

  try
  {
    is_target = false;
    jqCtl.find(".sc2_field").each(function() { if ($(this).attr("id") == mcSc2TypeControlId) { is_target = true; } } );
  }
  catch (e)
  {
    is_target = false;
  }
  return is_target;
}

function prv_is_unit_fascicolo_container(jqCtl)
{
  var is_target;
  try
  {
    is_target = false;
    jqCtl.find(".fsc_field").each(function() { 
      if ($(this).attr("id") == mcUnitFileTypeControlId) { is_target = true; } } );
  }
  catch (e)
  {
    is_target = false;
  }
  return is_target;
}

function prv_is_unit_edilizia_container(jqCtl)
{
  var is_target;
  try
  {
    is_target = false;
    jqCtl.find(".fe_field").each(function() { 
      if ($(this).attr("id") == mcUnitFileTypeControlId) { is_target = true; } } );
  }
  catch (e)
  {
    is_target = false;
  }
  return is_target;
}

function prv_is_lbl_unit_sc2_tsk_container(jqCtl)
{
  var is_target;

  try
  {
    is_target = false;
    jqCtl.find(".sc2_field_label").each(function() { if ($(this).attr("id") == mcSc2TypeLabelId) { is_target = true; } } );
  }
  catch (e)
  {
    is_target = false;
  }
  return is_target;
}

function prv_is_lbl_unit_fascicolo_container(jqCtl)
{
  var is_target;

  try
  {
    is_target = false;
    jqCtl.find(".fsc_field_label").each(function() {
     if ($(this).attr("id") == mcFscTypeLabelId) { is_target = true; } } );
  }
  catch (e)
  {
    is_target = false;
  }
  return is_target;
}

function prv_get_unit_sc2_tsk_container()
{
  var jqCtl;

  jqCtl = null;
  $(".sc2_container").each(
    function()
    {
      if (prv_is_unit_sc2_tsk_container($(this))) { jqCtl = $(this); return false; }
    }
  );
  return jqCtl;
}

function prv_get_unit_fascicolo_container()
{
  var jqCtl;
  jqCtl = null;
  $(".fsc_container").each(
    function()
    {
      if (prv_is_unit_fascicolo_container($(this))) { jqCtl = $(this); return false; }
    }
  );
  return jqCtl;
}

function prv_get_unit_edilizia_container()
{
  var jqCtl;
  jqCtl = null;
  $(".fe_container").each(
    function()
    {
      if (prv_is_unit_edilizia_container($(this))) { jqCtl = $(this); return false; }
    }
  );
  return jqCtl;
}

function prv_get_lbl_unit_sc2_tsk_container()
{
  var jqCtl;

  jqCtl = null;
  $(".sc2_container").each(
    function()
    {
      if (prv_is_lbl_unit_sc2_tsk_container($(this))) { jqCtl = $(this); return false; }
    }
  );
  return jqCtl;
}

function prv_get_lbl_unit_fascicolo_container()
{
  var jqCtl;

  jqCtl = null;
  $(".fsc_container").each(
    function()
    {
      if (prv_is_lbl_unit_fascicolo_container($(this))) { jqCtl = $(this); return false; }
    }
  );
  return jqCtl;
}

function prv_hide_and_clean(jqCtl)
{
  try
  {
    jqCtl.find(".sc2_field").each(
      function()
      {
        if ($(this).attr("id") != mcSc2TypeControlId)
          $(this).val("");
      }
    );

    if (jqCtl.hasClass("sc2_multi_instance"))
    {
      jqCtl.find("input[type=checkbox]").each(
        function()
        {
          $(this).attr('checked', 'checked');
        }
      );
    }
    jqCtl.hide();
  }
  catch (e)
  {
    prv_error("prv_hide_and_clean", e);
  }
}

function prv_fsc_hide_and_clean(jqCtl)
{
  try
  {
    jqCtl.find(".fsc_field").each(
      function()
      {
        if ($(this).attr("id") != mcUnitFileTypeControlId)
          $(this).val("");
      }
    );

    jqCtl.hide();
  }
  catch (e)
  {
    prv_error("prv_fsc_hide_and_clean", e);
  }
}

function prv_fe_hide_and_clean(jqCtl)
{
  try
  {
    jqCtl.find(".fe_field").each(
      function()
      {
        if ($(this).attr("id") != mcUnitFileTypeControlId){
          if($(this).is(":checked") == true){
            $(this).prop("checked", false);  
          }
          $(this).val("");
        }
      }
    );

    jqCtl.hide();
  }
  catch (e)
  {
    prv_error("prv_fe_hide_and_clean", e);
  }
}

function prv_show_and_build(jqCtl)
{
  var voc_scope;
  
  try
  {
    if (jqCtl.hasClass("sc2_multi_instance"))
    {
      jqCtl.find("input[type=checkbox]").each(
        function()
        {
          $(this).removeAttr('checked');
        }
      );
    }
    
    voc_scope = $("#" + mcSc2TypeControlId).val();    
    if (voc_scope != null && voc_scope != "")
    {
      jqCtl.find(".sc2_closedvoc").each(
        function()
        {
          var jqCtlName;
          var voc_name;
          
          try
          {
            jqCtlName = $(this);
            voc_name = jqCtlName.attr("data_voc_name");
            if (voc_name != null)
            {
              $.ajax({
                url: prv_make_voc_url(jqCtlName, voc_name, voc_scope),
                data: {},
                dataType: "json",
                success: function (data) { prv_closedvoc_update(jqCtlName, data); },
                error: function (data) { prv_closedvoc_empty(jqCtlName); }
              });
            }
          }
          catch (e)
          {
            prv_error("prv_show_and_build sc2_closedvoc:" + e.message);
          }
        }
      );
    }

    jqCtl.show();
  }
  catch (e)
  {
    prv_error("prv_show_and_build", e);
  }
}

function prv_fsc_show_and_build(jqCtl)
{
    jqCtl.show();
}

/* ------------------------------------------------- */
function prv_closedvoc_update(jqCtlSelect, vocData)
{
  var i;
  var curr_value;
  try
  {
    curr_value = jqCtlSelect.val();
    prv_closedvoc_empty(jqCtlSelect);
    if (vocData.status == "success")
    {
      for (i = 0; i < vocData.values.length; i++)
      {
        if (curr_value == vocData.values[i].term_key)
          jqCtlSelect.append($("<option></option>").attr("value", vocData.values[i].term_key).attr("selected", "selected").text(vocData.values[i].term_value));
        else
          jqCtlSelect.append($("<option></option>").attr("value", vocData.values[i].term_key).text(vocData.values[i].term_value));
      }
    }
  }
  catch (e)
  {
    prv_error("prv_closedvoc_update" + e.message);
  }
}

function prv_closedvoc_empty(jqCtlSelect)
{
  try
  {
    jqCtlSelect.find("option").remove();
  }
  catch (e)
  {   
  }
}

/* ------------------------------------------------- */
function pbl_openedvoc_open(jqCtlVocTrigger)
{
  var jqDialog;
  var jqCtlVocValue;
  var jqCtlParent;
  var voc_caption;
  var voc_scope;
  var voc_name;

  try
  {
    voc_scope = $("#" + mcSc2TypeControlId).val();
    voc_name = jqCtlVocTrigger.attr("data_voc_name");
    if (voc_name != null)
    {
      $("#lblInfo").text("Caricamento dei dati in corso");
      $("#divInfo").show();

      if (voc_scope == "F" && voc_name == "units.medium")
        voc_caption = "Il campo intende supporto e tecnica. Termini previsti per la compilazione del campo \"supporto e tecnica\"";
      else
        voc_caption = "Termini previsti per la compilazione del campo \"" + jqCtlVocTrigger.attr("data_voc_caption") + "\"";
      $("#lblVocCaption").text(voc_caption);

      jqDialog = $('#sc2-openvoc-dialog').modal({backdrop: "static"});
      $(".modal-backdrop").css("background-color", "#CCCCCC");
      jqDialog.show();

      jqCtlParent = jqCtlVocTrigger.parent();
      if (jqCtlParent.hasClass("sc2_openedvoc_link_right_side"))
        jqCtlVocValue = jqCtlParent.prev().find(".sc2_voc");
      else
        jqCtlVocValue = jqCtlParent.next();

      prv_openedvoc_empty();
      $.ajax({
        url: prv_make_voc_url(jqCtlVocTrigger, voc_name, voc_scope),
        data: {},
        dataType: "json",
        success: function (data) { prv_openedvoc_fill(jqCtlVocValue, $("#tblValues"), data); },
        error: function (data) { $("#lblInfo").text("Errore durante il caricamento dei dati."); }
      });
    }
  }
  catch (e)
  {
    prv_error("pbl_openedvoc_open", e);
  }
}

function prv_openedvoc_fill(jqCtlVocValue, jqCtlTblValues, vocData)
{
  var html_stmt;
  var voc_value;
  var i;

  try
  {
    if (vocData.status == "success")
    {
      for (i = 0; i < vocData.values.length; i++)
      {
        if (vocData.values[i].term_value == ""){
          voc_value = mcOpenedVocEmptyValue;
        }
        else{
          if(fsc_types[vocData.values[i].term_key] != null){
            voc_value = fsc_types[vocData.values[i].term_key];
            if(i == 3){
              html_header = "<tr><td><h3 class=\"row-header\">Fascicolo dipendente</h3></td></tr>"
              jqCtlTblValues.append(html_header);
            } 
          }else {
            voc_value = vocData.values[i].term_key; 
          }
          
        }
        // html_stmt = "<tr><td><a href=\"#\" >" + voc_value + "</a></td></tr>";
        html_stmt = "<tr><td><a href=\"javascript:void(0)\" >" + voc_value + "</a></td></tr>";
        jqCtlTblValues.append(html_stmt);
      }
      $("#tblValues a").on("click", function() { prv_opened_voc_item_select(jqCtlVocValue, $(this), jqCtlTblValues); } );
    }
    $("#lblInfo").text("");
    $("#divInfo").hide();
  }
  catch (e)
  {
    prv_error("prv_openedvoc_fill" + e.message);
  }
}

function prv_openedvoc_empty()
{
  try
  {
    $("#tblValues").empty();
  }
  catch (e)
  {
  }
}

function prv_openedvoc_close(jqCtlTblValues)
{
  try
  {
    $('#sc2-openvoc-dialog').modal('hide');
  }
  catch (e)
  {
  }
}

function prv_opened_voc_item_select(jqCtlVocValue, jqCtlSelected, jqCtlTblValues)
{
  var voc_value;
  try
  {

    voc_value = jqCtlSelected.text();
    if (voc_value == mcOpenedVocEmptyValue) voc_value = "";

    if (jqCtlVocValue.context.getAttribute("data_voc_name").match(/field_type/) != null){
      switch(true){
        case /Organizzazione/.test(voc_value):
          $('#unit_fsc_organizations').show();
          break;
        case /Nazionalit/.test(voc_value):
          $('#unit_fsc_nationalities').show();
          break;
        case /Codice/.test(voc_value):
          $('#unit_fsc_codes').show();
          break;
        case /apertura/.test(voc_value):
          $('#unit_fsc_opens').show();
          break;
        case /chiusura/.test(voc_value):
          $('#unit_fsc_closes').show();
          break;
        default:
          console.log("no values")
          break;
      }      

    }else{
      jqCtlVocValue.val(voc_value);
    }

    
    prv_openedvoc_close(jqCtlTblValues);
  }
  catch (e)
  {
    prv_error(prv_opened_voc_item_select, e);
  }
}

/* ------------------------------------------------- */
function prv_make_voc_url(jqCtlReference, voc_name, voc_scope)
{
  var url;
  try
  {
    url = "/units/sc2_voc_list?voc=" + voc_name;
    if (voc_scope != null) url = url + "&scope=" + voc_scope;
    if (jqCtlReference.hasClass("sc2_voc_add_empty")) url = url + "&add_empty=1";
  }
  catch (e)
  {
  }
  return url;
}

function prv_error(msg_context, e)
{
  alert(msg_context + " - Errore: " + e.message);
}

/* Upgrade 2.1.0 fine */