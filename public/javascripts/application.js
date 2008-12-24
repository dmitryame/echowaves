// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

Array.prototype.sum = function() {
  return (! this.length) ? 0 : this.slice(1).sum() +
      ((typeof this[0] == 'number') ? this[0] : 0);
};

var Textarea = {
  sync:function(ta_orig, ta_dest) {
    $(ta_dest).value = $F(ta_orig);
  }
}

function ShowUnreadMessagesInFLuidapp()
{
  var numbers = $$('.msgcount').collect(function(n) {
    return parseInt(n.innerHTML);
  });
  window.fluid.dockBadge = numbers.sum();
}

function FitToTextAndMoveMessagesUp(id, maxHeight)
{
   var text = id && id.style ? id : document.getElementById(id);
   if ( !text )
      return;

   var adjustedHeight = text.clientHeight;
   if ( !maxHeight || maxHeight > adjustedHeight )
   {
      adjustedHeight = Math.max(text.scrollHeight, adjustedHeight);
      if ( maxHeight )
         adjustedHeight = Math.min(maxHeight, adjustedHeight);
      if ( adjustedHeight > text.clientHeight ) {
         text.style.height = adjustedHeight + "px";
         $('messages').setStyle("padding-bottom: " + (adjustedHeight+60) + "px");
      }
   }
}