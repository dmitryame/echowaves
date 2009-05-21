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

I18n.translations = I18n.translations || {"ie6update": {"url": "http://www.microsoft.com/windows/internet-explorer/default.aspx", "msg": "Internet Explorer is missing updates required to view this site. Click here to update... "}, "number": {"percentage": {"format": {"delimiter": ""}}, "precision": {"format": {"delimiter": ""}}, "currency": {"format": {"precision": 2, "separator": ".", "format": "%u%n", "delimiter": ",", "unit": "$"}}, "format": {"precision": 3, "separator": ".", "delimiter": ","}, "human": {"format": {"precision": 1, "delimiter": ""}, "storage_units": {"units": {"byte": {"other": "Bytes", "one": "Byte"}, "kb": "KB", "mb": "MB", "tb": "TB", "gb": "GB"}, "format": "%n %u"}}}, "footer": {"terms_and_conditions": "Terms&Conditions", "uptime_monitoring": "Website Uptime Monitoring By", "conversations": "convos", "report_problems_or_abuse": "Report problems or Abuse to"}, "activerecord": {"errors": {"messages": {"inclusion": "is not included in the list", "equal_to": "must be equal to {{count}}", "less_than": "must be less than {{count}}", "accepted": "must be accepted", "empty": "can't be empty", "wrong_length": "is the wrong length (should be {{count}} characters)", "exclusion": "is reserved", "invalid": "is invalid", "less_than_or_equal_to": "must be less than or equal to {{count}}", "not_a_number": "is not a number", "taken": "has already been taken", "too_short": "is too short (minimum is {{count}} characters)", "odd": "must be odd", "greater_than": "must be greater than {{count}}", "too_long": "is too long (maximum is {{count}} characters)", "confirmation": "doesn't match confirmation", "blank": "can't be blank", "even": "must be even", "greater_than_or_equal_to": "must be greater than or equal to {{count}}"}, "template": {"header": {"other": "{{count}} errors prohibited this {{model}} from being saved", "one": "1 error prohibited this {{model}} from being saved"}, "body": "There were problems with the following fields:"}}}, "messages": {"new_messages": "new messages", "original_message": "original message"}, "errors": {"sorry_this_is_a_private_convo": "Sorry, this is a private conversation. You can try anoter one", "only_the_owner_can_invite": "Only the owner of this conversation can invite other users"}, "support": {"array": {"two_words_connector": " and ", "last_word_connector": ", and ", "words_connector": ", "}}, "notices": {"you_must_be_logged_out": "You must be logged out to access this page", "you_must_be_logged_in": "You must be logged in to access this page"}, "ui": {"spawnconfirm": "Are you sure you want to spawn a new convo off of this message?", "recent_tags": "Recent tags", "followers": "Followers", "with_images": "with images", "signup": "SignUp", "its_free": "it's free and anyone can join", "news": "New Messages", "users_conversations": "Users convos", "connected": "connected", "tagged_with": "Tagged with", "login": "login", "code": "code", "search_advice": "write something and click search!", "name": "name", "make_private": "make private", "receive_email_notifications": "Receive email notifications", "search_messages": "search messages", "recent_followers": "Recent followers", "search_conversations": "search convos", "all": "all", "sound_off": "sound off", "spawn": "spawn", "make_public": "make public", "search": "search", "private_convo": "Private conversation", "test_conversation": "TEST convo", "signup_error": "We couldn't set up that account, sorry. Please try again, or contact an admin (link is above).", "logout": "logout", "click_to_activate": "Click here to activate your account", "update": "update", "make_writable": "make writable", "home": "home", "view_all_or_add_a_tag": "<a href=\"#tags\">view all</a> or <a href=\"#tags\">add a tag</a>", "follow": "follow", "reportconfirm": "Are you sure you would like to report this message? The abuser will be punished.", "view_all_users": "view all users", "users": "users", "create": "create", "with_files": "with files", "invite": "invite", "confirm_remove_tag": "Are you sure you want to untag?", "followed_convos": "Followed Convos", "transport_closed": "transport closed", "cancel": "cancel", "make_read_only": "set as read only", "following": "Following", "this_is_the_newest_message": "This is the newest message", "total_messages": "Total messages", "report": "report", "forgot_password": "forgot password?", "time_zone": "time zone", "messages": "Messages", "unfollow": "unfollow", "edit_profile": "edit profile", "shift_enter": "(shift+Enter to insert new line)", "last_message": "last message", "recently_visited": "Recently visited", "get_an_gravatar_here": "get a gravatar here", "description": "description", "sound_on": "sound on", "thanks_for_signup": "Thanks for signing up! We're sending you an email with your activation code.", "convos": "Convos", "login_name": "login name", "attach_file": "attach file", "followed_users": "Followed Users", "password_confirmation": "confirm password", "total_users": "Total users", "echowaves_conversation": "EcHoWaVeS.CoM convo", "send": "send", "read_only": "read only", "back_to_parent": "back to parent", "password": "password", "back": "back", "recently_joined": "Recently joined", "transport_opened": "transport opened", "view_all_convos": "view all convos", "add_tag": "add tag", "reportconfirm_conversation": "Are you sure you would like to report this convo? The abuser will be punished.", "email": "email", "view_all": "view all", "conversations": "convos", "more_messages": "more messages", "my_conversations": "My convos", "started_by": "started by", "attach": "Attach", "recent_convos": "Recent convos", "email_confirmation": "confirm email", "update_your_profile": "Update your profile", "popular_convos": "Popular convos", "tags": "tags", "total_convos": "Total convos"}, "users": {"recently_joined_users": "recently joined users", "sign_up_as_new_user": "sign up as new user", "logged_out": "You have been logged out.", "signup_complete": "Signup complete! Please login to continue.", "invite_users": "Invite users", "since": "since:", "could_not_login_as": "Couldn't log you in as {{login}}", "look_for_users": "look for users", "profile_updated": "Profile updated correctly", "logged_in_sucesfully": "Logged in successfully"}, "time": {"am": "am", "formats": {"long": "%B %d, %Y %H:%M", "default": "%a, %d %b %Y %H:%M:%S %z", "short": "%d %b %H:%M"}, "pm": "pm"}, "conversations": {"already_spawned_warning": "You already spawned a new conversation from this message.", "start_new_conversation": "start new convo", "recently_started_conversations": "recently started convos", "not_allowed_to_write_warning": "You are not allowed to add messages to this conversation.", "bookmarked_conversations": "bookmarked conversations", "go_to_conversation": "go to conversation", "login_or_register_to_participate": "Please <a href=\"/login\">login</a> to participate.<br/>Don't have an account yet? <a href=\"/signup\">signup now</a>, it's free", "convo_sucesfully_created": "Conversation was successfully created.", "new_spawned_conversation": "new spawned convo", "new_conversation": "new convo", "this_is_an_read_only_convo": "This is a read only conversation", "look_for_conversations": "look for convos", "user_spawned_convo_description": "{{login}} spawned this convo, following the message {{original_message_link}}\n\nPlease provide a description and an appropriate title for this new conversation"}, "datetime": {"prompts": {"day": "Day", "second": "Seconds", "month": "Month", "year": "Year", "minute": "Minute", "hour": "Hour"}, "distance_in_words": {"x_months": {"other": "{{count}} months", "one": "1 month"}, "less_than_x_seconds": {"other": "less than {{count}} seconds", "one": "less than 1 second"}, "about_x_years": {"other": "about {{count}} years", "one": "about 1 year"}, "half_a_minute": "half a minute", "over_x_years": {"other": "over {{count}} years", "one": "over 1 year"}, "about_x_hours": {"other": "about {{count}} hours", "one": "about 1 hour"}, "x_seconds": {"other": "{{count}} seconds", "one": "1 second"}, "x_days": {"other": "{{count}} days", "one": "1 day"}, "less_than_x_minutes": {"other": "less than {{count}} minutes", "one": "less than a minute"}, "about_x_months": {"other": "about {{count}} months", "one": "about 1 month"}, "x_minutes": {"other": "{{count}} minutes", "one": "1 minute"}}}, "date": {"day_names": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], "month_names": [null, "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], "order": ["year", "month", "day"], "formats": {"long": "%B %d, %Y", "default": "%Y-%m-%d", "short": "%b %d"}, "abbr_day_names": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], "abbr_month_names": [null, "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]}, "home": {"index": {"p3": "Take it for a spin, post messages to our ", "feedback_advice": "If you find an issue or would like to make a suggestion on what functionality you would like to see in echowaves, you can do it at <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>", "p1": "<h5>If you like to chat, or blog, or post pictures, or share updates with friends, or just socialize -- you will enjoy EchoWaves.</h5> If you have any ideas or suggestions feel free to talk about it in", "p2": "-- it's free and anyone can join. Start your own convos, invite all your friends to join your convos, follow other convos that look interesting to you. Have fun!", "headline1": "EchoWaves.com is an opensource group chat social network.", "headline2": "The source code is hosted at: <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>."}}};
