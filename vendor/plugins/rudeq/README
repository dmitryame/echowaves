== Author
  Matthew Rudy Jacobs
 
== Contact
  MatthewRudyJacobs@gmail.com
 
RudeQ
=============
  A simple DB based queue,
  designed for situations where a server based queue is unnecessary.
 
 
INSTALL
============
This plugin requires Rails 2.* currently, and has only been tested on MySQL.

On rails 2.1 you can install straight from github:
  ruby script/plugin install git://github.com/matthewrudy/rudeq.git

Else just check it out into your plugins directory:
  git clone git://github.com/matthewrudy/rudeq.git vendor/plugins/rudeq
 
USAGE
============
After you've installed it just run
  rake queue:setup

  matthew@iRudy:~/code/jbequeueing $ rake queue:setup
  (in /Users/matthew/code/jbequeueing)
      exists  app/models/
      exists  spec/fixtures/
      exists  spec/models/
      create  app/models/rude_queue.rb
      create  spec/fixtures/rude_queues.yml
      create  spec/models/rude_queue_spec.rb
      exists  db/migrate
      create  db/migrate/029_create_rude_queues.rb

  and you're done.
  Fully tested, fully index... BOOM!

  Now run migrations, start up a console, and;

      RudeQueue.set(:queue_name, RandomObject)
      RudeQueue.get(:queue_name)
      RudeQueue.fetch(:queue_name) do |data|
        process(data)
      end

  And, to keep the queue running fast,
  set up a cron job to run

      rake queue:cleanup
  
  the cleanup will remove any queued items which have been processed longer than an hour ago.

      rake queue:cleanup CLEANUP_TIME=86,400

  will clear processed queue items processed longer than 86,400 seconds ago (1 day)

Try Yourself!
 
Copyright (c) 2008 [Matthew Rudy Jacobs Email: MatthewRudyJacobs@gmail.com],
released under the MIT license
