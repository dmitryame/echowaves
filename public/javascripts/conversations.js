jQuery.noConflict();
// public/javascripts/application.js
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})


jQuery(document).ready(function() {
    jQuery(".togglable_bookmark").bind('click', function(event) {
        event.preventDefault();		
        var convo_id = jQuery(this).attr('id').split('_')[1];
        // alert('/conversations/' + convo_id + '/toogle_bookmark');
        jQuery.post('/conversations/' + convo_id + '/toogle_bookmark', null, null, 'script');
        return false;
    })
})

