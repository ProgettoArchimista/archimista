/* Upgrade 2.2.0 inizio */
var gvCreateUnitReferenceNumberSettings;

$(document).ready(
  function()
  {
    gvCreateUnitReferenceNumberSettings = CreateUnitReferenceNumberSettingsInit();
  }
);

function CreateUnitReferenceNumberSettingsInit()
{
  var settings;
  
  try
  {
    settings = {};
    
    settings.folder_number_prefix_cookie_name = "archimista_unit_folder_number_prefix";
    settings.file_number_prefix_cookie_name = "archimista_unit_file_number_prefix";
    settings.folder_number_prefix_default_get = "b. ";
    settings.file_number_prefix_default_get = "fasc. ";
    
    settings.dialog = $("#create-unit-reference-number-options-dialog");
    
    settings.folder_number_prefix_get = function ()
    {
      return settings.value_get(settings.folder_number_prefix_cookie_name, settings.folder_number_prefix_default_get);
    };   
    settings.folder_number_prefix_set = function (value)
    {
      settings.value_set(settings.folder_number_prefix_cookie_name, value);
    };   

    settings.file_number_prefix_get = function ()
    {
      return settings.value_get(settings.file_number_prefix_cookie_name, settings.file_number_prefix_default_get);
    };
    settings.file_number_prefix_set = function (value)
    {
      settings.value_set(settings.file_number_prefix_cookie_name, value);
    };   
    
    settings.value_get = function (cookie_name, default_value)
    {
      var value;
      
      try
      {
        value = $.cookie(cookie_name);
        if (value == null || value == "") value = default_value;
      }
      catch (e)
      {
        value = default_value;
      }
      return value;
    };     
    settings.value_set = function (cookie_name, value)
    {
      try
      {
        $.cookie(cookie_name, value, { path: "/", expires: 365 * 20 + 5 } );
      }
      catch (e)
      {
      }
    };

    // ------------------------------
    settings.dialog.on('shown',
      function()
      {
        $("#txt_folder_number_prefix").val(settings.folder_number_prefix_get());
        $("#txt_file_number_prefix").val(settings.file_number_prefix_get());
      }
    );
    //settings.dialog.on('hidden', function() { } );
    
    $("#default-create-unit-reference-number-options").click(
      function()
      {
        try
        {
          $("#txt_folder_number_prefix").val(settings.folder_number_prefix_default_get);
          $("#txt_file_number_prefix").val(settings.file_number_prefix_default_get);
        }
        catch (e)
        {
        }
      }
    );
    $("#confirm-create-unit-reference-number-options").click(
      function()
      {
        try
        {
          settings.folder_number_prefix_set($("#txt_folder_number_prefix").val());
          settings.file_number_prefix_set($("#txt_file_number_prefix").val());
          settings.dialog.modal('hide');
        }
        catch (e)
        {
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