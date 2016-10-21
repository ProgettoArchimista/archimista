(function( $ ){

  // PLUGIN
  $.fn.archimate_autocomplete_setup = function() {

    return this.each(function(){
      var $field      = $(this),
      controller  = $field.data('autocompletion-controller'),
      action      = $field.data('autocompletion-action') || 'list',
/* Upgrade 2.2.0 inizio */
      group_filter = $field.data('autocompletion-group-filter') || '',
/* Upgrade 2.2.0 fine */
      cache       = {},
      path,
      lastXhr;

      if (action === 'index') {
        path = "/"+ controller +".json";
      } else {
        path = "/"+ controller +"/"+action+".json";
      }

      $field.autocomplete({
        minLength: 0,
        source: function( request, response ) {
          var term = request.term;
          if ( term in cache ) {
            response( cache[ term ] );
            return;
          }
/* Upgrade 2.2.0 inizio */
          if (group_filter != '') request.group_id = group_filter;
/* Upgrade 2.2.0 fine */
          lastXhr = $.getJSON( path, request, function( data, status, xhr ) {
            cache[ term ] = data;
            if ( xhr === lastXhr ) {
              response( data );
            }
          });
        } // source: function( request, response ) {
      }).focus(function() {// $field.autocomplete({
        if (this.value == "") {
          $(this).autocomplete('search', '');
        }
      }); //focus;

    }); // return this.each(function(){

  };

})( jQuery );

