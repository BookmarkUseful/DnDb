var ready = function(){
  var render, select;

  render = function(term, data, type) {
    return term;
  }

  select = function(term, data, type){
    // populate our search form with the autocomplete result
    $('#crystal-search').val(term);

    // hide our autocomplete results
    $('ul#soulmate').hide();

    // then redirect to the result's link
    // remember we have the link in the 'data' metadata
    return window.location.href = data.link
  }

  $('#crystal-search').soulmate({
    url: '/autocomplete/search',
    types: ['spells', 'classes', 'sources', 'class_features'],
    renderCallback : render,
    selectCallback : select,
    minQueryLength : 2,
    maxResults     : 10
  })


}
// when our document is ready, call our ready function
$(document).ready(ready);
