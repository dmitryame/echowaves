CREATE TABLE `abuse_reports` (
  `id` int(11) NOT NULL auto_increment,
  `message_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_abuse_reports_on_created_at` (`created_at`),
  KEY `index_abuse_reports_on_message_id` (`message_id`),
  KEY `index_abuse_reports_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `conversation_visits` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `conversation_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_conversation_visits_on_created_at` (`created_at`),
  KEY `index_conversation_visits_on_user_id` (`user_id`),
  KEY `index_conversation_visits_on_conversation_id` (`conversation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `conversations` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `description` text,
  `personal_conversation` tinyint(1) default '0',
  `read_only` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  KEY `index_conversations_on_name` (`name`),
  KEY `index_conversations_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `conversation_id` int(11) default NULL,
  `message` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `attachment_file_name` varchar(255) default NULL,
  `attachment_content_type` varchar(255) default NULL,
  `attachment_file_size` int(11) default NULL,
  `attachment_updated_at` datetime default NULL,
  `deactivated_at` datetime default NULL,
  `abuse_report_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_messages_on_user_id` (`user_id`),
  KEY `index_messages_on_conversation_id` (`conversation_id`),
  KEY `index_messages_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `subscriptions` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `conversation_id` int(11) default NULL,
  `activated_at` datetime default NULL,
  `last_message_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_subscriptions_on_user_id` (`user_id`),
  KEY `index_subscriptions_on_conversation_id` (`conversation_id`),
  KEY `index_subscriptions_on_activated_at` (`activated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(40) default NULL,
  `name` varchar(100) default '',
  `email` varchar(100) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(40) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `activation_code` varchar(40) default NULL,
  `activated_at` datetime default NULL,
  `password_reset_code` varchar(40) default NULL,
  `personal_conversation_id` int(11) default NULL,
  `time_zone` varchar(255) default 'UTC',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_users_on_login` (`login`),
  KEY `index_users_on_email` (`email`),
  KEY `index_users_on_crypted_password` (`crypted_password`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20081001172045');

INSERT INTO schema_migrations (version) VALUES ('20081003172020');

INSERT INTO schema_migrations (version) VALUES ('20081003193147');

INSERT INTO schema_migrations (version) VALUES ('20081003203731');

INSERT INTO schema_migrations (version) VALUES ('20081004171922');

INSERT INTO schema_migrations (version) VALUES ('20081004184557');

INSERT INTO schema_migrations (version) VALUES ('20081015035928');

INSERT INTO schema_migrations (version) VALUES ('20081024034115');

INSERT INTO schema_migrations (version) VALUES ('20081026225841');

INSERT INTO schema_migrations (version) VALUES ('20081027005113');

INSERT INTO schema_migrations (version) VALUES ('20081029211222');

INSERT INTO schema_migrations (version) VALUES ('20081106041047');

INSERT INTO schema_migrations (version) VALUES ('20081108044439');

INSERT INTO schema_migrations (version) VALUES ('20081108045125');

INSERT INTO schema_migrations (version) VALUES ('20081108173425');

INSERT INTO schema_migrations (version) VALUES ('20081108184556');

INSERT INTO schema_migrations (version) VALUES ('20081109202545');

INSERT INTO schema_migrations (version) VALUES ('20081110000150');

INSERT INTO schema_migrations (version) VALUES ('20081115054932');

INSERT INTO schema_migrations (version) VALUES ('20081117020514');

INSERT INTO schema_migrations (version) VALUES ('20081121081321');