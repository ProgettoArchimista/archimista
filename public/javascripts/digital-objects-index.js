$(document).ready(function() {

  uncheckAll();

  if (!checkBoxes()) {
    $("#toggle-all").prop('disabled', true).addClass('disabled');
  }

  $("#sortable").sortable({
    cursor: 'move',
    placeholder : 'sortable-placeholder',
    forcePlaceholderSize : true,
    opacity : 0.7,
    update : function () {
      var order = $('#sortable').sortable('serialize');
      var action = getEntitySortAction(getContext());
      $.get(action+"?"+order, function(data) {});
    }
  });

  $(document).on('change', "[id^=" + getEntityIds(getContext()) + "]", function() {
    if($(this).is(':checked') ) {
      if(allChecked()) {
        $('#toggle-all').prop('checked', true);
      }
    } else {
      if($('#toggle-all').is(':checked')) {
        $('#toggle-all').prop('checked', false);
      }
    }
    toggleBulkDestroy();
  });

  $(document).on("click", "#bulk-destroy", function (){
    if ($(this).prop('disabled') === false) {
      var params = decodeURIComponent($('input:checkbox:checked').serialize());
      var action = getEntityBulkDestroyAction(getContext());
      $.get(action+"?"+params, function(data) {
        window.location.reload();
      });
    }
  });

  $(document).on('change', "#toggle-all", function() {
    var CheckBoxes = $("[id^=" + getEntityIds(getContext()) + "]");
    $(this).is(':checked') ? CheckBoxes.prop("checked", true) : CheckBoxes.prop("checked", false);
    toggleBulkDestroy();
  });

  function toggleBulkDestroy() {
    var checkBoxChecked = $('input:checkbox:checked');
    if (checkBoxChecked.length) {
      $("#bulk-destroy").prop('disabled', false).removeClass('disabled').addClass('btn-danger');
      $("#bulk-destroy i").addClass('icon-white');
    }
    else {
      $("#bulk-destroy").prop('disabled', true).addClass('disabled').removeClass('btn-danger');
      $("#bulk-destroy i").removeClass('icon-white');
    }
  }

  function uncheckAll() {
    $('input:checkbox:checked').prop('checked', false);
  }

  function checkBoxes() {
    var test = $("[id^=" + getEntityIds(getContext()) + "]").length ? true : false;
    return test;
  }

  function allChecked() {
    var test = true;
    $("[id^=" + getEntityIds(getContext()) + "]").each(function() {
      if(!$(this).is(':checked')) {
        test = false;
      }
    });
    return test;
  }

/* Upgrade 2.1.0 inizio */
  function getEntityIds(context) {
    return context + "_ids_";
  }

  function getEntitySortAction(context) {
    return "/" + context + "s/sort";
  }

  function getEntityBulkDestroyAction(context) {
    return "/" + context + "s/bulk_destroy";
  }
/* Upgrade 2.1.0 fine */
});

