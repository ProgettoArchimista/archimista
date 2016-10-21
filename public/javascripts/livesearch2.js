jQuery.fn.liveUpdate = function (list, options) {

  var cache = {},
    settings = $.extend({
      'url': '',
      'field': '',
      'targetClass': 'livesearch',
      'selectedClass': 'highlight',
// Upgrade 2.2.0 inizio
      'group_id': {
        group_id: -1
      },
// Upgrade 2.2.0 fine
      'exclude': {
        exclude: []
      }
    }, options);

  /* private methods */

  function fill(data) {
    var items = [];
    $.each(data, function (key, val) {
      items.push('<li><label class="radio ' + settings.targetClass + '"><input name="' + settings.field + '" value="' + val.id + '" type="radio">' + val.value + '</label></li>');
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