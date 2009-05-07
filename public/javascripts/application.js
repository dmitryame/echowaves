// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// message template
//---------------------------------------------------------------------------
var messageTopTemplate = new Template(
"<div class=\"message\" id=\"message_#{message.id}\">\
	  <div class=\"avatar\"><a href=\"/users/#{user.id}-#{user.login}\" id=\"tip_#{message.id}\" title=\"&lt;img alt=&quot;#{user.login}&quot; border=&quot;0&quot; height=&quot;60&quot; src=&quot;#{user.gravatar_url}?d=identicon&amp;r=PG&amp;s=60&quot; style=&quot;float:left;margin-right:15px;margin-bottom:15px;&quot; width=&quot;60&quot; /&gt;#{user.since}&lt;br/&gt;#{user.convos_started}&lt;br/&gt;#{user.messages_posted}&lt;br/&gt;#{user.following}&lt;br/&gt;#{user.followers}\"><img alt=\"#{message.user.login}\" border=\"0\" class=\"avatar\" height=\"30\" src=\"#{user.gravatar_url}?d=identicon&amp;r=PG&amp;s=60\" width=\"30\" /></a>\
		</div>\
		<div class=\"messagetext\">"
);

var messageImageTemplate = new Template(
      "<div class=\"img_attachment\"><a href=\"#{attachment.url}\" target=\"_blank\"><img src=\"#{attachment.image_url}\" /></a></div>"
);

var messagePdfTemplate = new Template(
      "<div class=\"file_attachment\">\
        <a href=\"#{attachment.url}\" target=\"_blank\"><img alt=\"PDF Document\" src=\"/images/icons/pdf_large.jpg\" width=\"100\" /></a>\
        </div>"
);

var messageZipTemplate = new Template(
  "<div class=\"file_attachment\">\
    <a href=\"#{attachment.url}\" target=\"_blank\"><img alt=\"ZIP File\" src=\"/images/icons/zip_large.jpg\" width=\"82\" /></a>\
    </div>"
);

var messageBottomTemplate = new Template(
			"#{message.body}\
			  <div class=\"meta\">\
	      <span class=\"date quiet small\">\
			  	<a href=\"/conversations/#{convo.id}-#{convo.name}/messages/#{message.id}\" title=\"#{message.date}\">#{message.time}</a> -\
			  </span>\
			  <span class=\"username\"><a href=\"/conversations/#{convo.id}-#{convo.name}\" class=\"tip\" title=\"Personal convo for #{user.login}\">#{user.login}</a></span>\
			  <div class=\"messagelinks quiet small\">\
  				<a href=\"#\" onclick=\"if (confirm(\'#{t.report_confirmation}\')) { new Ajax.Request(\'/conversations/#{convo.id}-#{convo.name}/messages/#{message.id}/report\', {asynchronous:true, evalScripts:true}); }; return false;\">#{t.report}</a>\
  	      <a href=\"/conversations/new/spawn?message_id=#{message.id}\" onclick=\"if (confirm(\'#{t.spawn_confirmation}\')) { var f = document.createElement(\'form\'); f.style.display = \'none\'; this.parentNode.appendChild(f); f.method = \'POST\'; f.action = this.href;var m = document.createElement(\'input\'); m.setAttribute(\'type\', \'hidden\'); m.setAttribute(\'name\', \'_method\'); m.setAttribute(\'value\', \'get\'); f.appendChild(m);f.submit(); };return false;\">#{t.spawn}</a>\
  		  </div>\
      </div>\
		</div>\
		<div class=\"clear\"></div>\
	</div>"
);

// system message template
//---------------------------------------------------------------------------
var systemMessageTemplate = new Template(
"<div class=\"message system\" id=\"message_#{message.id}\">\
  <div class=\"avatar\"><img alt=\"Icon\" src=\"/images/icon.png\" width=\"30\" /></div>\
	<div class=\"messagetext\">\
    <span class=\"username\"><a href=\"/conversations/#{convo.id}-#{convo.name}\" class=\"tip\" title=\"Personal convo for #{user.login}\">#{user.login}</a></span>\
    #{message.unfiltered_body}\
		<span class=\"date quiet small\"><a href=\"/conversations/#{convo.id}-#{convo.name}/messages/#{message.id}\" title=\"#{message.date}\">#{message.time}</a></span>\
	</div>\
	<div class=\"clear\"></div>\
</div>"
);


function JsonToHtml(json)
{
  if(json.meta.system) {
    var html = systemMessageTemplate.evaluate(json);
  } else { 
    var html = messageTopTemplate.evaluate(json);
    if(json.meta.has_image) { html += messageImageTemplate.evaluate(json);}
    if(json.meta.has_zip) { html += messageZipTemplate.evaluate(json);}
    if(json.meta.has_pdf) { html += messagePdfTemplate.evaluate(json);}
	  html += messageBottomTemplate.evaluate(json);
	}
	return html;
}

//---------------------------------------------------------------------------
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

var BrowserDetect = {
	init: function () {
		this.browser = this.searchString(this.dataBrowser) || "An unknown browser";
		this.version = this.searchVersion(navigator.userAgent)
			|| this.searchVersion(navigator.appVersion)
			|| "an unknown version";
		this.OS = this.searchString(this.dataOS) || "an unknown OS";
	},
	searchString: function (data) {
		for (var i=0;i<data.length;i++)	{
			var dataString = data[i].string;
			var dataProp = data[i].prop;
			this.versionSearchString = data[i].versionSearch || data[i].identity;
			if (dataString) {
				if (dataString.indexOf(data[i].subString) != -1)
					return data[i].identity;
			}
			else if (dataProp)
				return data[i].identity;
		}
	},
	searchVersion: function (dataString) {
		var index = dataString.indexOf(this.versionSearchString);
		if (index == -1) return;
		return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
	},
	dataBrowser: [
		{
			string: navigator.userAgent,
			subString: "Chrome",
			identity: "Chrome"
		},
		{ 	string: navigator.userAgent,
			subString: "OmniWeb",
			versionSearch: "OmniWeb/",
			identity: "OmniWeb"
		},
		{
			string: navigator.vendor,
			subString: "Apple",
			identity: "Safari",
			versionSearch: "Version"
		},
		{
			prop: window.opera,
			identity: "Opera"
		},
		{
			string: navigator.vendor,
			subString: "iCab",
			identity: "iCab"
		},
		{
			string: navigator.vendor,
			subString: "KDE",
			identity: "Konqueror"
		},
		{
			string: navigator.userAgent,
			subString: "Firefox",
			identity: "Firefox"
		},
		{
			string: navigator.vendor,
			subString: "Camino",
			identity: "Camino"
		},
		{		// for newer Netscapes (6+)
			string: navigator.userAgent,
			subString: "Netscape",
			identity: "Netscape"
		},
		{
			string: navigator.userAgent,
			subString: "MSIE",
			identity: "Explorer",
			versionSearch: "MSIE"
		},
		{
			string: navigator.userAgent,
			subString: "Gecko",
			identity: "Mozilla",
			versionSearch: "rv"
		},
		{ 		// for older Netscapes (4-)
			string: navigator.userAgent,
			subString: "Mozilla",
			identity: "Netscape",
			versionSearch: "Mozilla"
		}
	],
	dataOS : [
		{
			string: navigator.platform,
			subString: "Win",
			identity: "Windows"
		},
		{
			string: navigator.platform,
			subString: "Mac",
			identity: "Mac"
		},
		{
			   string: navigator.userAgent,
			   subString: "iPhone",
			   identity: "iPhone/iPod"
	    },
		{
			string: navigator.platform,
			subString: "Linux",
			identity: "Linux"
		}
	]

};
BrowserDetect.init();