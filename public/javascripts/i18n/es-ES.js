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

I18n.translations = I18n.translations || {"ie6update": {"url": "http://www.microsoft.com/spain/windows/internet-explorer/", "msg": "Faltan actualizaciones importantes de Internet Explorer necesarias para ver este sitio. Haga clic aqu\u00ed para actualizar... "}, "footer": {"terms_and_conditions": "Terminos y Condiciones", "uptime_monitoring": "Website Uptime Monitoring By", "conversations": "conversaciones", "report_problems_or_abuse": "Informa de problemas o abusos a"}, "messages": {"new_messages": "nuevos mensajes", "original_message": "mensaje original"}, "errors": {"sorry_this_is_a_private_convo": "Lo sentimos mucho, esta es una conversacion privada. Puedes intentarlo con alguna otra", "only_the_owner_can_invite": "Solo el propietario de esta conversacion puede invitar a otros usuarios"}, "notices": {"you_must_be_logged_out": "Tienes que terminar la sesion para acceder a esta pagina", "you_must_be_logged_in": "Tienes que iniciar sesion para acceder a esta pagina"}, "ui": {"spawnconfirm": "Estas seguro de querer comenzar una nueva conversacion a partir de este mensaje?", "recent_tags": "Recent tags", "followers": "Seguidores", "with_images": "imagenes", "signup": "Registrate", "its_free": "es gratis y todo el mundo puede unirse", "news": "Nuevos mensajes", "users_conversations": "Conversaciones de los usuarios", "connected": "conectado", "tagged_with": "etiquetado con", "login": "entrar", "code": "codigo", "search_advice": "escribe lo que quieras buscar y haz click en buscar!", "name": "nombre", "make_private": "hacer privada", "receive_email_notifications": "Recibir notificaciones por email", "search_messages": "buscar mensajes", "recent_followers": "Seguidores recientes", "search_conversations": "buscar convos", "all": "todo", "sound_off": "sound off", "spawn": "bifurcar", "make_public": "hacer publica", "search": "buscar", "private_convo": "Conversacion privada", "test_conversation": "conversacion de TEST", "signup_error": "Lo sentimos mucho, no hemos podido crear tu cuenta. Por favor, int\u00e9ntalo de nuevo o ponte en contacto con un administrador (el enlace est\u00e1 m\u00e1s arriba).", "logout": "salir", "click_to_activate": "Click aqui para activar tu cuenta", "update": "actualizar", "make_writable": "permitir escritura", "home": "inicio", "view_all_or_add_a_tag": "<a href=\"#tags\">ver todos</a> o <a href=\"#tags\">a\u00f1ade un tag</a>", "follow": "seguir", "reportconfirm": "Estas seguro de querer informar acerca de este mensaje? El autor del mensaje inapropiado sera castigado.", "view_all_users": "view all users", "users": "usuarios", "create": "crear", "with_files": "archivos", "invite": "invitar", "confirm_remove_tag": "\u00bfEstas seguro de que quieres quitar esta etiqueta?", "followed_convos": "Followed Convos", "transport_closed": "conexion cerrada", "cancel": "cancelar", "make_read_only": "hacer de solo lectura", "following": "Siguiendo", "this_is_the_newest_message": "Este es el mensaje mas nuevo", "total_messages": "Mensajes", "report": "informar", "forgot_password": "\u00bfHas olvidado la contrase\u00f1a?", "time_zone": "zona horaria", "messages": "Messages", "unfollow": "no seguir", "edit_profile": "editar perfil", "shift_enter": "(mayusculas+Intro para insertar una nueva linea)", "last_message": "ultimo mensaje", "recently_visited": "Visitado recientemente", "get_an_gravatar_here": "consigue un gravatar aqui", "description": "descripcion", "sound_on": "sound on", "thanks_for_signup": "Gracias por registrarte! Te hemos enviando un correo electr\u00f3nico con tu c\u00f3digo de activaci\u00f3n", "convos": "Convos", "login_name": "nombre de usuario", "attach_file": "adjuntar archivo", "followed_users": "Followed Users", "password_confirmation": "confirmar contrase\u00f1a", "total_users": "Usuarios", "echowaves_conversation": "conversacion de EcHoWaVeS.CoM", "send": "enviar", "read_only": "solo lectura", "back_to_parent": "convo original", "password": "contrase\u00f1a", "back": "atras", "recently_joined": "Unidos recientemente", "transport_opened": "conexion abierta", "view_all_convos": "view all convos", "add_tag": "a\u00f1adir tag", "reportconfirm_conversation": "Estas seguro de querer informar acerca de esta conversation? El autor de la conversacion inapropiada sera castigado.", "email": "email", "view_all": "view all", "conversations": "conversaciones", "more_messages": "mas mensajes", "my_conversations": "Mis conversaciones", "started_by": "comenzada por", "attach": "Adjuntar", "recent_convos": "Conversaciones recientes", "email_confirmation": "confirm email", "update_your_profile": "Actualiza tu perfil", "popular_convos": "Conversaciones populares", "tags": "etiquetas", "total_convos": "Convos"}, "users": {"recently_joined_users": "usuarios registrados recientemente", "sign_up_as_new_user": "registrate como usuario", "logged_out": "Se ha cerrado la sesion.", "signup_complete": "Registro completado! Inicia sesi\u00f3n para continuar.", "invite_users": "Invitar usuarios", "since": "desde:", "could_not_login_as": "No se ha podido iniciar la sesion para {{login}}", "look_for_users": "buscar usuarios", "profile_updated": "Perfil actualizado correctamente", "logged_in_sucesfully": "Conectado con exito"}, "conversations": {"already_spawned_warning": "Ya has comenzado una nueva conversacion desde este mensaje.", "start_new_conversation": "iniciar una nueva conversacion", "recently_started_conversations": "conversaciones iniciadas recientemente", "not_allowed_to_write_warning": "No puedes escribir mensajes en esta conversacion.", "bookmarked_conversations": "conversaciones favoritas", "go_to_conversation": "ir a conversacion", "login_or_register_to_participate": "Por favor <a href=\"/login\">entra</a> para participar.<br/>\u00bfAun no tienes una cuenta? <a href=\"/signup\">registrate ahora</a>, es gratis", "convo_sucesfully_created": "La conversacion ha sido creada correctamente.", "new_spawned_conversation": "nueva conversacion siguiendo un mensaje", "new_conversation": "nueva conversacion", "this_is_an_read_only_convo": "Esta es una conversacion de solo lectura", "look_for_conversations": "buscar conversaciones", "user_spawned_convo_description": "{{login}} ha creado esta conversacion siguiendo el mensaje {{original_message_link}}\n\nPor favor, escribe una descripcion y un titulo adecuados para esta nueva conversacion"}, "home": {"index": {"p3": "Take it for a spin, post messages to our ", "feedback_advice": "Si encuentras algun problema o quieres hacer alguna sugerencia sobre alguna funcionalidad que te gustaria ver en echowaves, puedes hacerlo en <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>", "p1": "<h5>Si te gusta charlar, o escribir un blog, o compartir tu estado con los amigos, o simplemente socializar, EchoWaves es para ti.</h5>Si tienes alguna idea o sugerencia no dudes en hablarnos de ello en la", "p2": "-- es gratis y cualquiera puede unirse. Comienza tus propias conversaciones, invita a todos tus amigos a unirse, sigue de cerca otras conversaciones que te parezcan interesantes y diviertete!", "headline1": "Echowaves.com es un programa de chat y red social", "headline2": "El c\u00f3digo fuente se encuentra en <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>."}}};
