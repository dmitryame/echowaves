// I18n is slightly modified version of babilu.js from Tore Darell

var I18n = I18n || (function() {
    // Replace {{foo}} with obj.foo
    function interpolate(string, object) {
        return string.replace(/\{\{([^}]+)\}\}/g, function() {
            return object[arguments[1]] || arguments[0];
        });
    };

    // Split "foo.bar" to ["foo", "bar"] if key is a string
    function keyToArray(key) {
        if(!key) {
            return [];
        }
        if(typeof key != "string") {
            return key;
        }
        return key.split('.');
    };

    // Looks up a translation using an array of strings where the last
    // is the key and any string before that define the scope. The
    // current locale is always prepended and does not need to be
    // provided. The second parameter is an array of strings used as
    // defaults if the key can not be found. If a key starts with ":"
    // it is used as a key for lookup.  This method does not perform
    // pluralization or interpolation.
    function lookup(keys, defaults) {
        var i = 0, value = I18n.translations;
        defaults = (typeof defaults === "string") ? [defaults] : (defaults || []);
        while(keys[i]) {
            value = value && value[keys[i]];
            i++;
        }
        if(value) {
            return value;
        } else {
            if(defaults.length === 0) {
                return null;
            } else if (defaults[0].substr(0,1) === ':') {
                return lookup(keys.slice(0, keys.length - 1).concat(keyToArray(defaults[0].substr(1))), defaults.slice(1));
            } else {
                return defaults[0];
            }
        }
    };

    // Returns other when 0 given
    function pluralize(value, count) {
        if(count === undefined) return value;
        return count === 1 ? value.one : value.other;
    };

    // Works mostly the same as the Ruby equivalent, except there are
    // no symbols in JavaScript, so keys are always strings. The only
    // time this makes a difference is when differentiating between
    // keys and values in the defaultValue option. Strings starting
    // with ":" will be considered to be keys and used for lookup,
    // while other strings are returned as-is.
    function translate(key, options) {
        if(typeof key != "string") {
            // Bulk lookup
            var a = [], i;
            for(i = 0; i < key.length; i++) {
                a.push(translate(key[i], options));
            }
            return a;
        } else {
            options = options || {};
            options.defaultValue = options.defaultValue || null;
            key = keyToArray(options.scope).concat(keyToArray(key));
            var value = lookup(key, options.defaultValue);
            if(typeof value !== "string" && value) {
                value = pluralize(value, options.count);
            }
            if(typeof value === "string") {
                value = interpolate(value, options);
            }
            return value;
        }
    }

    return {
        translate: translate,
        t: translate
    };
})();

I18n.translations = I18n.translations || {"date":{"formats":{"default":"%Y-%m-%d","short":"%b %d","long":"%B %d, %Y"},"abbr_day_names":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"order":["year","month","day"],"day_names":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"abbr_month_names":[null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"month_names":[null,"January","February","March","April","May","June","July","August","September","October","November","December"]},"conversations":{"this_is_an_read_only_convo":"This is a read only conversation","recently_started_conversations":"recently started convos","go_to_conversation":"go to conversation","start_new_conversation":"start new convo","bookmarked_conversations":"bookmarked conversations","new_conversation":"new convo","already_spawned_warning":"You already spawned a new conversation from this message.","not_allowed_to_write_warning":"You are not allowed to add messages to this conversation.","convo_sucesfully_created":"Conversation was successfully created.","login_or_register_to_participate":"Please <a href=\"/login\">login</a> to participate.<br/>Don't have an account yet? <a href=\"/signup\">signup now</a>, it's free","look_for_conversations":"look for convos","user_spawned_convo_description":"{{login}} spawned this convo, following the message {{original_message_link}}\n\nPlease provide a description and an appropriate title for this new conversation","new_spawned_conversation":"new spawned convo"},"ui":{"view_all_users":"view all users","make_read_only":"set as read only","convos":"Convos","add_tag":"add tag","connected":"connected","view_all_convos":"view all convos","search":"search","following":"Following","forgot_password":"forgot password?","shift_enter":"(shift+Enter to insert new line)","messages":"Messages","back":"back","send":"send","click_to_activate":"Click here to activate your account","more_messages":"more messages","report":"report","description":"description","sound_on":"sound on","email_confirmation":"confirm email","attach_file":"attach file","make_public":"make public","confirm_remove_tag":"Are you sure you want to untag?","tags":"tags","invite":"invite","popular_convos":"Popular convos","search_messages":"search messages","follow":"follow","my_conversations":"My convos","home":"home","search_advice":"write something and click search!","recently_joined":"Recently joined","transport_closed":"transport closed","users":"users","change_my_password":"Change My Password","total_messages":"Total messages","spawnconfirm":"Are you sure you want to spawn a new convo off of this message?","view_all":"view all","login":"login","cancel":"cancel","edit_profile":"edit profile","this_is_the_newest_message":"This is the newest message","make_private":"make private","time_zone":"time zone","back_to_parent":"back to parent","recently_visited":"Recently visited","total_convos":"Total convos","followed_convos":"Followed Convos","private_convo":"Private conversation","signup":"SignUp","update_my_password_and_log_me_in":"Update my password and log me in","read_only":"read only","create":"create","login_name":"login name","conversations":"convos","attach":"Attach","password_confirmation":"confirm password","its_free":"it's free and anyone can join","logout":"logout","sound_off":"sound off","reportconfirm_conversation":"Are you sure you would like to report this convo? The abuser will be punished.","thanks_for_signup":"Thanks for signing up! We're sending you an email with your activation code.","reportconfirm":"Are you sure you would like to report this message? The abuser will be punished.","get_an_gravatar_here":"get a gravatar here","dashboard":"dashboard","last_message":"last message","followers":"Followers","make_writable":"make writable","search_convos_for":"Search conversations for: \"{{string}}\"","update":"update","tagged_with":"Tagged with","update_your_profile":"Update your profile","started_by":"started by","name":"name","search_conversations":"search convos","password":"password","transport_opened":"transport opened","recent_followers":"Recent followers","email":"email","loading_messages":"LOADING MESSAGES","test_conversation":"TEST convo","receive_email_notifications":"Receive email notifications","all":"all","with_files":"with files","recent_tags":"Recent tags","users_conversations":"Users convos","with_images":"with images","spawn":"spawn","unfollow":"unfollow","view_all_or_add_a_tag":"<a href=\"#tags\">view all</a> or <a href=\"#tags\">add a tag</a>","followed_users":"Followed Users","code":"code","recent_convos":"Recent convos","total_users":"Total users","signup_error":"We couldn't set up that account, sorry. Please try again, or contact an admin (link is above).","news":"New Messages","echowaves_conversation":"EcHoWaVeS.CoM convo"},"ie6update":{"msg":"Internet Explorer is missing updates required to view this site. Click here to update... ","url":"http://www.microsoft.com/windows/internet-explorer/default.aspx"},"number":{"format":{"separator":".","delimiter":",","precision":3},"precision":{"format":{"delimiter":""}},"percentage":{"format":{"delimiter":""}},"human":{"storage_units":{"units":{"kb":"KB","mb":"MB","byte":{"one":"Byte","other":"Bytes"},"gb":"GB","tb":"TB"},"format":"%n %u"},"format":{"delimiter":"","precision":1}},"currency":{"format":{"separator":".","delimiter":",","unit":"$","format":"%u%n","precision":2}}},"errors":{"no_response_text":"error, no response text","sorry_this_is_a_private_convo":"Sorry, this is a private conversation","only_the_owner_can_invite":"Only the owner of this conversation can invite other users","something_went_wrong":"Something went wrong..."},"datetime":{"prompts":{"day":"Day","minute":"Minute","month":"Month","year":"Year","second":"Seconds","hour":"Hour"},"distance_in_words":{"about_x_hours":{"one":"about 1 hour","other":"about {{count}} hours"},"x_days":{"one":"1 day","other":"{{count}} days"},"less_than_x_minutes":{"one":"less than a minute","other":"less than {{count}} minutes"},"about_x_months":{"one":"about 1 month","other":"about {{count}} months"},"x_seconds":{"one":"1 second","other":"{{count}} seconds"},"x_minutes":{"one":"1 minute","other":"{{count}} minutes"},"x_months":{"one":"1 month","other":"{{count}} months"},"less_than_x_seconds":{"one":"less than 1 second","other":"less than {{count}} seconds"},"about_x_years":{"one":"about 1 year","other":"about {{count}} years"},"half_a_minute":"half a minute","over_x_years":{"one":"over 1 year","other":"over {{count}} years"}}},"time":{"formats":{"default":"%a, %d %b %Y %H:%M:%S %z","short":"%d %b %H:%M","long":"%B %d, %Y %H:%M"},"pm":"pm","am":"am"},"footer":{"uptime_monitoring":"Website Uptime Monitoring By","conversations":"convos","terms_and_conditions":"Terms&Conditions","report_problems_or_abuse":"Report problems or Abuse to"},"home":{"index":{"p3":"Take it for a spin, post messages to our ","feedback_advice":"If you find an issue or would like to make a suggestion on what functionality you would like to see in echowaves, you can do it at <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>","p1":"<h5>If you like to chat, or blog, or post pictures, or share updates with friends, or just socialize -- you will enjoy EchoWaves.</h5> If you have any ideas or suggestions feel free to talk about it in","p2":"-- it's free and anyone can join. Start your own convos, invite all your friends to join your convos, follow other convos that look interesting to you. Have fun!","headline1":"EchoWaves.com is an opensource Social Group Chat.","headline2":"The source code is hosted at: <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>."}},"support":{"select":{"prompt":"Please select"},"array":{"words_connector":", ","two_words_connector":" and ","last_word_connector":", and "}},"messages":{"new_messages":"new messages","original_message":"original message"},"users":{"email_invites":"Email invites","look_for_users":"look for users","logged_in_sucesfully":"Logged in successfully","invite_users":"Invite users","recently_joined_users":"recently joined users","logged_out":"You have been logged out.","n_convos_started":"{{number}} convos started","profile_updated":"Profile updated correctly","invite_all_followers":"Invite all my followers","n_followers":"{{number}} followers","since_date":"since: {{date}}","n_messages_posted":"{{number}} messages posted","could_not_login_as":"Couldn't log you in as {{login}}","sign_up_as_new_user":"sign up as new user","since":"since:","invite_followed_users":"Invite followed users","following_n_users":"following {{number}} users","about":"About you","signup_complete":"Signup complete! Please login to continue."},"notices":{"you_must_be_logged_out":"You must be logged out to access this page","you_must_be_logged_in":"You must be logged in to access this page"},"activerecord":{"errors":{"template":{"body":"There were problems with the following fields:","header":{"one":"1 error prohibited this {{model}} from being saved","other":"{{count}} errors prohibited this {{model}} from being saved"}},"messages":{"greater_than_or_equal_to":"must be greater than or equal to {{count}}","inclusion":"is not included in the list","equal_to":"must be equal to {{count}}","empty":"can't be empty","accepted":"must be accepted","less_than":"must be less than {{count}}","wrong_length":"is the wrong length (should be {{count}} characters)","exclusion":"is reserved","invalid":"is invalid","not_a_number":"is not a number","taken":"has already been taken","less_than_or_equal_to":"must be less than or equal to {{count}}","too_short":"is too short (minimum is {{count}} characters)","blank":"can't be blank","odd":"must be odd","too_long":"is too long (maximum is {{count}} characters)","greater_than":"must be greater than {{count}}","confirmation":"doesn't match confirmation","record_invalid":"Validation failed: {{errors}}","even":"must be even"},"full_messages":{"format":"{{attribute}} {{message}}"}}}};
