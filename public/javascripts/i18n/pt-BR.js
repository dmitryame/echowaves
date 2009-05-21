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

I18n.translations = I18n.translations || {"ie6update": {"url": "http://www.microsoft.com/windows/internet-explorer/default.aspx", "msg": "O seu Internet Explorer t\u00e1 precisando ser atualizado pra poder visualizar esse site. Clique aqui pra atualizar... "}, "footer": {"terms_and_conditions": "Termos e condi\u00e7\u00f5es", "uptime_monitoring": "Website Uptime Monitorado por", "conversations": "convos", "report_problems_or_abuse": "Denuncie problemas ou abusos para"}, "messages": {"new_messages": "mensagens novas", "original_message": "mensagem original"}, "errors": {"sorry_this_is_a_private_convo": "Desculpe, essa \u00e1 uma conversa\u00e7\u00e3o privada. Voc\u00ea pode tentar uma outra", "only_the_owner_can_invite": "Apenas os donos dessa conversa\u00e7\u00e3o podem convidar novos usu\u00e1rios"}, "notices": {"you_must_be_logged_out": "Voc\u00ea precisa sair do sistema para acessar essa p\u00e1gina", "you_must_be_logged_in": "Voc\u00ea precisa entrar no sistema para acessar essa p\u00e1gina"}, "ui": {"spawnconfirm": "Voc\u00ea tem certeza que deseja ramificar um novo convo a partir dessa mensagem?", "recent_tags": "R\u00f3tulos recentes", "followers": "Seguidores", "with_images": "com imagens", "signup": "Registrar-se", "its_free": "\u00e9 de gra\u00e7a qualquer um pode entrar", "news": "Novas mensagens", "users_conversations": "Convos de usu\u00e1rios", "connected": "conectado", "tagged_with": "Rotulado com", "login": "Entrar", "code": "c\u00f3digo", "search_advice": "escreva algo e clique para procurar!", "name": "nome", "make_private": "tornar privado", "receive_email_notifications": "Receber notifica\u00e7\u00f5es por e-mail", "search_messages": "procurar mensagens", "recent_followers": "Seguidores recentes", "search_conversations": "procurar convos", "all": "todo", "sound_off": "desligar som", "spawn": "ramificar", "make_public": "tornar p\u00fablico", "search": "procurar", "private_convo": "Conversa\u00e7\u00e3o privada", "test_conversation": "convo TESTE", "signup_error": "N\u00f3s n\u00e3o conseguimos configurar sua conta, desculpe-nos. Por favor tente novamente, ou contacte algum Administrador (o link est\u00e1 acima).", "logout": "sair", "click_to_activate": "Clique aqui para ativar sua conta", "update": "atualizar", "make_writable": "tornar edit\u00e1vel", "home": "in\u00edcio", "view_all_or_add_a_tag": "<a href=\"#tags\">visualizar tudo all</a> ou <a href=\"#tags\">adicionar um r\u00f3tulo</a>", "follow": "seguir", "reportconfirm": "Tem certeza que voc\u00ea quer denunciar essa mensagem? O abuso ser\u00e1 punido.", "view_all_users": "visualizar todos os usu\u00e1rios", "users": "usu\u00e1rios", "create": "criar", "with_files": "com arquivos", "invite": "convidar", "confirm_remove_tag": "Tem certeza que quer desrotular?", "followed_convos": "Convos seguidos", "transport_closed": "conex\u00e3o fechada", "cancel": "cancelar", "make_read_only": "tornar somente leitura", "following": "Seguindo", "this_is_the_newest_message": "Essa \u00e9 a mensagem mais nova", "total_messages": "Mensagens", "report": "denunciar", "forgot_password": "esqueceu sua senha?", "time_zone": "fuso-hor\u00e1rio", "messages": "Mensagens", "unfollow": "deixar de seguir", "edit_profile": "editar perfil", "shift_enter": "(shift+Enter para inserir uma nova linha)", "last_message": "\u00faltima mensagem", "recently_visited": "Visitado recentemente", "get_an_gravatar_here": "pegar um aqui", "description": "descri\u00e7\u00e3o", "sound_on": "ligar som", "thanks_for_signup": "Obrigado por se registrar! Nos estamos mandando um e-mail para voc\u00ea com o seu c\u00f3digo de ativa\u00e7\u00e3o.", "convos": "Convos", "login_name": "Nome de usu\u00e1rio", "attach_file": "anexar arquivo", "followed_users": "Usu\u00e1rios seguidos", "password_confirmation": "confirmar senha", "total_users": "Usu\u00e1rios", "echowaves_conversation": "EcHoWaVeS.CoM convo", "send": "enviar", "read_only": "somente leitura", "back_to_parent": "voltar para cima", "password": "senha", "back": "voltar", "recently_joined": "Entrou recentemente", "transport_opened": "conex\u00e3o aberta", "view_all_convos": "visualizar todos os convos", "add_tag": "adicionar r\u00f3tulo", "reportconfirm_conversation": "Tem certeza que voc\u00ea quer denunciar esse convo? O abuso ser\u00e1 punido.", "email": "e-mail", "view_all": "visualizar tudo", "conversations": "convos", "more_messages": "mais mensagens", "my_conversations": "Meus convos", "started_by": "iniciado por", "attach": "Anexar", "recent_convos": "Convos recentes", "email_confirmation": "confirmar e-mail", "update_your_profile": "Atualizar seu perfil", "popular_convos": "Convos Populares", "tags": "r\u00f3tulos", "total_convos": "convos"}, "users": {"recently_joined_users": "usu\u00e1rios registrados recentemente", "sign_up_as_new_user": "registrar-se como um novo usu\u00e1rio", "logged_out": "Voc\u00ea fechou a sess\u00e3o.", "signup_complete": "Registro completo! Por favor entre no sistema para continuar.", "invite_users": "Convidar usu\u00e1rios", "since": "desde:", "could_not_login_as": "N\u00e3o conseguiu logar como {{login}}", "look_for_users": "buscar por usu\u00e1rios", "profile_updated": "Perfil atualizado corretamente", "logged_in_sucesfully": "Conectado com sucesso"}, "conversations": {"already_spawned_warning": "Voc\u00ea j\u00e1 ramificou uma nova conversa\u00e7\u00e3o dessa mensagem.", "start_new_conversation": "iniciar um novo convo", "recently_started_conversations": "convos iniciadas recentemente", "not_allowed_to_write_warning": "Voc\u00ea n\u00e3o tem permiss\u00e3o para adicionar novas mensagens a essa conversa\u00e7\u00e3o.", "bookmarked_conversations": "conversa\u00e7\u00f5es favoritas", "go_to_conversation": "ir para a conversa\u00e7\u00e3o", "login_or_register_to_participate": "Por favor <a href=\"/login\">entre</a> para participar.<br/>Ainda n\u00e3o tem uma conta? <a href=\"/signup\">Registre-se agora</a>, \u00e9 de gra\u00e7a", "convo_sucesfully_created": "Conversa\u00e7\u00e3o criada com sucesso.", "new_spawned_conversation": "nova conversa\u00e7\u00e3o ramificada", "new_conversation": "novo convo", "this_is_an_read_only_convo": "Essa \u00e9 uma conversa\u00e7\u00e3o somente leitura", "look_for_conversations": "buscar conversa\u00e7\u00f5es", "user_spawned_convo_description": "{{login}} ramificou esse convo, seguindo essa mensagem {{original_message_link}}\n\nPor favor forne\u00e7a uma descri\u00e7\u00e3o e um t\u00edtulo apropriado para a nova conversa\u00e7\u00e3o"}, "home": {"index": {"p3": "D\u00ea um giro e nos mande uma mensagem", "feedback_advice": "Se voc\u00ea encontrar alguma falha ou gostaria de mandar uma sugest\u00e3o sobre qual funcionalidade voc\u00ea gostaria de ver no echowaves, voc\u00ea pode fazer isso <a href=\"http://code.google.com/p/echowaves/issues/list\">http://echowaves.googlecode.com/</a>", "p1": "<h5>Se voc\u00ea gosta de conversar, participar de blogs, enviar fotos,  compartilhar atualiza\u00e7\u00f5es com seus amigos, ou simplesmente socializar -- Voc\u00ea vai adorar o EchoWaves.</h5> Se voc\u00ea tem algumas ideias ou sugest\u00f5es sinta-se livre para falar sobre isso aqui", "p2": "-- \u00c9 de gra\u00e7a e qualquer um pode entrar. Inicie seus pr\u00f3prios convos, convide todos os seus amigos para entrar nos seus convos, siga outros convos que pare\u00e7am interessante para voc\u00ea. Divirta-se!", "headline1": "EchoWaves.com \u00e9 um grupo de chat social opensource", "headline2": "O c\u00f3digo fonte est\u00e1 hospedado em: <a href=\"http://github.com/dmitryame/echowaves\">http://github.com/dmitryame/echowaves</a>."}}};
