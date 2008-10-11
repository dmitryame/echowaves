//
// INTERACT WITH WINDOW MANAGERS
//
var WindowManager = {
  blurred: false, // is the user currently looking away?
  pendingMessageIds: new Array(), // messages that have arrived since user last looked
  messageCountPattern: /^{(\d+)} /, // how we display the number of pending messages in the browser title
  

  init: function() {
//    if (document.onfocusout) { // maybe this makes it work in IE?
    if (navigator.appName == "Microsoft Internet Explorer") { // gah!
      Event.observe(document, 'focusout', WindowManager.onBlur);
    } else {
      Event.observe(window, 'blur', WindowManager.onBlur);
    }
    Event.observe(window, 'focus', WindowManager.onFocus);
  },

  onBlur: function(event) {
//    console.log("blurring");
    WindowManager.blurred = true;
  },
  
  onFocus: function(event) {
//    console.log("focusing");
    if (!WindowManager.blurred) { return; }

    WindowManager.showPendingMessages();
    WindowManager.blurred = false;
  },
  
  // inspired by how Campfire does it.
  moreMessagesHaveArrived: function(ids) {
    if (!WindowManager.blurred) {
      WindowManager.highlight_messages(ids);
      return;
    }

    WindowManager.pendingMessageIds = WindowManager.pendingMessageIds.concat(ids);

    var currentTitle = document.title;
    var prefix = "{" + WindowManager.pendingMessageIds.size() + "} ";
    var match = currentTitle.match(WindowManager.messageCountPattern);
    if (match) {
      document.title = document.title.replace(WindowManager.messageCountPattern, prefix);
    } else {
      document.title = prefix + currentTitle;
    }
    
  },

  showPendingMessages: function() {
    WindowManager.highlight_messages(WindowManager.pendingMessageIds);
    document.title = document.title.replace(WindowManager.messageCountPattern, "");
    WindowManager.pendingMessageIds = new Array();
  },

  highlight_messages: function(ids) {
    ids.each(function(id) {new Effect.Highlight('message'+id)});
  }

};

Event.observe(window, 'load', WindowManager.init);
