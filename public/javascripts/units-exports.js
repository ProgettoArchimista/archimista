/* Upgrade 2.2.0 inizio */
var gvExportUnitsSettings;

$(document).ready(function(){
  $("#chk-do-not-paginate-units").on("click", 
    function()
    {
      var form;
      
      try
      {
        form = $("#form-units-filter");
        form.submit();
      }
      catch (e)
      {
      }
    }
  );
  $("#chk-select-top-level-units").on("click", 
    function()
    {
      var form;
      
      try
      {
        form = $("#form-units-filter");
        form.submit();
      }
      catch (e)
      {
      }
    }
  );

  gvExportUnitsSettings = ExportUnitsSettingsInit();

  $("#confirm-mass-export").click(
    function(event)
    {
      try
      {
        gvExportUnitsSettings.export_units_ajax(event);
      }
      catch (e)
      {
      }
    }
  );
});

function ExportUnitsSettingsInit()
{
  var settings;

  try
  {   
    settings = {};
    
    settings.dialog = $("#mass-export-modal");
    settings.selected_checkboxes = function ()
    {
      return $("input:checkbox.selected-record-id").filter(":checked");
    };
    settings.export_units_ajax = function(event)
    {
      var unit_ids;
      try
      {
        settings.dialog.modal('hide');
        
				unit_ids = [];
        settings.selected_checkboxes().each(function(index, checkbox) { unit_ids[index] = $(checkbox).val(); } );

        event.preventDefault();
        $.blockUI({ message: 'Esportazione in corso...' });
        $.ajax({
          url: '/exports/units.json',
					type: 'POST',
          data: {
            ref_fond_id: parseInt($("#mass-export").attr("ref_fond_id")),
						unit_ids: unit_ids
          },
          dataType: 'json',
          success: function (data) {
            var tokens, file, data_file, metadata_file;
            $.unblockUI();
            tokens = data["dest_file"].split('/');
            file = tokens[tokens.length - 1];

            tokens = data["data_file"].split('/');
            data_file = tokens[tokens.length - 1];

            tokens = data["metadata_file"].split('/');
            metadata_file = tokens[tokens.length - 1];

            $(window.location).attr('href', "/exports/download?file=" + file + "&data=" + data_file + "&meta=" + metadata_file);
          }
        });
      }
      catch(e)
      {
      }
    };
    //verifiche sulla fattibilità dell'export
    settings.check_selected = function()
    {
      return (settings.selected_checkboxes().length > 0)
    }
    settings.check_first_level_fond = function()
    {
      var fid;
      var status;
      
      try
      {
        status = true;
        
        fid = "";
        settings.selected_checkboxes().each(
          function(chk_index, checkbox)
          {
            if (chk_index == 0)
              fid = $(checkbox).attr("fid");
            else
            {
              if (fid != $(checkbox).attr("fid"))
                status = false;
            }
          }
        );
      }
      catch (e)
      {
        status = false;
      }
      return status;
    };
    settings.check_units_hierarchy = function()
    {
      var unit_ids;
      var unit_pids;
      var pids_index;
      var ids_index;
      var pid;
      var status;
      try
      {
				unit_ids = [];
				unit_pids = [];
        pids_index = 0;
        settings.selected_checkboxes().each(
          function(chk_index, checkbox)
          {
            var pid;
            
            unit_ids[chk_index] = $(checkbox).val();
            
            pid = $(checkbox).attr("pid");
            if (pid != "") unit_pids[pids_index++] = pid;
          }
        );
        
        for (pids_index=0; pids_index < unit_pids.length; pids_index++)
        {
          pid = unit_pids[pids_index];
          for (ids_index=0; ids_index < unit_ids.length; ids_index++)
            if (unit_ids[ids_index] == pid) break;
          if (ids_index == unit_ids.length) break;
        }
        if (pids_index == unit_pids.length)
          status = true;
        else
          status = false;
      }
      catch (e)
      {
        status = false;
      }
      return status;
    };
    
    // ------------------------------------
    settings.dialog.on('shown',
      function()
      {
        var status1;
        var status2;
        var status3;
        
        status1 = settings.check_selected();
        status2 = settings.check_first_level_fond();
        status3 = settings.check_units_hierarchy();
        if (status1 && status2 && status3)
        {
          $("#confirm-msg-area").show();
          $("#confirm-mass-export").show();
          $("#error-msg-area").hide();
        }
        else
        {
          if (!status1)
            err_msg = "<p>Non è possibile effettuare l'esportazione perché non sono state selezionate le unità.</p>";
          else if (!status2)
            err_msg = "<p>Non è possibile effettuare l'esportazione perché le unità selezionate non appartengono tutte allo stesso complesso.</p>";
          else if (!status3)
            err_msg = "<p>Non è possibile effettuare l'esportazione perché sono state selezionate sotto-unità o sotto-sotto-unità senza la rispettiva unità di livello superiore.</p>";

          $("#confirm-msg-area").hide();
          $("#confirm-mass-export").hide();
          $("#error-msg-area").html(err_msg);
          $("#error-msg-area").show();
        }
      }
    );
  }
  catch (e)
  {
  }
  return settings;
}
/* Upgrade 2.2.0 fine */