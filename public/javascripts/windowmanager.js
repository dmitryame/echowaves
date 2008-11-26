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
      Event.observe(document, 'focusout', WindowManager.onBlurFO);
    } else {
      Event.observe(window, 'blur', WindowManager.onBlurW);
      Event.observe(document, 'blur', WindowManager.onBlurD);
    }
    Event.observe(window, 'focus', WindowManager.onFocusW);
    Event.observe(document, 'focus', WindowManager.onFocusD);
  },

  onBlur: function(event) {
//    console.log("blurring "+new Date());
    WindowManager.actOnBlur();
  },

  onBlurFO: function(event) {
//    console.log("blurring document IE "+new Date());
    WindowManager.actOnBlur();
  },
  onBlurW: function(event) {
//    console.log("blurring window      "+new Date());
    WindowManager.actOnBlur();
  },
  onBlurD: function(event) {
//    console.log("blurring document    "+new Date());
    WindowManager.actOnBlur();
  },
  onBlurB: function(event) {
//    console.log("blurring body        "+new Date());
    WindowManager.actOnBlur();
  },

  onFocus: function(event) {
//    console.log("focusing "+new Date());
    WindowManager.actOnFocus();
  },

  onFocusW: function(event) {
//    console.log("focusing window      "+new Date());
    WindowManager.actOnFocus();
  },

  onFocusD: function(event) {
//    console.log("focusing document    "+new Date());
    WindowManager.actOnFocus();
  },
  onFocusB: function(event) {
//    console.log("focusing body        "+new Date());
    WindowManager.actOnFocus();
  },

  actOnBlur: function() {
    if (WindowManager.blurred) { return; }

    WindowManager.blurred = true;
    // nothing more interesting right now.  but we could do all kinds of good things
    // 1) indicate to others (this would suck when people alt-tab around a lot, so I personally think it's a bad idea
    // 2) make some kind of indication in the title, so the user knows the app knows?

    // okay, going to start giving a helpful clue in the title,
    // at least to help identify what's going on with focus on different browsers/platforms
    document.title = "{0} " + document.title;

  },
  actOnFocus: function() {
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
    ids.each(function(id) {new Effect.Highlight('message_'+id)});
  }

};

Event.observe(window, 'load', WindowManager.init);
