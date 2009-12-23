/********************************************************************
 * jQuery Dependent Select plug-in									*
 *																	* 
 * @version		2.5													*
 * @copyright	(c) Bau Alexandru 2009 								*
 * @author 		Bau Alexandru										*
 * @email		bau.alexandru@gmail.com								*
 *																	*
 * @depends		jQuery									            *
 * 																	*
 * 																	*
 * Do not delete or modify this header!								*
 *																	* 
 * 																	*
 * Plugin call example:												*
 * 																	*
 * jQuery(function($){												*
 *																	* 
 *		SINGLE CHILD												*
 *		$('#child_id').dependent({							        *
 *			parent:	'parent_id',									*
 *			group:	'common_class'									*
 *		});															*
 *																	* 
 *		MULTIPLE CHILDS												*
 *		$('#child_id').dependent({							        *
 *			parent:	'parent_id' 									*
 *		});															*
 *																	*
 *	});																*
 *																	*
 ********************************************************************/

(function($){	// create closure
	
	/**
	 * Plug-in initialization
	 * @param	object	plug-in options
	 * @return 	object	this
	 */
	$.fn.dependent = function(settings){
		// merge default settings with dynamic settings
		$param = $.extend({}, $.fn.dependent.defaults, settings);
		
		this.each(function(){														// for each element
			$this = $(this);														// current element object
			
			var $parent 	= '#'+$param.parent;
			
			var $child	 	= $this;
			var $child_id 	= $($child).attr('id');
			var $child_cls 	= '.'+$child_id;
			
			if( $param.group != '' ){
				var $group	 	= '.'+$param.group;
			}
			
			var $index 		= 0;
			var $holder  	= 'dpslctholder';
			var $holder_cls	= '.'+$holder;
			
			_createHolder($holder, $holder_cls, $child, $child_id, $child_cls);
			
			// check if parent allready has an option selected
			if( $($parent).val() != 0 ) {
				$title = $($parent).find('option:selected').attr('title');
				$($child).find('option[class!='+$title+']').remove();
				$($child).prepend('<option value="">-- select --</option>');
			} else {
				// remove the child's options and add a default option
				$($child).find('option').remove();
				$($child).append('<option value="">-- select --</option>');
			}
			
			_parentChange($parent, $child, $group, $holder_cls, $child_cls);
			
		});
			
		return this;
	};
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/*********************************
	 * BEGIN PLUG-IN PRIVATE METHODS *
	 *********************************/
	
	/**
	 * Private function description
	 */
	 
	function _createHolder($holder, $holder_cls, $child, $child_id, $child_cls){
		
		// create a select to hold the options from all this child
		var $is_created = $($holder_cls+' '+$child_id).size();
		
		if( $is_created == 0 ){
			$('body').append('\n\n<select class="'+$holder+' '+$child_id+'" style="display:none">\n</select>\n');
		}
		
		// add options to the holder
		$($child).find('option[value!=]').each(function(){
			
			$value = $(this).attr('value');
			$class = $(this).attr('class');
			$title = $(this).attr('title');
			$text  = $(this).text();
			
			$($holder_cls+$child_cls).append('<option value="'+$value+'" class="'+$class+'" title="'+$title+'">'+$text+'</option>\n');
		});
		
	}
	
	function _parentChange($parent, $child, $group, $holder_cls, $child_cls){
		
		// on change event
		$($parent).bind('change', function(){
										   
			// remove all the child's options
			$($child).find('option[value!=]').remove();
			
			$index = $($group).index($(this))
			// set all the selects from the group to the default option
			if( $param.group != '' ){
				$($group+':gt('+ $index +')').find('option[value!=]').remove();
			}
			
			$title = $(this).find('option:selected').attr('title');
			// add options to the child mask from the holder
			$($holder_cls+$child_cls).find('option[class='+$title+']').each(function(){
																		  
				$value = $(this).attr('value');
				$class = $(this).attr('class');
				$title = $(this).attr('title');
				$text  = $(this).attr('text');
																		  
				$($child).append('<option value="'+$value+'" class="'+$class+'" title="'+$title+'">'+$text+'</option>');
			});
			
		});
		
	}
	
	/********************************
	 * /END PLUG-IN PRIVATE METHODS *
	 ********************************/
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/************************************
	 * BEGIN PLUG-IN DEFAULT PARAMETERS *
	 ************************************/
	
	$.fn.dependent.defaults = {	
		parent:		'parent_id'
	};
	
	/***********************************
	 * /END PLUG-IN DEFAULT PARAMETERS *
	 ***********************************/
	
})(jQuery);		// end closure