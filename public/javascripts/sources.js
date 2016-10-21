/* Upgrade 2.2.0 inizio */
/* $(document).ready(function(){ $("#sources_live_search").live_search({url : "/sources/list", animate_results : true});});*/
$(document).ready(function(){
  var jqCtl;
  var group_filter;
  var url;

  jqCtl = $("#sources_live_search");
  if (jqCtl.length > 0)
  {
    group_filter = jqCtl.attr("livesearch_group_filter");
    if (group_filter != null)
      url = "/sources/list" + "?group_id=" + group_filter.toString();
    else
      url = "/sources/list";
    jqCtl.live_search({
       url : url,
       animate_results : true
     });  
  }
});
/* Upgrade 2.2.0 fine */