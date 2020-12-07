jQuery.fn.liveUpdateFondMerge = function (list, options) {

  var cache = {},
    settings = $.extend({
      'url': '',
      'field': '',
      'targetClass': 'livesearch',
      'selectedClass': 'highlight',
      'group_id': {
        group_id: -1
      },
      'exclude': {
        exclude: []
      }
    }, options);

  /* private methods */

  function fill(data) {
    var items = [];
    $.each(data, function (key, val) {

      var liHtml = '<li><label class="radio ';
      liHtml += settings.targetClass;
      liHtml += '"><input name="';
      liHtml += settings.field;
      liHtml += '" value="';
      liHtml += val.id;
      liHtml += '" type="radio">';
      liHtml += val.value;
      liHtml += '<span class="sub-selected"></span></label></li>';
      liHtml += '<div id="fondmerge-' + val.id + '" class="dropdown divmerge">';
      //<%= render :partial => 'fonds/jump_to', :locals => {:fond => fond, :root => fond.root} %>
      liHtml += '<div id="jump-to-dialog" class="dropdown-menu">';

      /*
      <%= content_tag :div,
          nil,
    :id => "jump-to-tree"+ root.id.to_s,
    :'data-action' => controller.action_name,
    :'data-current-node-id' => fond.id,
    :'data-root-id' => root.id
      %>

       */

      var fondRootId = val.id;
      liHtml += '<div id="jump-to-tree' + fondRootId + '" ';
      liHtml += 'data-action="list.json'  + '"';
      liHtml += 'data-current-node-id="' + val.id + '" ';
      liHtml += 'data-root-id="' + fondRootId + '" ';
      liHtml += '></div>';

      liHtml += '</div>';
      liHtml += '</div>';

      items.push(liHtml);
    });
    if (items.length === 0) {
      list.html('<li>Nessun risultato trovato</li>');
    } else {
      list.html('');
      list.html(items.join(''));
    }
  }

  function filter() {
    var q = jQuery.trim(jQuery(this).val().toLowerCase());

    if (cache.hasOwnProperty(q)) {
      fill(cache[q]);
      return;
    }

// Upgrade 2.2.0 inizio
//    $.getJSON(settings.url + '?' + $.param(settings.exclude), {
// Upgrade 2.2.0 fine
    $.getJSON(settings.url + '?' + $.param(settings.exclude) + '&' + $.param(settings.group_id), {
      term: q
    }, function (data) {
      cache[q] = data;
      fill(data);
    });
  }

  function removeSelectedClass() {
    $('.' + settings.targetClass).each(function () {
      if ($(this).hasClass(settings.selectedClass)) {
        $(this).removeClass(settings.selectedClass);
      }
    });
  }

  /* public methods */
  this.getTargetClass = function () {
    return settings.targetClass;
  };

  this.getSelectedClass = function () {
    return settings.selectedClass;
  };

  this.getUrl = function () {
    return settings.url;
  };

  this.reset = function () {
    cache = {};
    removeSelectedClass();
    this.val('');
    this.trigger('keyup');
  };

  /* end public methods */

  list = jQuery(list);

  this.keyup(filter).keyup().parents('form').submit(function () {
    return false;
  });

  $('.' + settings.targetClass).live('click', function () {
    removeSelectedClass();
    $(this).addClass(settings.selectedClass);
  });

  return this;

};