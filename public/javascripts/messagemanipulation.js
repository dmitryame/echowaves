//
// INTERACT WITH MESSAGES
//
var MessageManipulation = {

  init: function() {
  },

  working_begin: function() {
    $('working').appear({ duration: 0.3 });
  },
  working_end: function() {
    $('working').fade({ duration: 0.3 });
  },

};

Event.observe(window, 'load', MessageManipulation.init);
