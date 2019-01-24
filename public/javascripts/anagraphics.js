$(document).ready(function () {
  getAnagraphicList = function () {
    var id = $("#anagraphic-list").attr('data-id');
    var controller = $("#anagraphic-list").attr('data-controller');
    $.get('/anagraphics/ajax_list', {
      related_entity_id: id,
      related_entity: controller
    }).success(function (data) {
      $("#anagraphic-list").html(data);
    });
    return false;
  };

  getSelectedText = function (ids) {
    var text = '';
    var len = ids.length;
    for (var i = 0; i < len; i++) {
      var element = $('#' + ids[i]);
      if (element[0].tagName.toLowerCase() == "textarea" || element[0].tagName.toLowerCase() == "input") {
        var input = document.getElementById(element.attr('id'));
        var start = input.selectionStart;
        var end = input.selectionEnd;
        text = element.val().substring(start, end);
      } else {
        if (window.getSelection) {
          text = window.getSelection();
        } else if (document.getSelection) {
          text = document.getSelection();
        } else if (document.selection) {
          text = document.selection.createRange().text;
        }
      }
      if (text != '') break;
    }
    return text;
  };

  if ($("#anagraphic-list").length) {
    getAnagraphicList();
  }


  $("#add-anagraphic-modal").click(function (event) {
    event.preventDefault();
    var id = $(this).attr('data-id');
    var controller = $(this).attr('data-controller');
    $.get('/anagraphics/modal_new', {
      related_id: id,
      related_controller: controller
    }).success(function (data) {
      $('#add-anagraphic-container').html(data);
      $('#add-anagraphic-container #add-anagraphic-dialog').modal("show");
      text = getSelectedText(['unit_content']);
      $('#anagraphic_name').val(text);
      if (text != '') {
        $("#create-anagraphic-btn").removeClass('disabled').prop('disabled', false);
      }
    });
    return false;
  });

  $("#link-anagraphic-modal").click(function (event) {
    event.preventDefault();
    var id = $(this).attr('data-id');
    var controller = $(this).attr('data-controller');
    $.get('/anagraphics/modal_link', {
      related_entity_id: id,
      related_entity: controller
    }).success(function (data) {
      $('#link-anagraphic-container').html(data);
      $('#link-anagraphic-container #link-anagraphic-dialog').modal("show");
    });
    return false;
  });

  $(document).delegate('#create-anagraphic-btn', 'click', function (event) {
    $.post('/anagraphics/modal_create', $('#new_anagraphic').serialize(), function (data) {
      if (data.status === "success") {
        $('#add-anagraphic-dialog').modal("hide");
        getAnagraphicList();
      } else {
        $("#anagraphic_form_error").
        html('<div class="alert alert-error"><a class="close" data-dismiss="alert">×</a>' + data.msg + '.</div>');
      }
    }, 'json');
    event.stopImmediatePropagation();
  });

  $(document).delegate('#link-anagraphic-btn', 'click', function (event) {
    $.post('/anagraphics/ajax_link', $('#link-anagraphic-form').serialize(), function (data) {
      if (data.status === "success") {
        $('#link-anagraphic-dialog').modal("hide");
        getAnagraphicList();
      }
    }, 'json');
    event.stopImmediatePropagation();
  });

  $(document).delegate(".anagraphic-remove", 'click', function (event) {
    event.preventDefault();
    var anagraphic_id = $(this).attr('data-anagraphic_id');
    var related_entity_id = $(this).attr('data-related_entity_id');
    var related_entity = $(this).attr('data-related_entity');
    $.post('/anagraphics/ajax_remove', {
      related_entity_id: related_entity_id,
      related_entity: related_entity,
      anagraphic_id: anagraphic_id
    }).success(function (data) {
      if (data.status == 'success') {
        getAnagraphicList();
      } else {
        alert(data.msg)
      }
    }, 'json');
    event.stopImmediatePropagation();
  });

  $(document).delegate(":input[@name='anagraphic_id']", 'click', function () {
    $("#link-anagraphic-btn").removeClass('disabled').prop('disabled', false);
  });

  $(document).delegate("#anagraphic_name", 'change', function () {
    $("#create-anagraphic-btn").removeClass('disabled').prop('disabled', false);
  });
});