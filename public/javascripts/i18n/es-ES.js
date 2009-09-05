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

I18n.translations = I18n.translations || {"conversations":{"this_is_an_read_only_convo":"Esta es una conversacion de solo lectura","recently_started_conversations":"conversaciones iniciadas recientemente","go_to_conversation":"ir a conversacion","start_new_conversation":"iniciar una nueva conversacion","bookmarked_conversations":"conversaciones favoritas","new_conversation":"nueva conversacion","already_spawned_warning":"Ya has comenzado una nueva conversacion desde este mensaje.","not_allowed_to_write_warning":"No puedes escribir mensajes en esta conversacion.","convo_sucesfully_created":"La conversacion ha sido creada correctamente.","login_or_register_to_participate":"Por favor <a href=\"/login\">entra</a> para participar.<br/>\u00bfAun no tienes una cuenta? <a href=\"/signup\">registrate ahora</a>, es gratis","look_for_conversations":"buscar conversaciones","user_spawned_convo_description":"{{login}} ha creado esta conversacion siguiendo el mensaje {{original_message_link}}\n\nPor favor, escribe una descripcion y un titulo adecuados para esta nueva conversacion","new_spawned_conversation":"nueva conversacion siguiendo un mensaje"},"ui":{"view_all_users":"view all users","make_read_only":"hacer de solo lectura","convos":"Convos","add_tag":"a\u00f1adir tag","connected":"conectado","view_all_convos":"view all convos","search":"buscar","following":"Siguiendo","forgot_password":"\u00bfHas olvidado la contrase\u00f1a?","shift_enter":"(mayusculas+Intro para insertar una nueva linea)","messages":"Messages","back":"atras","send":"enviar","click_to_activate":"Click aqui para activar tu cuenta","more_messages":"mas mensajes","report":"informar","description":"descripcion","sound_on":"sonido on","email_confirmation":"confirm email","attach_file":"adjuntar archivo","make_public":"hacer publica","confirm_remove_tag":"\u00bfEstas seguro de que quieres quitar esta etiqueta?","tags":"etiquetas","invite":"invitar","popular_convos":"Conversaciones populares","search_messages":"buscar mensajes","follow":"seguir","my_conversations":"Mis conversaciones","home":"inicio","search_advice":"escribe lo que quieras buscar y haz click en buscar!","recently_joined":"Unidos recientemente","transport_closed":"conexion cerrada","users":"usuarios","change_my_password":"Cambiar mi contrase\u00f1a","total_messages":"Mensajes","spawnconfirm":"Estas seguro de querer comenzar una nueva conversacion a partir de este mensaje?","view_all":"view all","login":"entrar","cancel":"cancelar","edit_profile":"editar perfil","this_is_the_newest_message":"Este es el mensaje mas nuevo","make_private":"hacer privada","time_zone":"zona horaria","back_to_parent":"convo original","recently_visited":"Visitado recientemente","total_convos":"Convos","followed_convos":"Followed Convos","private_convo":"Conversacion privada","signup":"Registrate","update_my_password_and_log_me_in":"Actualiza mi contrase\u00f1a y entra en la web","read_only":"solo lectura","create":"crear","login_name":"nombre de usuario","conversations":"conversaciones","attach":"Adjuntar","password_confirmation":"confirmar contrase\u00f1a","its_free":"es gratis y todo el mundo puede unirse","logout":"salir","sound_off":"sonido off","reportconfirm_conversation":"Estas seguro de querer informar acerca de esta conversation? El autor de la conversacion inapropiada sera castigado.","thanks_for_signup":"Gracias por registrarte! Te hemos enviando un correo electr\u00f3nico con tu c\u00f3digo de activaci\u00f3n","reportconfirm":"Estas seguro de querer informar acerca de este mensaje? El autor del mensaje inapropiado sera castigado.","get_an_gravatar_here":"consigue un gravatar aqui","dashboard":"tablero","last_message":"ultimo mensaje","followers":"Seguidores","make_writable":"permitir escritura","search_convos_for":"Buscar conversaciones con: \"{{string}}\"","update":"actualizar","tagged_with":"etiquetado con","update_your_profile":"Actualiza tu perfil","started_by":"comenzada por","name":"nombre","search_conversations":"buscar convos","password":"contrase\u00f1a","transport_opened":"conexion abierta","recent_followers":"Seguidores recientes","email":"email","loading_messages":"CARGANDO MENSAJES","test_conversation":"conversacion de TEST","receive_email_notifications":"Recibir notificaciones por email","all":"todo","with_files":"archivos","recent_tags":"Recent tags","users_conversations":"Conversaciones de los usuarios","with_images":"imagenes","spawn":"bifurcar","unfollow":"no seguir","view_all_or_add_a_tag":"<a href=\"#tags\">ver todos</a> o <a href=\"#tags\">a\u00f1ade un tag</a>","followed_users":"Usuarios seguidos","code":"codigo","recent_convos":"Conversaciones recientes","total_users":"Usuarios","signup_error":"Lo sentimos mucho, no hemos podido crear tu cuenta. Por favor, int\u00e9ntalo de nuevo o ponte en contacto con un administrador (el enlace est\u00e1 m\u00e1s arriba).","news":"Nuevos mensajes","echowaves_conversation":"conversacion de EcHoWaVeS.CoM"},"ie6update":{"msg":"Faltan actualizaciones importantes de Internet Explorer necesarias para ver este sitio. Haga clic aqu\u00ed para actualizar... ","url":"http://www.microsoft.com/spain/windows/internet-explorer/"},"errors":{"no_response_text":"error, no ha texto en la respuesta","sorry_this_is_a_private_convo":"Lo sentimos, esta es una conversacion privada","only_the_owner_can_invite":"Solo el propietario de esta conversacion puede invitar a otros usuarios","something_went_wrong":"Algo ha ido mal, intentalo mas tarde..."},"footer":{"uptime_monitoring":"Website Uptime Monitoring By","conversations":"conversaciones","terms_and_conditions":"Terminos y Condiciones","report_problems_or_abuse":"Informa de problemas o abusos a"},"home":{"index":{"p3":"Take it for a spin, post messages to our ","feedback_advice":"Si encuentras algun problema o quieres hacer alguna sugerencia sobre alguna funcionalidad que te gustaria ver en echowaves, puedes hacerlo en <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>","p1":"<h5>Si te gusta charlar, o escribir un blog, o compartir tu estado con los amigos, o simplemente socializar, EchoWaves es para ti.</h5>Si tienes alguna idea o sugerencia no dudes en hablarnos de ello en la","p2":"-- es gratis y cualquiera puede unirse. Comienza tus propias conversaciones, invita a todos tus amigos a unirse, sigue de cerca otras conversaciones que te parezcan interesantes y diviertete!","headline1":"Echowaves.com es un programa de chat y red social","headline2":"El c\u00f3digo fuente se encuentra en <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>."}},"messages":{"new_messages":"nuevos mensajes","original_message":"mensaje original"},"users":{"email_invites":"Email invites","look_for_users":"buscar usuarios","logged_in_sucesfully":"Conectado con exito","invite_users":"Invitar usuarios","recently_joined_users":"usuarios registrados recientemente","logged_out":"Se ha cerrado la sesion.","n_convos_started":"{{number}} conversaciones comenzadas","profile_updated":"Perfil actualizado correctamente","invite_all_followers":"Invitar a todos mis seguidores","n_followers":"{{number}} seguidores","since_date":"desde: {{date}}","n_messages_posted":"{{number}} mensajes publicados","could_not_login_as":"No se ha podido iniciar la sesion para {{login}}","sign_up_as_new_user":"registrate como usuario","since":"desde:","invite_followed_users":"Invitar a usuarios que yo sigo","following_n_users":"siguiendo a {{number}} usuarios","about":"Acerca de ti","signup_complete":"Registro completado! Inicia sesi\u00f3n para continuar."},"notices":{"you_must_be_logged_out":"Tienes que terminar la sesion para acceder a esta pagina","you_must_be_logged_in":"Tienes que iniciar sesion para acceder a esta pagina"}};
