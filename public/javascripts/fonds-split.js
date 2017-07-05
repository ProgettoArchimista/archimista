$(document).ready(function () {

  $.jump_to_fond = {};
  

  $(document).delegate(".fondsplit", 'click', function () {

    var id = $(this).attr('data-id');
    $.get('fonds/' + id + '/split_fond').success(function (data) {
      $('#split-fond-container').html(data);
      $('#split-fond-container #split-fonds-modal').modal("show");
      $.jump_to_fond.tree = $("#jump-to-tree");
      $.jump_to_fond.jump();
    });
  });


  $.jump_to_fond.tree_setup = function ($tree, root_id, current_node_id) {
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
      $("#confirm-split").prop('disabled', false).removeClass('disabled');
    })
    .delegate($tree, "click", function (event) {
      event.stopPropagation();
      return false;
    });
  };

$.jump_to_fond.jump = function () {
    var self, root_id, current_node_id, action;

    self            = this;
    root_id         = self.tree.data('root-id');
    current_node_id = self.tree.data('current-node-id');
    action          = self.tree.data('action');


    if ( self.tree.children().length > 0 ) { return null; }

   
    self.tree_setup(self.tree, root_id, current_node_id);

    self.tree.bind('node_selected.custom_jstree', function (event, target_node_id) {
      if (action === "gridview" ) {
      } else {
        $("input[name='new_root_id']").val(target_node_id);
      }
    });
  };

  $(document).delegate("#confirm-split", 'click', function () {
    if ($(this).hasClass("disabled")) {
      return false;
    } else {
      $("#split-fonds-form").trigger('submit');
    }
  });

});

