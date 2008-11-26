// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

Array.prototype.sum = function() {
  return (! this.length) ? 0 : this.slice(1).sum() +
      ((typeof this[0] == 'number') ? this[0] : 0);
};

function ShowUnreadMessagesInFLuidapp()
{
  var numbers = $$('.msgcount').collect(function(n) {
    return parseInt(n.innerHTML);
  });
  window.fluid.dockBadge = numbers.sum();
}