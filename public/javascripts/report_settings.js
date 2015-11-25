//

function report_settings_init(dialog_id, hdfReportSettingsCfg)
{
  var report_settings;
  var cfg;
  var jqCtl;
  
  try
  {
    jqCtl = $("#" + hdfReportSettingsCfg);
    if (jqCtl.length <= 0) return null;
    
    cfg = eval("(" + jqCtl.val() + ")");
    
    report_settings = {};

    // -------------------------
    report_settings.cookie_name = cfg.cookie_name;
    report_settings.reportAttributesSuffix = cfg.reportAttributesSuffix;
    report_settings.reportDontUseCaptionsSuffix = cfg.reportDontUseCaptionsSuffix;
    
    // -------------------------
    report_settings.dialog = $("#" + dialog_id);
		
		report_settings.dialog.on('shown', function(){
			$(".options-spec input[type=checkbox]").each(
        function()
        {
          if (!report_settings.hasProperty($(this), "initialValue")) this.initialValue = this.checked;
        }
      );
			$(".attributes-list input[type=checkbox]").each(
        function()
        {
          if (!report_settings.hasProperty($(this), "initialValue")) this.initialValue = this.checked;
        }
      );
		});	
		report_settings.dialog.on('hidden', function(){
			$(".options-spec input[type=checkbox]").each(
        function()
        {
          if (report_settings.hasProperty($(this), "initialValue")) this.checked = this.initialValue;
        }
      );
			$(".attributes-list input[type=checkbox]").each(
        function()
        {
          if (report_settings.hasProperty($(this), "initialValue")) this.checked = this.initialValue;
        }
      );
		});

    $(".list-area-cmd-btn-select").click(
      function()
      {
        report_settings.set_checkboxes($(this), true);
        return false;
      }
    );

    $(".list-area-cmd-btn-unselect").click(
      function() {
        report_settings.set_checkboxes($(this), false);
        return false;
      }
    );

    $(".list-area-cmd-btn-reset").click(
      function() {
        report_settings.reset_checkboxes($(this));
        return false;
      }
    );

    $("#confirm-columns").click(
      function()
      {
        report_settings.execute();
      }
    );

    // -------------------------
    report_settings.set_checkboxes = function(jqCtl, checkbox_status)
    {
			var btn_id;
			var entity_name;
			var i;
			
			try
			{
				btn_id = jqCtl.attr("id");
				i = btn_id.indexOf("-");
				if (i >= 0)
				{
					entity_name = btn_id.substring(3, i);
					$("#ul" + entity_name + "-attributes-list input[type=checkbox]").each(function() { this.checked = checkbox_status; });
				}
			}
			catch (e)
			{
        report_settings.show_errmsg("report_settings.set_checkboxes errore=" + e.message);
			}
		}

    // -------------------------
    report_settings.reset_checkboxes = function(jqCtl)
    {
			var btn_id;
			var entity_name;
			var i;
			
			try
			{
				btn_id = jqCtl.attr("id");
				i = btn_id.indexOf("-");
				if (i >= 0)
				{
					entity_name = btn_id.substring(3, i);
					$("#ul" + entity_name + "-attributes-list input[type=checkbox]").each(
            function()
            {
              try
              {
                if (report_settings.hasAttribute($(this), "is_default"))
                {
                  if ($(this).attr("is_default") == "1")
                    this.checked = true;
                  else
                    this.checked = false;
                }
                else
                  this.checked = false;
              }
              catch (e)
              {
                alert("Erore: " + e.message);
              }
            }
          );
				}
			}
			catch (e)
			{
        report_settings.show_errmsg("report_settings.set_checkboxes errore=" + e.message);
			}
		}

    // -------------------------
    report_settings.execute = function()
    {
      try
      {
        var form;
        var params;
        var selected_attribute_names;
        var dont_use_fld_captions;

        form = report_settings.dialog.find("form").first();
        params = form.serializeArray();
        selected_attribute_names = [];
        dont_use_fld_captions = [];
        $.each(params, function(index, input_field)
        {
          if (report_settings.StrEndsWith(input_field.name, report_settings.reportAttributesSuffix)) {
            selected_attribute_names.push(input_field.value);
          }
          if (report_settings.StrEndsWith(input_field.name, report_settings.reportDontUseCaptionsSuffix)) {
            dont_use_fld_captions.push(input_field.value);
          }
        });
        report_settings.set_cookie(report_settings.cookie_name, selected_attribute_names, dont_use_fld_captions);

        form.trigger('submit');
      }
      catch (e)
      {
        report_settings.show_errmsg("report_settings.execute errore=" + e.message);
      }
    };

    // -------------------------
    report_settings.set_cookie = function (cookie_name, selected_attribute_names, dont_use_fld_captions)
    {
      var cookie_value;
      var i;
      var status;

      try
      {
        cookie_value = "";
        for (i = 0; i < selected_attribute_names.length; i++)
        {
          if (cookie_value != "") cookie_value = cookie_value + ",";
          cookie_value = cookie_value + selected_attribute_names[i];
        }
        for (i = 0; i < dont_use_fld_captions.length; i++)
        {
          if (cookie_value != "") cookie_value = cookie_value + ",";
          cookie_value = cookie_value + dont_use_fld_captions[i];
        }

        $.cookie(cookie_name, cookie_value, { path: "/", expires: 365 * 20 + 5 } );

        status = true;
      }
      catch (e)
      {
        report_settings.show_errmsg("report_settings.set_cookie errore=" + e.message);
        status = false;
      }
      return status;
    };

    // -------------------------
    report_settings.show_errmsg = function (msg)
    {
      //alert(msg);
    };

    // -------------------------
    report_settings.StrEndsWith = function (str, suffix)
    {
      var status;
      try
      {
        if (str.length >= suffix.length)
          status = str.indexOf(suffix, str.length - suffix.length) !== -1;
        else
          status = false;
      }
      catch (e)
      {
        status = false;
      }
      return status;
    }

    // -------------------------
    report_settings.hasAttribute = function (jqCtl, attrName)
    {
      var status;
      try
      {
        status = (jqCtl.attr(attrName) !== undefined);
      }
      catch (e)
      {
        status = false;
      }
      return status;
    }

    // -------------------------
    report_settings.hasProperty = function (jqCtl, propName)
    {
      var status;
      try
      {
        status = (jqCtl.prop(propName) !== undefined);
      }
      catch (e)
      {
        status = false;
      }
      return status;
    }
  }
  catch (e)
  {
    alert("report_settings.init: " + e.message);
    report_settings = null;
  }
  return report_settings;
}
