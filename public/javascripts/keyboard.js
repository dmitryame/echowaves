//
// KEYBOARD MAGIC
//
// initially grabbed from
//   http://www.howtocreate.co.uk/tutorials/javascript/eventinfo

// completely gutted for now, just supporting "Ctrl-ENTER" to submit the text area
// once we have more sophisticated features, we can plug some keyboard navigation in
var Keyboard = {
  verbose: false, // for debugging

  init: function() {
    Event.observe(document, 'keyup', Keyboard.handleKeyEvent);
  },

  // the keyboard event handler function
  handleKeyEvent: function(e) {
    var k;
    if( !e ) {
      //if the browser did not pass the event information to the
      //function, we will have to obtain it from the event register
      if( window.event ) {
        //Internet Explorer
        e = window.event;
      } else {
        //total failure, we have no way of referencing the event
        return;
      }
    }

    if( typeof( e.keyCode ) == 'number'  ) {
      k = e.keyCode; // DOM
    } else if( typeof( e.which ) == 'number' ) {
      k = e.which; //NS 4 compatible
    } else if( typeof( e.charCode ) == 'number'  ) {
      k = e.charCode; //also NS 6+, Mozilla 0.9+
    } else {
      return; //total failure, we have no way of obtaining the key code
    }
    if (Keyboard.verbose) {
      console.log('The key pressed has keycode ' + k +
                  ' and is key "' + String.fromCharCode( k ) +'"' +
                  ' and shiftKey was "' + e.shiftKey +'"' +
                  ' and ctrlKey was "' + e.ctrlKey +'"' +
                  ' and altKey was "' + e.altKey +'"'
                 );
    }

    // okay, for now, all we're doing is seeing if you pressed "Ctrl-ENTER" in the text area
    // ugh, "e.target.id" fails in IE (7 anyway) too lazy to figure out what to do.
//    if (e.target.id == "message_message") {
    
      if (k == 13 && e.shiftKey) { // "Shift-ENTER" enters a new line
        return;
      }
      if (k == 13) { // "ENTER" submits a message
        $("message_message").form.onsubmit();
      }
//    }

  }
};

Event.observe(window, 'load', Keyboard.init);
