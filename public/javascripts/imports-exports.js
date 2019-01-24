$(document).ready(function() {

    $("#inc_san").click(function(event) {
        if ($("#inc_san").is(":checked")) {
            $("#inc_ead").attr('checked', false);
            $("#inc_ead").attr("disabled", true);
            $("#sources").removeClass('tab-xml');
            $("#creators").removeClass('tab-xml');
        } else {
            $("#inc_ead").removeAttr("disabled");
            $("#sources").addClass('tab-xml');
            $("#creators").addClass('tab-xml');
        }
    });

    $("#inc_ead").click(function(event) {
        if ($("#inc_ead").is(":checked")) {
            $("#inc_san").attr('checked', false);
            $("#inc_san").attr("disabled", true);
            $("#inc_digit").attr('checked', false);
            $("#inc_digit").attr("disabled", true);
            $("#sources").removeClass('tab-xml');
            $("#creators").removeClass('tab-xml');
        } else {
            $("#inc_san").removeAttr("disabled");
            $("#inc_digit").removeAttr("disabled");
            $("#sources").addClass('tab-xml');
            $("#creators").addClass('tab-xml');
        }
    });

    $("#exports-fond-autocomplete").archimate_autocomplete_setup();

    $("#exports-fond-name-autocomplete").autocomplete('option', 'select', function(event, ui) {
        $("#exports-fond-name-autocomplete").attr("value", ui.item.value);
        $("#exports-fond-id-autocomplete").attr("value", ui.item.id);
        $("#exports-fond-choice").submit();
        return false;
    });

    $("#exports-custodian-autocomplete").archimate_autocomplete_setup();

    $("#exports-custodian-name-autocomplete").autocomplete('option', 'select', function(event, ui) {
        $("#exports-custodian-name-autocomplete").attr("value", ui.item.value);
        $("#exports-custodian-id-autocomplete").attr("value", ui.item.id);
        $("#exports-custodian-choice").submit();
        return false;
    });

    $("#exports-project-autocomplete").archimate_autocomplete_setup();

    $("#exports-project-name-autocomplete").autocomplete('option', 'select', function(event, ui) {
        $("#exports-project-name-autocomplete").attr("value", ui.item.value);
        $("#exports-project-id-autocomplete").attr("value", ui.item.id);
        $("#exports-project-choice").submit();
        return false;
    });

    /* UPDATE 3.0.1 ICAR Inizio*/

    $("#exports-creator-autocomplete").archimate_autocomplete_setup();

    $("#exports-creator-name-autocomplete").autocomplete('option', 'select', function(event, ui) {
        $("#exports-creator-name-autocomplete").attr("value", ui.item.value);
        $("#exports-creator-id-autocomplete").attr("value", ui.item.id);
        $("#exports-creator-choice").submit();
        return false;
    });

    $("#exports-source-autocomplete").archimate_autocomplete_setup();

    $("#exports-source-name-autocomplete").autocomplete('option', 'select', function(event, ui) {
        $("#exports-source-name-autocomplete").attr("value", ui.item.value);
        $("#exports-source-id-autocomplete").attr("value", ui.item.id);
        $("#exports-source-choice").submit();
        return false;
    });

    /* UPDATE 3.0.1 ICAR fine*/

    $("#import-wait").submit(function() {
        $.blockUI({
            message: 'Importazione in corso...'
        });
    });

    $("#exports-fond-choice").submit(function(event) {
        if ($("#inc_san").is(":checked") || $("#inc_ead").is(":checked")) {
            data = {
                "target_id": $("#exports-fond-id-autocomplete").val(),
                "target_class": "fond",
                "target_mode": "full",
                "target_xml" : $("#inc_san").is(":checked") ? "san" : "ead"
            };
            if (!$("#inc_entities").is(":checked")) {
                data.target_mode = "not-full";
            }
            export_xml(event, data);
            return false;
        } else {
            event.preventDefault();
            $.blockUI({
                message: 'Esportazione in corso...'
            });
            $.ajax({
                url: '/exports.json',
                data: {
                    target_id: $("#exports-fond-id-autocomplete").val(),
                    target_class: 'fond',
                    mode: 'full',
                    /* Upgrade 3.0.0 inizio */
                    inc_digit: $("#inc_digit").is(":checked")
                    /* Upgrade 3.0.0 inizio */

                },
                dataType: 'json',
                success: function(data) {
                    var tokens, file, data_file, metadata_file;
                    $.unblockUI();
                    /*codice senza file digitali da esportare
                      //        tokens = data["export"]["dest_file"].split('/');
                      tokens = data["dest_file"].split('/');
                      
                    file = tokens[tokens.length - 1];*/

                    tokens = data["dest_file"].split('/');
                    file = tokens[tokens.length - 1];

                    tokens = data["data_file"].split('/');
                    data_file = tokens[tokens.length - 1];

                    tokens = data["metadata_file"].split('/');
                    metadata_file = tokens[tokens.length - 1];

                    /* Upgrade 3.0.0 inizio */
                    $("#inc_digit").prop('checked', false);
                    /* Upgrade 3.0.0 inizio */
                    $(window.location).attr('href', "/exports/download?file=" + file);
                }
            });
            return false;
        }

    });



    $("#exports-custodian-choice").submit(function(event) {
        if ($("#inc_san").is(":checked") || $("#inc_ead").is(":checked")) {
            data = {
                "target_id": $("#exports-custodian-id-autocomplete").val(),
                "target_class": "custodian",
                "target_mode": "full",
                "target_xml" : $("#inc_san").is(":checked") ? "san" : "ead"
            };
            if (!$("#inc_entities").is(":checked")) {
                data.target_mode = "not-full";
            }
            export_xml(event, data);
            return false;
        } else {
            event.preventDefault();
            $.blockUI({
                message: 'Esportazione in corso...'
            });
            $.ajax({
                url: '/exports.json',
                data: {
                    target_id: $("#exports-custodian-id-autocomplete").val(),
                    target_class: 'custodian',
                    mode: 'full',
                    /* Upgrade 3.0.0 inizio */
                    inc_digit: $("#inc_digit").is(":checked")
                    /* Upgrade 3.0.0 inizio */

                },
                dataType: 'json',
                success: function(data) {
                    var tokens, file, data_file, metadata_file;
                    $.unblockUI();
                    /* Codice senza file digitali da esportare
                      //        tokens = data["export"]["dest_file"].split('/');
                      tokens = data["dest_file"].split('/');
                    file = tokens[tokens.length - 1];*/

                    tokens = data["dest_file"].split('/');
                    file = tokens[tokens.length - 1];

                    tokens = data["data_file"].split('/');
                    data_file = tokens[tokens.length - 1];

                    tokens = data["metadata_file"].split('/');
                    metadata_file = tokens[tokens.length - 1];

                    /* Upgrade 3.0.0 inizio */
                    $("#inc_digit").prop('checked', false);
                    /* Upgrade 3.0.0 inizio */

                    $(window.location).attr('href', "/exports/download?file=" + file);
                }
            });
            return false;
        }

    });



    $("#exports-project-choice").submit(function(event) {
        event.preventDefault();
        $.blockUI({
            message: 'Esportazione in corso...'
        });
        $.ajax({
            url: '/exports.json',
            data: {
                target_id: $("#exports-project-id-autocomplete").val(),
                target_class: 'project',
                mode: 'full',
                /* Upgrade 3.0.0 inizio */
                inc_digit: $("#inc_digit").is(":checked")
                /* Upgrade 3.0.0 inizio */

            },
            dataType: 'json',
            success: function(data) {
                var tokens, file, data_file, metadata_file;
                $.unblockUI();
                /* codice senza file digitali da esportare
                  //        tokens = data["export"]["dest_file"].split('/');
                  tokens = data["dest_file"].split('/');
                file = tokens[tokens.length - 1];*/

                tokens = data["dest_file"].split('/');
                file = tokens[tokens.length - 1];

                tokens = data["data_file"].split('/');
                data_file = tokens[tokens.length - 1];

                tokens = data["metadata_file"].split('/');
                metadata_file = tokens[tokens.length - 1];

                /* Upgrade 3.0.0 inizio */
                $("#inc_digit").prop('checked', false);
                /* Upgrade 3.0.0 inizio */

                $(window.location).attr('href', "/exports/download?file=" + file);
            }
        });
        return false;
    });

    $("#exports-creator-choice").submit(function(event) {
        if ($("#inc_san").is(":checked") || $("#inc_ead").is(":checked")) {
            data = {
                "target_id": $("#exports-creator-id-autocomplete").val(),
                "target_class": "creator",
                "target_mode": "full",
                "target_xml" : $("#inc_san").is(":checked") ? "san" : "ead"
            };
            if (!$("#inc_entities").is(":checked")) {
                /*$(this).attr('target-mode', 'not-full');*/
                data.target_mode = "not-full";
            }
            export_xml(event, data);
            return false;
        } else {
            /*data = {"target_id": $(this).attr('target-id'), 
              "target_class": $(this).attr('target-class'), 
              "target_mode": $(this).attr('target-mode')
              };
              if(!$("#inc_entities").is(":checked")){
              data.target_mode = "not-full";
              }  
              
            */
            export_aef(event, data);
            return false;
        }

    });

    $("#exports-source-choice").submit(function(event) {
        if ($("#inc_san").is(":checked") || $("#inc_ead").is(":checked")) {
            data = {
                "target_id": $("#exports-source-id-autocomplete").val(),
                "target_class": "source",
                "target_mode": "full",
                "target_xml" : $("#inc_san").is(":checked") ? "san" : "ead"
            };
            if (!$("#inc_entities").is(":checked")) {
                /*$(this).attr('target-mode', 'not-full');*/
                data.target_mode = "not-full";
            }
            export_xml(event, data);
            return false;
        } else {
            /*data = {"target_id": $(this).attr('target-id'), 
              "target_class": $(this).attr('target-class'), 
              "target_mode": $(this).attr('target-mode')
            };*/
            return false;
        }

    });


    $(".export-trigger-wait").click(function(event) {
        if ($("#inc_san").is(":checked") || $("#inc_ead").is(":checked")) {
            data = {
                "target_id": $(this).attr('target-id'),
                "target_class": $(this).attr('target-class'),
                "target_mode": $(this).attr('target-mode'),
                "target_xml" : $("#inc_san").is(":checked") ? "san" : "ead"
            };
            if (!$("#inc_entities").is(":checked")) {
                data.target_mode = "not-full";
            }else{
                data.target_mode = "full";
            }
            export_xml(event, data);
            return false;
        } else {
            export_aef(event, $(this));
            return false;
        }
    });

    function export_xml(event, obj) {
        event.preventDefault();
        $.blockUI({
            message: 'Esportazione in corso...'
        });
        $.ajax({
            url: '/exports/xml',
            data: {
                /* target_id: obj.attr('target-id'),
                  target_class: obj.attr('target-class'),
                  mode: obj.attr('target-mode'),
                inc_digit: $("#inc_digit").is(":checked")*/
                target_id: obj.target_id,
                target_class: obj.target_class,
                mode: obj.target_mode,
                inc_digit: $("#inc_digit").is(":checked"),
                target_xml: obj.target_xml
            },
            dataType: 'json',
            success: function(data) {
                var tokens, file, data_file, metadata_file;
                $.unblockUI();

                tokens = data["dest_file"].split('/');
                file = tokens[tokens.length - 1];

                tokens = data["data_file"].split('/');
                data_file = tokens[tokens.length - 1];

                tokens = data["metadata_file"].split('/');
                metadata_file = tokens[tokens.length - 1];

                $(window.location).attr('href', "/exports/download?file=" + file + "&data=" + data_file);
            },
            error: function(data) {
                console.log(data);
                $.unblockUI();
            }
        });
    };

    function export_aef(event, obj) {
        event.preventDefault();
        $.blockUI({
            message: 'Esportazione in corso...'
        });
        $.ajax({
            url: '/exports.json',
            data: {
                target_id: obj.attr('target-id'),
                target_class: obj.attr('target-class'),
                mode: obj.attr('target-mode'),
                inc_digit: $("#inc_digit").is(":checked")
            },
            dataType: 'json',
            success: function(data) {
                var tokens, file, data_file, metadata_file;
                $.unblockUI();

                tokens = data["dest_file"].split('/');
                file = tokens[tokens.length - 1];

                tokens = data["data_file"].split('/');
                data_file = tokens[tokens.length - 1];

                tokens = data["metadata_file"].split('/');
                metadata_file = tokens[tokens.length - 1];

                $("#inc_digit").prop('checked', false);
                $(window.location).attr('href', "/exports/download?file=" + file + "&data=" + data_file + "&meta=" + metadata_file);
            },
            error: function(data) {
                $.unblockUI();
            }
        });
    };


    $(".export-aef-wait").click(function(event) {
        event.preventDefault();
        $.blockUI({
            message: 'Esportazione in corso...'
        });
        $.ajax({
            url: '/exports.json',
            data: {
                target_id: $(this).attr('target-id'),
                target_class: $(this).attr('target-class'),
                mode: $(this).attr('target-mode'),
                /* Upgrade 3.0.0 inizio */
                inc_digit: $("#inc_digit").is(":checked")
                /* Upgrade 3.0.0 inizio */
            },
            dataType: 'json',
            success: function(data) {
                var tokens, file, data_file, metadata_file;
                $.unblockUI();
                /* Upgrade 2.0.0 inizio */
                /*
                  tokens = data["export"]["dest_file"].split('/');
                  file = tokens[tokens.length - 1];
                  
                  tokens = data["export"]["data_file"].split('/');
                  data_file = tokens[tokens.length - 1];
                  
                  tokens = data["export"]["metadata_file"].split('/');
                  metadata_file = tokens[tokens.length - 1];
                */
                tokens = data["dest_file"].split('/');
                file = tokens[tokens.length - 1];

                tokens = data["data_file"].split('/');
                data_file = tokens[tokens.length - 1];

                tokens = data["metadata_file"].split('/');
                metadata_file = tokens[tokens.length - 1];
                /* Upgrade 2.0.0 fine */
                /* Upgrade 3.0.0 inizio */
                $("#inc_digit").prop('checked', false);
                /* Upgrade 3.0.0 inizio */
                $(window.location).attr('href', "/exports/download?file=" + file + "&data=" + data_file + "&meta=" + metadata_file);
            }
        });
        return false;
    });

    $(".delete-import").click(function() {
        $("#confirm-delete-btn").attr("data-import-id", $(this).attr("data-import-id"));
        $("#confirm-delete-import").modal("show");
        return false;
    });

    $("#confirm-delete-btn").click(function() {
        var id = $(this).attr("data-import-id");
        $('#confirm-delete-import').modal("hide");

        $.blockUI({
            message: 'Eliminazione in corso...'
        });

        $.ajax({
            type: "DELETE",
            url: '/imports/' + id,
            success: function(data) {
                $.unblockUI();
                if (data.status === "success") {
                    location.reload();
                } else {
                    $("div.container").prepend('<div class="alert alert-error"><a class="close" data-dismiss="alert">×</a>' + data.msg + '.</div>');
                }
            }
        });
    });

    $('#export-tabs a:first').tab('show');

    $('#export-tabs li a').click(function(event) {
        if ($(this).text().includes('Progetti')) {
            $("#inc_ead").prop('checked', false);
            $("#inc_ead").attr("disabled", true);
            $("#inc_san").prop('checked', false);
            $("#inc_san").attr("disabled", true);
            $("#inc_entities").prop('checked', false);
            $("#inc_entities").attr("disabled", true);
        } else {
            $("#inc_ead").prop('checked', false);
            $("#inc_ead").removeAttr("disabled");
            $("#inc_san").prop('checked', false);
            $("#inc_san").removeAttr("disabled");
            $("#inc_entities").prop('checked', false);
            $("#inc_entities").removeAttr("disabled");
            $("#sources").addClass('tab-xml');
            $("#creators").addClass('tab-xml');
        }

    });

});