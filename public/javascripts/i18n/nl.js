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

I18n.translations = I18n.translations || {"messages": {"new_messages": "nieuw bericht", "original_message": "eerste bericht"}, "errors": {"only_the_owner_can_invite": "Alleen de eigenaar kan mensen uitnodigen", "sorry_this_is_a_private_convo": "Sorry, dit is een priv\u00e9 gesprek."}, "ui": {"thanks_for_signup": "Bedankt voor het registreren! We sturen je een mail met een activatielink.", "invite": "uitnodigen", "attach_file": "Voeg bestand toe als bijlage", "followers": "Followers", "login_name": "gebruikersnaam", "total_users": "Totaal aantal gebruikers", "echowaves_conversation": "EcHoWaVeS.CoM convo", "back_to_parent": "terug naar oorspronkelijk bericht/convo", "tagged_with": "Tagged met", "login": "Inloggen", "code": "code", "transport_opened": "transport opened", "unfollow": "unfollow", "name": "naam", "recently_joined": "Recentelijk lid geworden", "view_all_convos": "laat alle convos zien", "recent_followers": "Recente followers", "view_all": "laat alles zien", "all": "allemaal", "reportconfirm_conversation": "Weet je zeker dat je dit wilt melden?", "more_messages": "meer berichten", "search": "zoek", "started_by": "gemaakt door", "my_conversations": "Mijn convos", "recent_convos": "Recente convos", "update": "update", "attach": "Attach", "convos": "Convos", "update_your_profile": "Update je profiel", "home": "home", "popular_convos": "Populaire convos", "follow": "follow", "total_convos": "Totaal aantal convos", "spawnconfirm": "Weet je zeker dat je een nieuwe convo wilt maken van dit bericht?", "users": "Gebruikers", "create": "maak", "with_images": "met afbeeldingen", "recent_tags": "Recente tags", "its_free": "Heb je nog geen account? Registreer je dan!", "connected": "verbonden", "users_conversations": "Gebruikers convos", "signup": "Registreren", "following": "Following", "make_private": "maak priv\u00e9", "report": "dit is niet OK", "time_zone": "tijd zone", "messages": "Berichten", "search_advice": "typ iets en klik hier!", "search_messages": "zoek berichten", "sound_off": "geluid uit", "email_confirmation": "bevestig email", "search_conversations": "zoek convos", "last_message": "laatste bericht", "make_public": "maak openbaar", "test_conversation": "TEST convo", "description": "beschrijving", "private_convo": "priv\u00e9 gesprek", "signup_error": "We konden je niet registreren. Probeer het nog eens of neem contact op met een admin.", "click_to_activate": "Klik hier op je account te bevestigen", "forgotnew": "Vergeten", "make_writable": "maak schrijfbaar", "password_confirmation": "Bevestig wachtwoord", "logout": "uitloggen", "reportconfirm": "Weet je zeker dat je dit wilt melden?", "send": "verstuur", "news": "Nieuw bericht", "read_only": "alleen lezen", "view_all_or_add_a_tag": "<a href=\"#tags\">laat zien</a> of <a href=\"#tags\">voeg een tag toe</a>", "view_all_users": "laat alle gebruikers zien", "password": "Wachtwoord", "back": "terug", "confirm_remove_tag": "Weet je zeker dat je deze tag ongedaan wil maken?", "spawn": "spawn", "with_files": "met bestanden", "transport_closed": "transport closed", "add_tag": "voeg een tag toe", "make_read_only": "maak alleen lezen", "email": "email", "cancel": "stoppen", "conversations": "convos", "this_is_the_newest_message": "Dit is het nieuwste bericht", "forgot_password": "Wachtwoord vergeten?", "total_messages": "Totaal aantal berichten", "shift_enter": "(shift+Enter om naar een nieuwe regel te gaan)", "edit_profile": "verander profiel", "recently_visited": "Recentelijk bezocht", "sound_on": "geluid aan", "tags": "tags", "get_an_gravatar_here": "maak je eigen gravatar"}, "users": {"since_date": "since: {{date}}", "sign_up_as_new_user": "registreren", "profile_updated": "Profiel geupdate", "invite_users": "Nodig gebruikers uit", "signup_complete": "Registratie compleet! Login om je account te activeren.", "following_n_users": "following {{number}} users", "look_for_users": "zoek nieuwe gebruikers", "logged_out": "Je bent uitgelogd.", "n_convos_started": "{{number}} convos started", "n_messages_posted": "{{number}} messages posted", "since": "sinds:", "could_not_login_as": "Kon niet inloggen als {{login}}", "logged_in_sucesfully": "succesvol ingelogd", "n_followers": "{{number}} followers", "recently_joined_users": "nieuwe gebruikers"}, "ie6update": {"url": "http://www.microsoft.com/windows/internet-explorer/default.aspx", "msg": "Internet Explorer mist een update die nodig is om deze site te bekijken. Klik hier om Internet Explorer te updaten... "}, "footer": {"terms_and_conditions": "Voorwaarden", "uptime_monitoring": "Website wordt gecheckt door", "report_problems_or_abuse": "Problemen of misbruik melden aan:", "conversations": "convos"}, "conversations": {"bookmarked_conversations": "gemarkeerde gesprekken", "go_to_conversation": "Ga naar gesprek", "login_or_register_to_participate": "Registreer <a href=\"/login\">login</a> om deel te nemen.<br/>Heb je nog geen account? <a href=\"/signup\">Registreer</a>, het is gratis", "convo_sucesfully_created": "Gesprek succesvol gemaakt.", "new_spawned_conversation": "nieuw gesprek van bericht", "new_conversation": "nieuwe convos", "this_is_an_read_only_convo": "Dit is een alleen-lezen gesprek", "look_for_conversations": "zoek convos", "user_spawned_convo_description": "{{login}} maakte dit bericht van het bericht {{original_message_link}}\n\nBedenk alsjeblieft een nieuwe titel en beschrijving voor dit gesprek", "already_spawned_warning": "Je hebt al een nieuw gesprek gemaakt van dit bericht!", "start_new_conversation": "begin een nieuwe convo", "recently_started_conversations": "nieuwe convos", "not_allowed_to_write_warning": "Je mag geen berichten toevoegen aan dit gesprek."}, "notices": {"you_must_be_logged_out": "Je moet uitgelogd zijn om dit te kunnen zien", "you_must_be_logged_in": "Je moet ingelogd zijn om dit te kunnen zien"}, "home": {"index": {"headline1": "Welkom op Echowaves.", "p1": "<H5>Als je van kletsen, bloggen, foto's laten zien aan je vrienden of gewoon socializen met je vrienden houdt, is Echowaves iets voor jou!", "headline2": "The source code is hosted at: <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>.", "p2": "-- het is gratis en iedereen kan meedoen. Begin je eigen convos, nodig al je vrienden uit voor jouw convos of neem deel aan convos die je interessant lijken. Veel plezier!", "p3": "Klik op 'registeren' om een account te maken", "feedback_advice": "Als je een fout vindt of een suggestie wil doen, kun je dat doen op <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>"}}};
