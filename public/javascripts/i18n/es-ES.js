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

I18n.translations = I18n.translations || {"conversations":{"user_spawned_convo_description":"{{login}} ha creado esta conversacion siguiendo el mensaje {{original_message_link}}\n\nPor favor, escribe una descripcion y un titulo adecuados para esta nueva conversacion","look_for_conversations":"buscar conversaciones","start_new_conversation":"iniciar una nueva conversacion","already_spawned_warning":"Ya has comenzado una nueva conversacion desde este mensaje.","not_allowed_to_write_warning":"No puedes escribir mensajes en esta conversacion.","recently_started_conversations":"conversaciones iniciadas recientemente","login_or_register_to_participate":"Por favor <a href=\"/login\">entra</a> para participar.<br/>\u00bfAun no tienes una cuenta? <a href=\"/signup\">registrate ahora</a>, es gratis","go_to_conversation":"ir a conversacion","convo_sucesfully_created":"La conversacion ha sido creada correctamente.","new_conversation":"nueva conversacion","bookmarked_conversations":"conversaciones favoritas","this_is_an_read_only_convo":"Esta es una conversacion de solo lectura","new_spawned_conversation":"nueva conversacion siguiendo un mensaje"},"users":{"since":"desde:","could_not_login_as":"No se ha podido iniciar la sesion para {{login}}","recently_joined_users":"usuarios registrados recientemente","invite_followed_users":"Invitar a usuarios que yo sigo","invite_users":"Invitar usuarios","about":"Acerca de ti","sign_up_as_new_user":"registrate como usuario","n_followers":"{{number}} seguidores","look_for_users":"buscar usuarios","logged_out":"Se ha cerrado la sesion.","signup_complete":"Registro completado! Inicia sesi\u00f3n para continuar.","since_date":"desde: {{date}}","invite_all_followers":"Invitar a todos mis seguidores","n_convos_started":"{{number}} conversaciones comenzadas","profile_updated":"Perfil actualizado correctamente","n_messages_posted":"{{number}} mensajes publicados","email_invites":"Email invites","following_n_users":"siguiendo a {{number}} usuarios","logged_in_sucesfully":"Conectado con exito"},"home":{"index":{"headline1":"Echowaves.com es un programa de chat y red social","headline2":"El c\u00f3digo fuente se encuentra en <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>.","p1":"<h5>Si te gusta charlar, o escribir un blog, o compartir tu estado con los amigos, o simplemente socializar, EchoWaves es para ti.</h5>Si tienes alguna idea o sugerencia no dudes en hablarnos de ello en la","p3":"Take it for a spin, post messages to our ","p2":"-- es gratis y cualquiera puede unirse. Comienza tus propias conversaciones, invita a todos tus amigos a unirse, sigue de cerca otras conversaciones que te parezcan interesantes y diviertete!","feedback_advice":"Si encuentras algun problema o quieres hacer alguna sugerencia sobre alguna funcionalidad que te gustaria ver en echowaves, puedes hacerlo en <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>"}},"errors":{"sorry_this_is_a_private_convo":"Lo sentimos, esta es una conversacion privada","something_went_wrong":"Algo ha ido mal, intentalo mas tarde...","only_the_owner_can_invite":"Solo el propietario de esta conversacion puede invitar a otros usuarios","no_response_text":"error, no ha texto en la respuesta"},"footer":{"uptime_monitoring":"Website Uptime Monitoring By","conversations":"conversaciones","report_problems_or_abuse":"Informa de problemas o abusos a","terms_and_conditions":"Terminos y Condiciones"},"messages":{"new_messages":"nuevos mensajes","original_message":"mensaje original"},"notices":{"you_must_be_logged_out":"Tienes que terminar la sesion para acceder a esta pagina","you_must_be_logged_in":"Tienes que iniciar sesion para acceder a esta pagina"},"ie6update":{"url":"http://www.microsoft.com/spain/windows/internet-explorer/","msg":"Faltan actualizaciones importantes de Internet Explorer necesarias para ver este sitio. Haga clic aqu\u00ed para actualizar... "},"ui":{"thanks_for_signup":"Gracias por registrarte! Te hemos enviando un correo electr\u00f3nico con tu c\u00f3digo de activaci\u00f3n","following":"Siguiendo","reportconfirm":"Estas seguro de querer informar acerca de este mensaje? El autor del mensaje inapropiado sera castigado.","search_conversations":"buscar convos","conversations":"conversaciones","password_confirmation":"confirmar contrase\u00f1a","total_users":"Usuarios","unfollow":"no seguir","read_only":"solo lectura","with_images":"imagenes","view_all_users":"view all users","search_convos_for":"Buscar conversaciones con: \"{{string}}\"","tags":"etiquetas","connected":"conectado","all":"todo","name":"nombre","home":"inicio","recent_tags":"Recent tags","back":"atras","spawnconfirm":"Estas seguro de querer comenzar una nueva conversacion a partir de este mensaje?","create":"crear","total_messages":"Mensajes","users_conversations":"Conversaciones de los usuarios","email":"email","change_my_password":"Cambiar mi contrase\u00f1a","more_messages":"mas mensajes","edit_profile":"editar perfil","sound_on":"sonido on","password":"contrase\u00f1a","logout":"salir","news":"Nuevos mensajes","update":"actualizar","private_convo":"Conversacion privada","search_messages":"buscar mensajes","tagged_with":"etiquetado con","view_all_or_add_a_tag":"<a href=\"#tags\">ver todos</a> o <a href=\"#tags\">a\u00f1ade un tag</a>","test_conversation":"conversacion de TEST","invite":"invitar","last_message":"ultimo mensaje","followed_convos":"Followed Convos","make_writable":"permitir escritura","spawn":"bifurcar","echowaves_conversation":"conversacion de EcHoWaVeS.CoM","follow":"seguir","its_free":"es gratis y todo el mundo puede unirse","view_all":"view all","recently_joined":"Unidos recientemente","time_zone":"zona horaria","back_to_parent":"convo original","users":"usuarios","attach":"Adjuntar","confirm_remove_tag":"\u00bfEstas seguro de que quieres quitar esta etiqueta?","code":"codigo","cancel":"cancelar","recently_visited":"Visitado recientemente","make_read_only":"hacer de solo lectura","shift_enter":"(mayusculas+Intro para insertar una nueva linea)","loading_messages":"CARGANDO MENSAJES","make_public":"hacer publica","forgot_password":"\u00bfHas olvidado la contrase\u00f1a?","update_my_password_and_log_me_in":"Actualiza mi contrase\u00f1a y entra en la web","messages":"Messages","recent_convos":"Conversaciones recientes","signup_error":"Lo sentimos mucho, no hemos podido crear tu cuenta. Por favor, int\u00e9ntalo de nuevo o ponte en contacto con un administrador (el enlace est\u00e1 m\u00e1s arriba).","email_confirmation":"confirm email","convos":"Convos","total_convos":"Convos","update_your_profile":"Actualiza tu perfil","followed_users":"Usuarios seguidos","login_name":"nombre de usuario","send":"enviar","get_an_gravatar_here":"consigue un gravatar aqui","dashboard":"tablero","recent_followers":"Seguidores recientes","report":"informar","attach_file":"adjuntar archivo","add_tag":"a\u00f1adir tag","transport_opened":"conexion abierta","transport_closed":"conexion cerrada","followers":"Seguidores","system_messages":"system messages","with_files":"archivos","search":"buscar","make_private":"hacer privada","this_is_the_newest_message":"Este es el mensaje mas nuevo","receive_email_notifications":"Recibir notificaciones por email","login":"entrar","sound_off":"sonido off","signup":"Registrate","search_advice":"escribe lo que quieras buscar y haz click en buscar!","started_by":"comenzada por","reportconfirm_conversation":"Estas seguro de querer informar acerca de esta conversation? El autor de la conversacion inapropiada sera castigado.","view_all_convos":"view all convos","click_to_activate":"Click aqui para activar tu cuenta","my_conversations":"Mis conversaciones","description":"descripcion","popular_convos":"Conversaciones populares"}};
