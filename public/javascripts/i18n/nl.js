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

I18n.translations = I18n.translations || {"conversations":{"this_is_an_read_only_convo":"Dit is een alleen-lezen gesprek","recently_started_conversations":"nieuwe convos","go_to_conversation":"Ga naar gesprek","start_new_conversation":"begin een nieuwe convo","bookmarked_conversations":"gemarkeerde gesprekken","new_conversation":"nieuwe convos","already_spawned_warning":"Je hebt al een nieuw gesprek gemaakt van dit bericht!","not_allowed_to_write_warning":"Je mag geen berichten toevoegen aan dit gesprek.","convo_sucesfully_created":"Gesprek succesvol gemaakt.","login_or_register_to_participate":"Registreer <a href=\"/login\">login</a> om deel te nemen.<br/>Heb je nog geen account? <a href=\"/signup\">Registreer</a>, het is gratis","look_for_conversations":"zoek convos","user_spawned_convo_description":"{{login}} maakte dit bericht van het bericht {{original_message_link}}\n\nBedenk alsjeblieft een nieuwe titel en beschrijving voor dit gesprek","new_spawned_conversation":"nieuw gesprek van bericht"},"ui":{"view_all_users":"laat alle gebruikers zien","make_read_only":"maak alleen lezen","convos":"Convos","add_tag":"voeg een tag toe","connected":"verbonden","view_all_convos":"laat alle convos zien","search":"zoek","following":"Following","forgot_password":"Wachtwoord vergeten?","shift_enter":"(shift+Enter om naar een nieuwe regel te gaan)","messages":"Berichten","back":"terug","send":"verstuur","click_to_activate":"Klik hier op je account te bevestigen","more_messages":"meer berichten","report":"dit is niet OK","description":"beschrijving","sound_on":"geluid aan","forgotnew":"Vergeten","email_confirmation":"bevestig email","attach_file":"Voeg bestand toe als bijlage","confirm_remove_tag":"Weet je zeker dat je deze tag ongedaan wil maken?","tags":"tags","invite":"uitnodigen","popular_convos":"Populaire convos","search_messages":"zoek berichten","follow":"follow","my_conversations":"Mijn convos","home":"home","search_advice":"typ iets en klik hier!","recently_joined":"Recentelijk lid geworden","transport_closed":"transport closed","users":"Gebruikers","change_my_password":"Change My Password","total_messages":"Totaal aantal berichten","spawnconfirm":"Weet je zeker dat je een nieuwe convo wilt maken van dit bericht?","view_all":"laat alles zien","login":"Inloggen","cancel":"stoppen","edit_profile":"verander profiel","this_is_the_newest_message":"Dit is het nieuwste bericht","time_zone":"tijd zone","back_to_parent":"terug naar oorspronkelijk bericht/convo","recently_visited":"Recentelijk bezocht","total_convos":"Totaal aantal convos","private_convo":"priv\u00e9 gesprek","signup":"Registreren","update_my_password_and_log_me_in":"Update my password and log me in","read_only":"alleen lezen","create":"maak","login_name":"gebruikersnaam","conversations":"convos","attach":"Attach","password_confirmation":"Bevestig wachtwoord","its_free":"Heb je nog geen account? Registreer je dan!","logout":"uitloggen","sound_off":"geluid uit","reportconfirm_conversation":"Weet je zeker dat je dit wilt melden?","thanks_for_signup":"Bedankt voor het registreren! We sturen je een mail met een activatielink.","reportconfirm":"Weet je zeker dat je dit wilt melden?","get_an_gravatar_here":"maak je eigen gravatar","dashboard":"dashboard","last_message":"laatste bericht","followers":"Followers","make_writable":"maak schrijfbaar","search_convos_for":"Search conversations for: \"{{string}}\"","update":"update","tagged_with":"Tagged met","update_your_profile":"Update je profiel","started_by":"gemaakt door","name":"naam","search_conversations":"zoek convos","password":"Wachtwoord","transport_opened":"transport opened","recent_followers":"Recente followers","email":"email","loading_messages":"LOADING MESSAGES","test_conversation":"TEST convo","all":"allemaal","with_files":"met bestanden","recent_tags":"Recente tags","users_conversations":"Gebruikers convos","with_images":"met afbeeldingen","spawn":"spawn","unfollow":"unfollow","view_all_or_add_a_tag":"<a href=\"#tags\">laat zien</a> of <a href=\"#tags\">voeg een tag toe</a>","code":"code","recent_convos":"Recente convos","total_users":"Totaal aantal gebruikers","signup_error":"We konden je niet registreren. Probeer het nog eens of neem contact op met een admin.","news":"Nieuw bericht","echowaves_conversation":"EcHoWaVeS.CoM convo"},"ie6update":{"msg":"Internet Explorer mist een update die nodig is om deze site te bekijken. Klik hier om Internet Explorer te updaten... ","url":"http://www.microsoft.com/windows/internet-explorer/default.aspx"},"errors":{"no_response_text":"error, no response text","sorry_this_is_a_private_convo":"Sorry, this is a private conversation","only_the_owner_can_invite":"Alleen de eigenaar kan mensen uitnodigen","something_went_wrong":"Something went wrong..."},"footer":{"uptime_monitoring":"Website wordt gecheckt door","conversations":"convos","terms_and_conditions":"Voorwaarden","report_problems_or_abuse":"Problemen of misbruik melden aan:"},"home":{"index":{"p3":"Klik op 'registeren' om een account te maken","feedback_advice":"Als je een fout vindt of een suggestie wil doen, kun je dat doen op <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>","p1":"<H5>Als je van kletsen, bloggen, foto's laten zien aan je vrienden of gewoon socializen met je vrienden houdt, is Echowaves iets voor jou!","p2":"-- het is gratis en iedereen kan meedoen. Begin je eigen convos, nodig al je vrienden uit voor jouw convos of neem deel aan convos die je interessant lijken. Veel plezier!","headline1":"Welkom op Echowaves.","headline2":"The source code is hosted at: <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>."}},"messages":{"new_messages":"nieuw bericht","original_message":"eerste bericht"},"users":{"email_invites":"Email invites","look_for_users":"zoek nieuwe gebruikers","logged_in_sucesfully":"succesvol ingelogd","invite_users":"Nodig gebruikers uit","recently_joined_users":"nieuwe gebruikers","logged_out":"Je bent uitgelogd.","n_convos_started":"{{number}} convos started","profile_updated":"Profiel geupdate","invite_all_followers":"Invite all my followers","n_followers":"{{number}} followers","since_date":"since: {{date}}","n_messages_posted":"{{number}} messages posted","could_not_login_as":"Kon niet inloggen als {{login}}","sign_up_as_new_user":"registreren","since":"sinds:","invite_followed_users":"Invite followed users","following_n_users":"following {{number}} users","about":"About you","signup_complete":"Registratie compleet! Login om je account te activeren."},"notices":{"you_must_be_logged_out":"Je moet uitgelogd zijn om dit te kunnen zien","you_must_be_logged_in":"Je moet ingelogd zijn om dit te kunnen zien"}};
