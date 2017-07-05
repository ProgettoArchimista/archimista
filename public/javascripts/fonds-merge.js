$(document).ready(function () {

  $.jump_to_fonds = {};
  

  $(document).delegate(".merge", 'click', function () {

    var id = $(this).attr('data-id');
    $.get('fonds/' + id + '/merge_with').success(function (data) {
      
      $('#merge-with-container').html(data);
      $('#merge-with-container #merge-fonds-modal').modal("show");
      
    });
  });

  $(document).delegate("#fonds-list input[@name='new_root_id']", 'click', function (event) {
    var target_value = event.target.value;
    $.jump_to_fonds.tree = $("#jump-to-tree" + target_value);
    $.jump_to_fonds.jump(target_value);
  });


  $.jump_to_fonds.tree_setup = function ($tree, root_id, current_node_id) {
    var self, target_node_id;

    self = this;

    self.tree
    .bind("loaded.jstree", function(event, data) {
      $tree.jstree("open_all");

      $tree.find('li a').each(function() {
        var units_count = $(this).parent("li").data('units');
        $(this).append(' <em>(' + units_count + ')</em>');
      });

    })
    .jstree({
      plugins   : ["themes", "ui", "json_data"],
      themes    : { theme : "apple", dots : false, icons : true },
      ui        : { initially_select : ["#node-"+current_node_id] },
      json_data : {
        ajax : {
          dataType : "json",
          url : "/fonds/" + root_id + "/tree"
        }
      }
    })
    .delegate("li a", "click", function (event) {
      event.stopPropagation();
      target_node_id = $(this).parent("li").attr('id').split('-').pop();
      $tree.trigger("node_selected.custom_jstree", target_node_id);
    })
    .delegate($tree, "click", function (event) {
      event.stopPropagation();
      return false;
    });
  };

$.jump_to_fonds.jump = function (target_id) {
  
    var self, root_id, current_node_id, action;

    self            = this;
    /*root_id         = self.tree.data('root-id');
    current_node_id = self.tree.data('current-node-id');*/
    root_id = target_id;
    current_node_id = target_id;
    action          = self.tree.data('action');
   
    self.tree_setup(self.tree, root_id, current_node_id);

    self.tree.bind("loaded.jstree", function (event, data) {
        $(this).jstree("open_all");
    });

    self.tree.bind('node_selected.custom_jstree', function (event, target_node_id) {
      if (action === "gridview" ) {
      } else {
        $('.dropdown.divmerge').removeClass('open');
        $("input[name='choosen_root_id']").val(target_node_id);
        $("#confirm-merge").prop('disabled', false).removeClass('disabled');
      }
    });
  };



  $(document).delegate("#fonds-list input[@name='new_root_id']", 'click', function () {
    var id = $(this).val();

    if($('#fondmerge-'+id).hasClass('open')){
      $('#fondmerge-'+id).removeClass('open');
    }else{
      $('.dropdown.divmerge').each(function () {
        if ($(this).hasClass('open')) {
          $(this).removeClass('open');
        }
      });
      $('#fondmerge-'+id).addClass('open');
    }
  });

  $(document).delegate('.livesearch', 'click', function () {
    var id = $(this).find("input").val();
    $('.livesearch').each(function () {
      if ($(this).hasClass('highlight')) {
        $(this).removeClass('highlight');
      }
    });

    $(this).addClass('highlight');
  });

  $(document).delegate("#confirm-merge", 'click', function () {
    if ($(this).hasClass("disabled")) {
      return false;
    } else {
      $("#merge-fonds-form").trigger('submit');
    }
  });

  $(document).click(function(e) {

    if($(e.target).hasClass("modal-body")){
      $('.dropdown.divmerge').each(function () {
        if ($(this).hasClass('open')) {
          $(this).removeClass('open');
        }
      });
    }
  });

});

