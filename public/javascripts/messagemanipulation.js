//
// INTERACT WITH MESSAGES
//
var MessageManipulation = {
  last_message_number: 0,
  suspend_polling: false,

  init: function() {
  },

  working_begin: function() {
    $('working').appear({ duration: 0.3 });
  },
  working_end: function() {
    $('working').fade({ duration: 0.3 });
  },

  handle_new_messages: function() {
    var new_last_msg_num = MessageManipulation.find_last_message_number();
    if (MessageManipulation.last_message_number < new_last_msg_num) { // shortcut if nothing's changed
      var newMessages = MessageManipulation.identify_new_messages(MessageManipulation.last_message_number + 1, new_last_msg_num);
      MessageManipulation.last_message_number = new_last_msg_num;
      WindowManager.moreMessagesHaveArrived(newMessages)
    }
    MessageManipulation.suspend_polling = false; // in case we had shut it off for some reason
    MessageManipulation.working_end();
  },

  find_last_message_number: function() {
    var last_msg = $('messages').childElements().last();
    var num = parseInt(last_msg.id.sub("message",""));
    return num;
  },

  identify_new_messages: function(first, last) {
    var newMessages = new Array();
    for (var i = first; i <= last; i++) {
      if ($("message"+i)) { // some might be in other conversations
        newMessages.push(i);
      }
    }
    return newMessages;
  },

  quote: function(msgnum) {
    var msgtxt = $$("#message"+msgnum+" p.messagetext")[0].innerHTML.strip();
    // for now we have to undo all that markup we do at the back end.  bah
    msgtxt = msgtxt.gsub("<[Bb][Rr]/?>", "\n");
    msgtxt = msgtxt.gsub("</?[Aa] .*?>", "");

    var who = $$("#message"+msgnum+" p.messagemeta .username")[0].innerHTML.strip();
    $("message_message").value = who + " said:\n---\n" + msgtxt + "\n---\n";
    $("message_message").focus();
  }
};

Event.observe(window, 'load', MessageManipulation.init);
