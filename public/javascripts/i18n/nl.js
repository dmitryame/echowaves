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

I18n.translations = I18n.translations || {"ie6update": {"url": "http://www.microsoft.com/windows/internet-explorer/default.aspx", "msg": "Internet Explorer mist een update die nodig is om deze site te bekijken. Klik hier om Internet Explorer te updaten... "}, "footer": {"terms_and_conditions": "Voorwaarden", "uptime_monitoring": "Website wordt gecheckt door", "conversations": "convos", "report_problems_or_abuse": "Problemen of misbruik melden aan:"}, "messages": {"new_messages": "nieuw bericht", "original_message": "eerste bericht"}, "errors": {"sorry_this_is_a_private_convo": "Sorry, dit is een priv\u00e9 gesprek.", "only_the_owner_can_invite": "Alleen de eigenaar kan mensen uitnodigen"}, "notices": {"you_must_be_logged_out": "Je moet uitgelogd zijn om dit te kunnen zien", "you_must_be_logged_in": "Je moet ingelogd zijn om dit te kunnen zien"}, "ui": {"spawnconfirm": "Weet je zeker dat je een nieuwe convo wilt maken van dit bericht?", "recent_tags": "Recente tags", "followers": "Followers", "with_images": "met afbeeldingen", "signup": "Registreren", "its_free": "Heb je nog geen account? Registreer je dan!", "news": "Nieuw bericht", "users_conversations": "Gebruikers convos", "connected": "verbonden", "tagged_with": "Tagged met", "login": "Inloggen", "code": "code", "search_advice": "typ iets en klik hier!", "name": "naam", "make_private": "maak priv\u00e9", "search_messages": "zoek berichten", "recent_followers": "Recente followers", "search_conversations": "zoek convos", "all": "allemaal", "sound_off": "geluid uit", "spawn": "spawn", "make_public": "maak openbaar", "search": "zoek", "private_convo": "priv\u00e9 gesprek", "test_conversation": "TEST convo", "signup_error": "We konden je niet registreren. Probeer het nog eens of neem contact op met een admin.", "logout": "uitloggen", "click_to_activate": "Klik hier op je account te bevestigen", "forgotnew": "Vergeten", "update": "update", "make_writable": "maak schrijfbaar", "home": "home", "view_all_or_add_a_tag": "<a href=\"#tags\">laat zien</a> of <a href=\"#tags\">voeg een tag toe</a>", "follow": "follow", "reportconfirm": "Weet je zeker dat je dit wilt melden?", "view_all_users": "laat alle gebruikers zien", "users": "Gebruikers", "create": "maak", "with_files": "met bestanden", "invite": "uitnodigen", "confirm_remove_tag": "Weet je zeker dat je deze tag ongedaan wil maken?", "transport_closed": "transport closed", "cancel": "stoppen", "make_read_only": "maak alleen lezen", "following": "Following", "this_is_the_newest_message": "Dit is het nieuwste bericht", "total_messages": "Totaal aantal berichten", "report": "dit is niet OK", "forgot_password": "Wachtwoord vergeten?", "time_zone": "tijd zone", "messages": "Berichten", "unfollow": "unfollow", "edit_profile": "verander profiel", "shift_enter": "(shift+Enter om naar een nieuwe regel te gaan)", "last_message": "laatste bericht", "recently_visited": "Recentelijk bezocht", "get_an_gravatar_here": "maak je eigen gravatar", "description": "beschrijving", "sound_on": "geluid aan", "thanks_for_signup": "Bedankt voor het registreren! We sturen je een mail met een activatielink.", "convos": "Convos", "login_name": "gebruikersnaam", "attach_file": "Voeg bestand toe als bijlage", "password_confirmation": "Bevestig wachtwoord", "total_users": "Totaal aantal gebruikers", "echowaves_conversation": "EcHoWaVeS.CoM convo", "send": "verstuur", "read_only": "alleen lezen", "back_to_parent": "terug naar oorspronkelijk bericht/convo", "password": "Wachtwoord", "back": "terug", "recently_joined": "Recentelijk lid geworden", "transport_opened": "transport opened", "view_all_convos": "laat alle convos zien", "add_tag": "voeg een tag toe", "reportconfirm_conversation": "Weet je zeker dat je dit wilt melden?", "email": "email", "view_all": "laat alles zien", "conversations": "convos", "more_messages": "meer berichten", "my_conversations": "Mijn convos", "started_by": "gemaakt door", "attach": "Attach", "recent_convos": "Recente convos", "email_confirmation": "bevestig email", "update_your_profile": "Update je profiel", "popular_convos": "Populaire convos", "tags": "tags", "total_convos": "Totaal aantal convos"}, "users": {"recently_joined_users": "nieuwe gebruikers", "sign_up_as_new_user": "registreren", "logged_out": "Je bent uitgelogd.", "signup_complete": "Registratie compleet! Login om je account te activeren.", "invite_users": "Nodig gebruikers uit", "since": "sinds:", "could_not_login_as": "Kon niet inloggen als {{login}}", "look_for_users": "zoek nieuwe gebruikers", "profile_updated": "Profiel geupdate", "logged_in_sucesfully": "succesvol ingelogd"}, "conversations": {"already_spawned_warning": "Je hebt al een nieuw gesprek gemaakt van dit bericht!", "start_new_conversation": "begin een nieuwe convo", "recently_started_conversations": "nieuwe convos", "not_allowed_to_write_warning": "Je mag geen berichten toevoegen aan dit gesprek.", "bookmarked_conversations": "gemarkeerde gesprekken", "go_to_conversation": "Ga naar gesprek", "login_or_register_to_participate": "Registreer <a href=\"/login\">login</a> om deel te nemen.<br/>Heb je nog geen account? <a href=\"/signup\">Registreer</a>, het is gratis", "convo_sucesfully_created": "Gesprek succesvol gemaakt.", "new_spawned_conversation": "nieuw gesprek van bericht", "new_conversation": "nieuwe convos", "this_is_an_read_only_convo": "Dit is een alleen-lezen gesprek", "look_for_conversations": "zoek convos", "user_spawned_convo_description": "{{login}} maakte dit bericht van het bericht {{original_message_link}}\n\nBedenk alsjeblieft een nieuwe titel en beschrijving voor dit gesprek"}, "home": {"index": {"p3": "Klik op 'registeren' om een account te maken", "feedback_advice": "Als je een fout vindt of een suggestie wil doen, kun je dat doen op <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>", "p1": "<H5>Als je van kletsen, bloggen, foto's laten zien aan je vrienden of gewoon socializen met je vrienden houdt, is Echowaves iets voor jou!", "p2": "-- het is gratis en iedereen kan meedoen. Begin je eigen convos, nodig al je vrienden uit voor jouw convos of neem deel aan convos die je interessant lijken. Veel plezier!", "headline1": "Welkom op Echowaves.", "headline2": "The source code is hosted at: <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>."}}};
