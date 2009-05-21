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

I18n.translations = I18n.translations || {"messages": {"new_messages": "mensagens novas", "original_message": "mensagem original"}, "errors": {"only_the_owner_can_invite": "Apenas os donos dessa conversa\u00e7\u00e3o podem convidar novos usu\u00e1rios", "sorry_this_is_a_private_convo": "Desculpe, essa \u00e1 uma conversa\u00e7\u00e3o privada. Voc\u00ea pode tentar uma outra"}, "ui": {"thanks_for_signup": "Obrigado por se registrar! Nos estamos mandando um e-mail para voc\u00ea com o seu c\u00f3digo de ativa\u00e7\u00e3o.", "invite": "convidar", "attach_file": "anexar arquivo", "followers": "Seguidores", "login_name": "Nome de usu\u00e1rio", "followed_convos": "Convos seguidos", "total_users": "Usu\u00e1rios", "echowaves_conversation": "EcHoWaVeS.CoM convo", "back_to_parent": "voltar para cima", "tagged_with": "Rotulado com", "login": "Entrar", "code": "c\u00f3digo", "transport_opened": "conex\u00e3o aberta", "unfollow": "deixar de seguir", "name": "nome", "recently_joined": "Entrou recentemente", "view_all_convos": "visualizar todos os convos", "recent_followers": "Seguidores recentes", "view_all": "visualizar tudo", "all": "todo", "reportconfirm_conversation": "Tem certeza que voc\u00ea quer denunciar esse convo? O abuso ser\u00e1 punido.", "more_messages": "mais mensagens", "search": "procurar", "started_by": "iniciado por", "my_conversations": "Meus convos", "attach": "Anexar", "recent_convos": "Convos recentes", "update": "atualizar", "followed_users": "Usu\u00e1rios seguidos", "convos": "Convos", "update_your_profile": "Atualizar seu perfil", "home": "in\u00edcio", "popular_convos": "Convos Populares", "follow": "seguir", "total_convos": "convos", "spawnconfirm": "Voc\u00ea tem certeza que deseja ramificar um novo convo a partir dessa mensagem?", "users": "usu\u00e1rios", "create": "criar", "with_images": "com imagens", "recent_tags": "R\u00f3tulos recentes", "its_free": "\u00e9 de gra\u00e7a qualquer um pode entrar", "connected": "conectado", "users_conversations": "Convos de usu\u00e1rios", "signup": "Registrar-se", "following": "Seguindo", "make_private": "tornar privado", "report": "denunciar", "time_zone": "fuso-hor\u00e1rio", "messages": "Mensagens", "search_advice": "escreva algo e clique para procurar!", "search_messages": "procurar mensagens", "sound_off": "desligar som", "email_confirmation": "confirmar e-mail", "search_conversations": "procurar convos", "last_message": "\u00faltima mensagem", "make_public": "tornar p\u00fablico", "test_conversation": "convo TESTE", "description": "descri\u00e7\u00e3o", "private_convo": "Conversa\u00e7\u00e3o privada", "signup_error": "N\u00f3s n\u00e3o conseguimos configurar sua conta, desculpe-nos. Por favor tente novamente, ou contacte algum Administrador (o link est\u00e1 acima).", "click_to_activate": "Clique aqui para ativar sua conta", "make_writable": "tornar edit\u00e1vel", "password_confirmation": "confirmar senha", "logout": "sair", "reportconfirm": "Tem certeza que voc\u00ea quer denunciar essa mensagem? O abuso ser\u00e1 punido.", "send": "enviar", "news": "Novas mensagens", "read_only": "somente leitura", "view_all_or_add_a_tag": "<a href=\"#tags\">visualizar tudo all</a> ou <a href=\"#tags\">adicionar um r\u00f3tulo</a>", "view_all_users": "visualizar todos os usu\u00e1rios", "password": "senha", "back": "voltar", "confirm_remove_tag": "Tem certeza que quer desrotular?", "spawn": "ramificar", "receive_email_notifications": "Receber notifica\u00e7\u00f5es por e-mail", "with_files": "com arquivos", "transport_closed": "conex\u00e3o fechada", "add_tag": "adicionar r\u00f3tulo", "make_read_only": "tornar somente leitura", "email": "e-mail", "cancel": "cancelar", "conversations": "convos", "this_is_the_newest_message": "Essa \u00e9 a mensagem mais nova", "forgot_password": "esqueceu sua senha?", "total_messages": "Mensagens", "shift_enter": "(shift+Enter para inserir uma nova linha)", "edit_profile": "editar perfil", "recently_visited": "Visitado recentemente", "sound_on": "ligar som", "tags": "r\u00f3tulos", "get_an_gravatar_here": "pegar um aqui"}, "users": {"since_date": "since: {{date}}", "sign_up_as_new_user": "registrar-se como um novo usu\u00e1rio", "profile_updated": "Perfil atualizado corretamente", "invite_users": "Convidar usu\u00e1rios", "signup_complete": "Registro completo! Por favor entre no sistema para continuar.", "following_n_users": "following {{number}} users", "look_for_users": "buscar por usu\u00e1rios", "logged_out": "Voc\u00ea fechou a sess\u00e3o.", "n_convos_started": "{{number}} convos started", "n_messages_posted": "{{number}} messages posted", "since": "desde:", "could_not_login_as": "N\u00e3o conseguiu logar como {{login}}", "logged_in_sucesfully": "Conectado com sucesso", "n_followers": "{{number}} followers", "recently_joined_users": "usu\u00e1rios registrados recentemente"}, "ie6update": {"url": "http://www.microsoft.com/windows/internet-explorer/default.aspx", "msg": "O seu Internet Explorer t\u00e1 precisando ser atualizado pra poder visualizar esse site. Clique aqui pra atualizar... "}, "footer": {"terms_and_conditions": "Termos e condi\u00e7\u00f5es", "uptime_monitoring": "Website Uptime Monitorado por", "report_problems_or_abuse": "Denuncie problemas ou abusos para", "conversations": "convos"}, "conversations": {"bookmarked_conversations": "conversa\u00e7\u00f5es favoritas", "go_to_conversation": "ir para a conversa\u00e7\u00e3o", "login_or_register_to_participate": "Por favor <a href=\"/login\">entre</a> para participar.<br/>Ainda n\u00e3o tem uma conta? <a href=\"/signup\">Registre-se agora</a>, \u00e9 de gra\u00e7a", "convo_sucesfully_created": "Conversa\u00e7\u00e3o criada com sucesso.", "new_spawned_conversation": "nova conversa\u00e7\u00e3o ramificada", "new_conversation": "novo convo", "this_is_an_read_only_convo": "Essa \u00e9 uma conversa\u00e7\u00e3o somente leitura", "look_for_conversations": "buscar conversa\u00e7\u00f5es", "user_spawned_convo_description": "{{login}} ramificou esse convo, seguindo essa mensagem {{original_message_link}}\n\nPor favor forne\u00e7a uma descri\u00e7\u00e3o e um t\u00edtulo apropriado para a nova conversa\u00e7\u00e3o", "already_spawned_warning": "Voc\u00ea j\u00e1 ramificou uma nova conversa\u00e7\u00e3o dessa mensagem.", "start_new_conversation": "iniciar um novo convo", "recently_started_conversations": "convos iniciadas recentemente", "not_allowed_to_write_warning": "Voc\u00ea n\u00e3o tem permiss\u00e3o para adicionar novas mensagens a essa conversa\u00e7\u00e3o."}, "notices": {"you_must_be_logged_out": "Voc\u00ea precisa sair do sistema para acessar essa p\u00e1gina", "you_must_be_logged_in": "Voc\u00ea precisa entrar no sistema para acessar essa p\u00e1gina"}, "home": {"index": {"headline1": "EchoWaves.com \u00e9 um grupo de chat social opensource", "p1": "<h5>Se voc\u00ea gosta de conversar, participar de blogs, enviar fotos,  compartilhar atualiza\u00e7\u00f5es com seus amigos, ou simplesmente socializar -- Voc\u00ea vai adorar o EchoWaves.</h5> Se voc\u00ea tem algumas ideias ou sugest\u00f5es sinta-se livre para falar sobre isso aqui", "headline2": "O c\u00f3digo fonte est\u00e1 hospedado em: <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>.", "p2": "-- \u00c9 de gra\u00e7a e qualquer um pode entrar. Inicie seus pr\u00f3prios convos, convide todos os seus amigos para entrar nos seus convos, siga outros convos que pare\u00e7am interessante para voc\u00ea. Divirta-se!", "p3": "D\u00ea um giro e nos mande uma mensagem", "feedback_advice": "Se voc\u00ea encontrar alguma falha ou gostaria de mandar uma sugest\u00e3o sobre qual funcionalidade voc\u00ea gostaria de ver no echowaves, voc\u00ea pode fazer isso <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>"}}};
