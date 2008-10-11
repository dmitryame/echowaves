//
// INTERACT WITH WINDOW MANAGERS
//
var WindowManager = {
  blurred: false, // is the user currently looking away?
  pendingMessageIds: new Array(), // messages that have arrived since user last looked
  messageCountPattern: /^{(\d+)} /, // how we display the number of pending messages in the browser title
  

  init: function() {
    document.onblur = WindowManager.onBlur;
    document.onfocus = WindowManager.onFocus;
  },

  onBlur: function(event) {
    WindowManager.blurred = true;
  },
  
  onFocus: function(event) {
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
  },

  highlight_messages: function(ids) {
    ids.each(function(id) {new Effect.Highlight('message'+id)});
  }

};
