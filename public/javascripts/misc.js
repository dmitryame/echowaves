//
// RANDOM STUFF THAT DOESN'T BELONG ANYWHERE ELSE
//
var Misc = {
  pageScroll: function() {
    window.scrollBy(0,50000); // horizontal and vertical scroll increments
  },

  // try to focus an input field, if we can find it
  focusInput: function(inputId) {
    if ($(inputId)) {
      $(inputId).focus();
    }
  },

  showAndHide: function(toshow, tohide) {
    $$(toshow).each(function(e) {e.show()});
    $$(tohide).each(function(e) {e.hide()});
  }

}
