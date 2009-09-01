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

I18n.translations = I18n.translations || {"conversations":{"user_spawned_convo_description":"{{login}} maakte dit bericht van het bericht {{original_message_link}}\n\nBedenk alsjeblieft een nieuwe titel en beschrijving voor dit gesprek","look_for_conversations":"zoek convos","start_new_conversation":"begin een nieuwe convo","already_spawned_warning":"Je hebt al een nieuw gesprek gemaakt van dit bericht!","not_allowed_to_write_warning":"Je mag geen berichten toevoegen aan dit gesprek.","recently_started_conversations":"nieuwe convos","login_or_register_to_participate":"Registreer <a href=\"/login\">login</a> om deel te nemen.<br/>Heb je nog geen account? <a href=\"/signup\">Registreer</a>, het is gratis","go_to_conversation":"Ga naar gesprek","convo_sucesfully_created":"Gesprek succesvol gemaakt.","new_conversation":"nieuwe convos","bookmarked_conversations":"gemarkeerde gesprekken","this_is_an_read_only_convo":"Dit is een alleen-lezen gesprek","new_spawned_conversation":"nieuw gesprek van bericht"},"users":{"since":"sinds:","could_not_login_as":"Kon niet inloggen als {{login}}","recently_joined_users":"nieuwe gebruikers","invite_followed_users":"Invite followed users","invite_users":"Nodig gebruikers uit","about":"About you","sign_up_as_new_user":"registreren","n_followers":"{{number}} followers","look_for_users":"zoek nieuwe gebruikers","logged_out":"Je bent uitgelogd.","signup_complete":"Registratie compleet! Login om je account te activeren.","since_date":"since: {{date}}","invite_all_followers":"Invite all my followers","n_convos_started":"{{number}} convos started","profile_updated":"Profiel geupdate","n_messages_posted":"{{number}} messages posted","email_invites":"Email invites","following_n_users":"following {{number}} users","logged_in_sucesfully":"succesvol ingelogd"},"home":{"index":{"headline1":"Welkom op Echowaves.","headline2":"The source code is hosted at: <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>.","p1":"<H5>Als je van kletsen, bloggen, foto's laten zien aan je vrienden of gewoon socializen met je vrienden houdt, is Echowaves iets voor jou!","p3":"Klik op 'registeren' om een account te maken","p2":"-- het is gratis en iedereen kan meedoen. Begin je eigen convos, nodig al je vrienden uit voor jouw convos of neem deel aan convos die je interessant lijken. Veel plezier!","feedback_advice":"Als je een fout vindt of een suggestie wil doen, kun je dat doen op <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>"}},"errors":{"sorry_this_is_a_private_convo":"Sorry, this is a private conversation","something_went_wrong":"Something went wrong...","only_the_owner_can_invite":"Alleen de eigenaar kan mensen uitnodigen","no_response_text":"error, no response text"},"footer":{"uptime_monitoring":"Website wordt gecheckt door","conversations":"convos","report_problems_or_abuse":"Problemen of misbruik melden aan:","terms_and_conditions":"Voorwaarden"},"messages":{"new_messages":"nieuw bericht","original_message":"eerste bericht"},"notices":{"you_must_be_logged_out":"Je moet uitgelogd zijn om dit te kunnen zien","you_must_be_logged_in":"Je moet ingelogd zijn om dit te kunnen zien"},"ie6update":{"url":"http://www.microsoft.com/windows/internet-explorer/default.aspx","msg":"Internet Explorer mist een update die nodig is om deze site te bekijken. Klik hier om Internet Explorer te updaten... "},"ui":{"thanks_for_signup":"Bedankt voor het registreren! We sturen je een mail met een activatielink.","following":"Following","reportconfirm":"Weet je zeker dat je dit wilt melden?","search_conversations":"zoek convos","forgotnew":"Vergeten","conversations":"convos","password_confirmation":"Bevestig wachtwoord","total_users":"Totaal aantal gebruikers","unfollow":"unfollow","read_only":"alleen lezen","with_images":"met afbeeldingen","view_all_users":"laat alle gebruikers zien","search_convos_for":"Search conversations for: \"{{string}}\"","tags":"tags","connected":"verbonden","all":"allemaal","name":"naam","home":"home","recent_tags":"Recente tags","back":"terug","spawnconfirm":"Weet je zeker dat je een nieuwe convo wilt maken van dit bericht?","create":"maak","total_messages":"Totaal aantal berichten","users_conversations":"Gebruikers convos","email":"email","change_my_password":"Change My Password","more_messages":"meer berichten","edit_profile":"verander profiel","sound_on":"geluid aan","password":"Wachtwoord","logout":"uitloggen","news":"Nieuw bericht","update":"update","private_convo":"priv\u00e9 gesprek","search_messages":"zoek berichten","tagged_with":"Tagged met","view_all_or_add_a_tag":"<a href=\"#tags\">laat zien</a> of <a href=\"#tags\">voeg een tag toe</a>","test_conversation":"TEST convo","invite":"uitnodigen","last_message":"laatste bericht","make_writable":"maak schrijfbaar","spawn":"spawn","echowaves_conversation":"EcHoWaVeS.CoM convo","follow":"follow","its_free":"Heb je nog geen account? Registreer je dan!","view_all":"laat alles zien","recently_joined":"Recentelijk lid geworden","time_zone":"tijd zone","back_to_parent":"terug naar oorspronkelijk bericht/convo","users":"Gebruikers","attach":"Attach","confirm_remove_tag":"Weet je zeker dat je deze tag ongedaan wil maken?","code":"code","cancel":"stoppen","recently_visited":"Recentelijk bezocht","make_read_only":"maak alleen lezen","shift_enter":"(shift+Enter om naar een nieuwe regel te gaan)","loading_messages":"LOADING MESSAGES","make_public":"maak openbaar","forgot_password":"Wachtwoord vergeten?","update_my_password_and_log_me_in":"Update my password and log me in","messages":"Berichten","recent_convos":"Recente convos","signup_error":"We konden je niet registreren. Probeer het nog eens of neem contact op met een admin.","email_confirmation":"bevestig email","convos":"Convos","total_convos":"Totaal aantal convos","update_your_profile":"Update je profiel","login_name":"gebruikersnaam","send":"verstuur","get_an_gravatar_here":"maak je eigen gravatar","dashboard":"dashboard","recent_followers":"Recente followers","report":"dit is niet OK","attach_file":"Voeg bestand toe als bijlage","add_tag":"voeg een tag toe","transport_opened":"transport opened","transport_closed":"transport closed","followers":"Followers","system_messages":"system messages","with_files":"met bestanden","search":"zoek","make_private":"maak priv\u00e9","this_is_the_newest_message":"Dit is het nieuwste bericht","login":"Inloggen","sound_off":"geluid uit","signup":"Registreren","search_advice":"typ iets en klik hier!","started_by":"gemaakt door","reportconfirm_conversation":"Weet je zeker dat je dit wilt melden?","view_all_convos":"laat alle convos zien","click_to_activate":"Klik hier op je account te bevestigen","my_conversations":"Mijn convos","description":"beschrijving","popular_convos":"Populaire convos"}};
