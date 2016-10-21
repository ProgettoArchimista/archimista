/* Validare file js con jshint */

$(document).ready(function() {
  // Alerts
  setTimeout(function(){
    $(".alert-success").fadeOut('slow', function() {});
  }, 2000);

  // jQuery UI: Archimate defaults
  // OPTIMIZE: diventerà inutile una volta dismessi i dialog JqueryUI
  $.extend($.ui.dialog.prototype.options, {
    autoOpen: false,
    modal: true,
    position: ['center', 140],
    resizable: false,
    show: 'fade'
  });

  // BlockUI: Archimate defaults
  // OPTIMIZE: da rivedere + i18n

  $.blockUI.defaults.applyPlatformOpacityRules = false; // show overlay in Firefox on Linux
  $.blockUI.defaults.draggable = false;
  $.blockUI.defaults.overlayCSS.backgroundColor = "#000";
  $.blockUI.defaults.overlayCSS.opacity = 0.2;
  $.blockUI.defaults.centerX = true;
  $.blockUI.defaults.centerY = false;
  $.blockUI.defaults.css.top = '180px';
  $.blockUI.defaults.message = null;
  $.blockUI.defaults.baseZ = 9000; // z-index for the blocking overlay; default: 1000

  // DON'T GO AWAY WITHOUT SAVE

  $(function () {
    // FIXME: non innescare askConfirm per le form che non eseguono azioni di save (search, import, ecc.)
    $('form:not(".skip-prompt") :input').bind('change', function () {
      $("#fond-preview").addClass("disabled"); // solo in fonds/treeview
      askConfirm(true);
    });
    $('input[type="submit"]').click(function() {
      $("#fond-preview").removeClass("disabled");
      askConfirm(false);
    });
    // FIXME: verificare attentamente funzionamento askConfirm in fonds/treeview
    // FIXME: askConfirm si deve innescare anche quando si agisce sulle relations
    // (l'interazione con queste talvolta prescinde da elementi di form, ma si attua mediante link "aggiungi" / "rimuovi")
    // OPTIMIZE: modal al posto di browser dialog (?)

    function askConfirm(on) {
      window.onbeforeunload = (on) ? confirmMessage : null;
    }

    function confirmMessage() {
      return '';
    }

    window.onerror = UnspecifiedErrorHandler;
    function UnspecifiedErrorHandler() {
      return true;
    }
  });

  // Forms: prevent double-click of submit inputs (and buttons equivalent to submit inputs)
  $(document).on("click", 'input[type="submit"], button.submit', function(event){
    if ($(this).hasClass("disabled")) {
      return false;
    } else {
      $(this).clone().insertAfter($(this)).prop("disabled", true).addClass("disabled");
      $(this).hide();
    }
  });

  // FONDS

  function validatesPresenceOf(name) {
    if (name.replace(/\s/g, "") === "") {
      $(".inline-msg").show();
      return false;
    } else {
      return true;
    }
  }

  $("#create_fond").click(function() {
    var name = $("#fond_name").val();
    var group_id = $("#fond_group_id").val();
    var sequence_number = $("#fond_sequence_number").val();
    var validForm = true;
    validForm = validForm && validatesPresenceOf(name);

    if (validForm) {
      $.ajax({
        url: "/fonds/ajax_create",
        dataType: "json",
        type: "POST",
        data: '{"fond": { "name": "' + name + '", "group_id": "' + group_id + '", "sequence_number": "' + sequence_number + '"} }',
        processData: true,
        contentType: "application/json",
        success: function(data, textStatus, jqXHR){
          var final_status = jQuery.parseJSON(jqXHR.responseText);
          if (final_status.status === "failure") {
            return false;
          } else {
            window.location = "/fonds/" + final_status.id + "/treeview";
            $('#add_fond_modal').modal('hide');
          }
          $(":input","#add_fond_modal").val("");
          $(".inline-msg").hide();
          $(".alert").replaceWith("<div id=\"fond_form_error\"></div>");
        }
      });
    }
  });

  $(".close_fond").click(function() {
    $(":input","#add_fond_modal").val("");
    $(".inline-msg").hide();
    $(".alert").replaceWith("<div id=\"fond_form_error\"></div>");
  });


/* Upgrade 2.2.0 inizio */
  $("#user-form").submit(function (e) { return user_form_submit(); } );
  function user_form_submit()
  {
    try
    {
      if (!user_form_check_group_relation())
      {
        alert("Deve esistere almeno un gruppo per il quale è impostato un ruolo non vuoto");
        return false;
      }
      user_form_manage_destroy_attribute();
    }
    catch (e)
    {
    }
    return true;
  }
  function user_form_check_group_relation()
  {
    var jqWs;
    var status;
    try
    {
      jqWs = $(".user_group_role");
      if (jqWs.length > 0)
      {
        status = false;
        jqWs.each(
          function()
          {
            if (!status && $(this).val() != "")
              status = true;
          }
        );
      }
      else
        status = true;
    }
    catch(e)
    {
      status = false;
    }
    return status;
  }
  function user_form_manage_destroy_attribute()
  {
    var jqWs;
    try
    {
      jqWs = $(".user_group_role");
      jqWs.each(
        function()
        {
          if ($(this).val() == "")
          {
            var jqCtlDestroy;
            var refId;

            refId = $(this).attr("id").split("_role").join("_destroy");
            jqCtlDestroy = $("#" + refId);
            jqCtlDestroy.val("1");
          }
        }
      );
    }
    catch(e)
    {
    }
  }


  $("#create_creator").click(
    function()
    {
      var group_id = $("#creator_group_id").val();
      var creator_creator_type = $("#creator_creator_type").val();

      window.location = "/creators/new?type=" + creator_creator_type + "&group_id=" + group_id;
      $('#add_creator_modal').modal('hide');
    }
  );
  $("#create_custodian").click(
    function()
    {
      var group_id = $("#custodian_group_id").val();

      window.location = "/custodians/new?group_id=" + group_id;
      $('#select_custodian_group_modal').modal('hide');
    }
  );
  $("#create_editor").click(
    function()
    {
      var group_id = $("#editor_group_id").val();

      window.location = "/editors/new?group_id=" + group_id;
      $('#select_editor_group_modal').modal('hide');
    }
  );
  $("#create_source").click(
    function()
    {
      var group_id = $("#source_group_id").val();
      var source_source_type = $("#source_new_source_type_code").val();

      window.location = "/sources/new?type=" + source_source_type + "&group_id=" + group_id;
      $('#add_source_modal').modal('hide');
    }
  );
  $("#create_project").click(
    function()
    {
      var group_id = $("#project_group_id").val();

      window.location = "/projects/new?group_id=" + group_id;
      $('#select_project_group_modal').modal('hide');
    }
  );
  $("#create_institution").click(
    function()
    {
      var group_id = $("#institution_group_id").val();

      window.location = "/institutions/new?group_id=" + group_id;
      $('#select_institution_group_modal').modal('hide');
    }
  );
  $("#create_document_form").click(
    function()
    {
      var group_id = $("#document_form_group_id").val();

      window.location = "/document_forms/new?group_id=" + group_id;
      $('#select_document_form_group_modal').modal('hide');
    }
  );
  $("#create_heading").click(
    function()
    {
      var group_id = $("#heading_group_id").val();

      window.location = "/headings/new?group_id=" + group_id;
      $('#select_heading_group_modal').modal('hide');
    }
  );
/* Upgrade 2.2.0 fine */

  // EDITORS

  $("#add-editor-modal").click(function(){
/* Upgrade 2.2.0 inizio */
    var group_id = $("#group_id").val();
    var url;
    if (group_id != null)
      url = "/editors/modal_new?group_id=" + group_id;
    else
      url = "/editors/modal_new";
/* Upgrade 2.2.0 fine */
    $.get(url).success(function(data){
      $('#add-editor-container').html(data);
      $('#add-editor-container #add-editor-dialog').modal("show");
    });
    return false;
  });

  $(document).delegate('#create-editor-btn', 'click', function(event){
    $.post('/editors/modal_create',
      $('#new-editor-form').serialize(),
      function(data){
        if (data.status === "success") {
          $('#add-editor-dialog').modal("hide");
        } else {
          $("#editor_form_error").
          html('<div class="alert alert-error"><a class="close" data-dismiss="alert">×</a>' + data.msg + '.</div>');
        }
      },'json');
    event.stopImmediatePropagation();
  });

  $(document).delegate(".datepicker", 'click', function(){
    $(this).removeClass('hasDatepicker').datepicker({
      dateFormat: 'yy-mm-dd',
      changeMonth: true,
      changeYear: true
    }).focus();
  });

  // UNITS
  $('#unit_tsk').change(function() {
    window.location = window.location.href.split('?')[0] + "?t=" + this.value;
  });

  $('#create_reference_number').click(function(){
    if($('#unit_folder_number').val() === "" || $('#unit_file_number').val() === "") {
      alert("I campi Busta e Fascicolo non devono essere vuoti");
      return false;
    }
/* Upgrade 2.2.0 inizio */
    //$("#unit_reference_number").attr("value","b. " + $('#unit_folder_number').val() + ", fasc. " +$('#unit_file_number').val());
    var folder_number_prefix;
    var file_number_prefix;
    folder_number_prefix = gvCreateUnitReferenceNumberSettings.folder_number_prefix_get();
    file_number_prefix = gvCreateUnitReferenceNumberSettings.file_number_prefix_get();
    $("#unit_reference_number").attr("value",folder_number_prefix + $('#unit_folder_number').val() + ", " + file_number_prefix +$('#unit_file_number').val());
/* Upgrade 2.2.0 fine */
    return false;
  });

  // SOURCES
  $('#source_source_type_code').change(function() {
    window.location = window.location.href.split('?')[0] + "?type=" + this.value;
  });

  // COMMON FEATURES and ARCHIDATE
  $('.disabled').attr("disabled", true);

  $(".archidate-wrapper").archidate();

  $('.autocomplete').archimate_autocomplete_setup();

  $("#template-selector").change(function(event){
    $("#template-text").val($(this).val());
  });

  // CLONE NESTED ATTRIBUTES
  // OPTIMIZE: la funzione clone può essere estratta e condivisa come quella di autocomplete
/* Upgrade 2.1.0 inizio */
  $('form a.add_child').click( function() { add_child_click($(this)); } );
	
  function add_child_click(jqCtl)
	{
		var new_index = new Date().getTime();
    var data_assoc = jqCtl.attr('data-association');
    var new_fields_$ = $('#' + data_assoc).find('.fields:first').clone();
		
		var new_fields_to_be_removed = new_fields_$.find("input[type=hidden][id$='_id']");
		new_fields_to_be_removed.each(function() { $(this).remove(); } );
		
		var inner_sc2_containers_fields_to_be_removed = new_fields_$.find(".sc2_container .fields:not(:first)");
		inner_sc2_containers_fields_to_be_removed.each(function() { $(this).remove(); } );

		new_fields_$.find(".sc2_container").attr('id',
			function()
			{
				if ($(this).attr('id'))
				{
					return $(this).attr('id').replace(/(\d+)(?![a-zA-Z-_\[\]]*\d+)/, new_index);
				}
			}
		);
		new_fields_$.find(".add_child").attr('data-association',
			function()
			{
				if ($(this).attr('data-association'))
				{
					return $(this).attr('data-association').replace(/(\d+)(?![a-zA-Z-_\[\]]*\d+)/, new_index);
				}
			}
		);
		new_fields_$.find(".add_child").each(function() { $(this).click(function() { add_child_click($(this)); } ) } );
		new_fields_$.find(".sc2_openedvoc_link").each(function() { $(this).click(function() { pbl_openedvoc_open($(this)); } ) } );
		
		var replace_reference_string;
		if (jqCtl.attr('replace_reference') == null)
			replace_reference_string = null;
		else
			replace_reference_string = jqCtl.attr('replace_reference');
		
    new_fields_$.find('label, input, select, textarea')
    .attr('for', function(){
      if ($(this).attr('for')) {
				return prv_adjust_attribute($(this).attr('for'), new_index, replace_reference_string);
      }
    } )
    .attr('id', function(){
      if ($(this).attr('id')) {
				return prv_adjust_attribute($(this).attr('id'), new_index, replace_reference_string);
      }
    } )
    .attr('name', function(){
      if ($(this).attr('name')) {
				return prv_adjust_attribute($(this).attr('name'), new_index, replace_reference_string);
      }
    } );

    new_fields_$.find('input:text, select, input:file').attr('value', '');
    new_fields_$.find('input:checkbox').attr('checked', false).attr('aria-pressed', false);

    new_fields_$.find('select').each(function(){
      var options = $(this).find('option');
      options.removeAttr('selected');
      options.first().attr('selected', true);
    });

    new_fields_$.find('textarea').empty();

    new_fields_$.find('.autocomplete').archimate_autocomplete_setup();
    jqCtl.parent().before(new_fields_$);

  }
	
	function prv_adjust_attribute(ip_value, new_index, replace_reference_string)
	{
		var op_value;
		var p;
		
		try
		{
			if (replace_reference_string == null)
			{
				op_value = ip_value.replace(/(\d+)(?![a-zA-Z-_\[\]]*\d+)/, new_index);
			}
			else
			{
				p = ip_value.indexOf(replace_reference_string);
				if (p >= 0)
				{
					p += replace_reference_string.length;
					op_value = ip_value.substr(0, p) + ip_value.substr(p).replace(/\d+/, new_index);					
				}
				else
					op_value = ip_value;
			}
		}
		catch (e)
		{
			op_value = ip_value;
		}
		return op_value;
	}
/* Upgrade 2.1.0 fine */
	
  $('.textile').markItUp(mySettings,{});

  // DIGITAL OBJECTS

  $("a.fancybox").fancybox({
    'padding': 5,
    'centerOnScroll': true
  });

  function fancyTitle(title, currentArray, currentIndex, currentOpts) {
    return '<span id="fancybox-title-over">' + (currentIndex + 1) + ' / ' + currentArray.length + '</span>';
  }

  $("a.fancybox-gallery").fancybox({
    'padding': 5,
    'titlePosition': 'over',
    'titleFormat': fancyTitle,
    'centerOnScroll': true
  });

  $("#digital-objects-warning").popover({
    title: "Oggetti digitali non disponibili",
    content: "Per accedere a questa funzionalità è necessario installare il programma ImageMagick.",
    placement: 'bottom'
  });

});

/*
  OPTIMIZE: quando c'è tempo e dopo attenta verifica, sostituire live() con delegate().
  "As of jQuery 1.7, the .live() method is deprecated. Use .on() to attach event handlers.
  Users of older versions of jQuery should use .delegate() in preference to .live()."
*/

