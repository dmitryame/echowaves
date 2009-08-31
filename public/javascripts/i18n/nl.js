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

I18n.translations = I18n.translations || {"footer":{"terms_and_conditions":"Voorwaarden","uptime_monitoring":"Website wordt gecheckt door","conversations":"convos","report_problems_or_abuse":"Problemen of misbruik melden aan:"},"home":{"index":{"headline2":"The source code is hosted at: <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>.","p3":"Klik op 'registeren' om een account te maken","p1":"<H5>Als je van kletsen, bloggen, foto's laten zien aan je vrienden of gewoon socializen met je vrienden houdt, is Echowaves iets voor jou!","feedback_advice":"Als je een fout vindt of een suggestie wil doen, kun je dat doen op <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>","p2":"-- het is gratis en iedereen kan meedoen. Begin je eigen convos, nodig al je vrienden uit voor jouw convos of neem deel aan convos die je interessant lijken. Veel plezier!","headline1":"Welkom op Echowaves."}},"errors":{"only_the_owner_can_invite":"Alleen de eigenaar kan mensen uitnodigen","sorry_this_is_a_private_convo":"Sorry, dit is een priv\u00e9 gesprek."},"notices":{"you_must_be_logged_in":"Je moet ingelogd zijn om dit te kunnen zien","you_must_be_logged_out":"Je moet uitgelogd zijn om dit te kunnen zien"},"messages":{"new_messages":"nieuw bericht","original_message":"eerste bericht"},"conversations":{"not_allowed_to_write_warning":"Je mag geen berichten toevoegen aan dit gesprek.","recently_started_conversations":"nieuwe convos","login_or_register_to_participate":"Registreer <a href=\"/login\">login</a> om deel te nemen.<br/>Heb je nog geen account? <a href=\"/signup\">Registreer</a>, het is gratis","go_to_conversation":"Ga naar gesprek","convo_sucesfully_created":"Gesprek succesvol gemaakt.","new_conversation":"nieuwe convos","bookmarked_conversations":"gemarkeerde gesprekken","this_is_an_read_only_convo":"Dit is een alleen-lezen gesprek","new_spawned_conversation":"nieuw gesprek van bericht","user_spawned_convo_description":"{{login}} maakte dit bericht van het bericht {{original_message_link}}\n\nBedenk alsjeblieft een nieuwe titel en beschrijving voor dit gesprek","look_for_conversations":"zoek convos","start_new_conversation":"begin een nieuwe convo","already_spawned_warning":"Je hebt al een nieuw gesprek gemaakt van dit bericht!"},"ie6update":{"url":"http://www.microsoft.com/windows/internet-explorer/default.aspx","msg":"Internet Explorer mist een update die nodig is om deze site te bekijken. Klik hier om Internet Explorer te updaten... "},"users":{"since":"sinds:","n_followers":"{{number}} followers","look_for_users":"zoek nieuwe gebruikers","signup_complete":"Registratie compleet! Login om je account te activeren.","since_date":"since: {{date}}","invite_all_followers":"Invite all my followers","about":"About you","n_convos_started":"{{number}} convos started","profile_updated":"Profiel geupdate","n_messages_posted":"{{number}} messages posted","logged_out":"Je bent uitgelogd.","email_invites":"Email invites","following_n_users":"following {{number}} users","logged_in_sucesfully":"succesvol ingelogd","could_not_login_as":"Kon niet inloggen als {{login}}","recently_joined_users":"nieuwe gebruikers","invite_followed_users":"Invite followed users","invite_users":"Nodig gebruikers uit","sign_up_as_new_user":"registreren"},"ui":{"recently_visited":"Recentelijk bezocht","following":"Following","recent_convos":"Recente convos","forgot_password":"Wachtwoord vergeten?","popular_convos":"Populaire convos","transport_closed":"transport closed","password_confirmation":"Bevestig wachtwoord","total_convos":"Totaal aantal convos","read_only":"alleen lezen","view_all":"laat alles zien","this_is_the_newest_message":"Dit is het nieuwste bericht","tags":"tags","cancel":"stoppen","all":"allemaal","name":"naam","home":"home","get_an_gravatar_here":"maak je eigen gravatar","back":"terug","update_your_profile":"Update je profiel","create":"maak","recent_followers":"Recente followers","attach_file":"Voeg bestand toe als bijlage","email":"email","search_advice":"typ iets en klik hier!","make_private":"maak priv\u00e9","system_messages":"system messages","spawn":"spawn","password":"Wachtwoord","thanks_for_signup":"Bedankt voor het registreren! We sturen je een mail met een activatielink.","sound_off":"geluid uit","update":"update","convos":"Convos","tagged_with":"Tagged met","total_users":"Totaal aantal gebruikers","reportconfirm_conversation":"Weet je zeker dat je dit wilt melden?","invite":"uitnodigen","login_name":"gebruikersnaam","search_messages":"zoek berichten","my_conversations":"Mijn convos","view_all_or_add_a_tag":"<a href=\"#tags\">laat zien</a> of <a href=\"#tags\">voeg een tag toe</a>","click_to_activate":"Klik hier op je account te bevestigen","follow":"follow","view_all_convos":"laat alle convos zien","with_files":"met bestanden","reportconfirm":"Weet je zeker dat je dit wilt melden?","time_zone":"tijd zone","conversations":"convos","more_messages":"meer berichten","forgotnew":"Vergeten","unfollow":"unfollow","code":"code","logout":"uitloggen","recent_tags":"Recente tags","started_by":"gemaakt door","signup":"Registreren","users_conversations":"Gebruikers convos","shift_enter":"(shift+Enter om naar een nieuwe regel te gaan)","messages":"Berichten","total_messages":"Totaal aantal berichten","spawnconfirm":"Weet je zeker dat je een nieuwe convo wilt maken van dit bericht?","search_conversations":"zoek convos","email_confirmation":"bevestig email","edit_profile":"verander profiel","its_free":"Heb je nog geen account? Registreer je dan!","with_images":"met afbeeldingen","send":"verstuur","news":"Nieuw bericht","attach":"Attach","connected":"verbonden","report":"dit is niet OK","test_conversation":"TEST convo","add_tag":"voeg een tag toe","view_all_users":"laat alle gebruikers zien","followers":"Followers","make_writable":"maak schrijfbaar","transport_opened":"transport opened","search":"zoek","echowaves_conversation":"EcHoWaVeS.CoM convo","make_public":"maak openbaar","sound_on":"geluid aan","login":"Inloggen","recently_joined":"Recentelijk lid geworden","users":"Gebruikers","signup_error":"We konden je niet registreren. Probeer het nog eens of neem contact op met een admin.","private_convo":"priv\u00e9 gesprek","confirm_remove_tag":"Weet je zeker dat je deze tag ongedaan wil maken?","back_to_parent":"terug naar oorspronkelijk bericht/convo","last_message":"laatste bericht","make_read_only":"maak alleen lezen","description":"beschrijving"}};
