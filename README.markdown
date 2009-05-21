# ECHOWAVES

### [echowaves](http://echowaves.com/) is an opensource group chat social network.

EchoWaves is a Collaboration Tool and a Social Network. EchoWaves is as powerful as CampFire, and as simple to use as Twitter. It's built around conversations (convos) rather than users. Isn't it more natural for humans to socialize around convos?

Why one more Collaboration Tools? After all we already have meebo.com and campfire and many others like facebook.com and such. They all are great, but... none of them fits our needs 100%, and none of them is open-source.

Basically this tool could be an important addition to an agile team, specially to a geographically distributed one. We all know the importance of communication which could be difficult if people are not in the same room, or when someone walks out for few minutes...

If you'd like to contribute, perhaps start by picking a task from the issues list at:
[http://code.google.com/p/echowaves/issues/list](http://code.google.com/p/echowaves/issues/list)

## INSTALL (localhost)

copy config/database.yml-sample to config/database.yml and modify to taste (see below for some hints on different platforms)
  
    rake gems:install                         # automatically installs gems referenced in config/environment.rb
    rake db:create                            # creates the development database
    rake db:migrate                           # creates tables in dev DB
    
    rake thinking_sphinx:configure            # Generate the Sphinx configuration file using Thinking Sphinx's settings
                                              # this will generate config/development.sphinx.conf, modify for your setup
                                          

## SERVER SIDE COMPONENT INSTALL

install python
  
    sudo apt-get install python2.5-dev
    sudo apt-get install python2.5-twisted

install orbited (http://orbited.org/wiki/Installation)
  
    easy_install orbited

install simplejson
  
    easy_install simplejson

copy orbited config file
  
    cp config/orbited.cfg /etc/

install stomp gem

    sudo gem install stomp

(stomp gem will be prompted for by the entry in config/environment.rb)

update gem sources
  
    gem sources -a http://gems.github.com

install ImageMagick
You can install it quite easily via apt, yum, or port, or the package manager of your choice.

install sphinx from http://sphinxsearch.com/

## POST INSTALL

Index data for Sphinx using Thinking Sphinx's settings (this rake task will create the settings file at #{RAILS_ROOT}/configuration/development.sphinx.conf)

    rake thinking_sphinx:index

You will see a warning like the following – it’s safe to ignore, it’s just Sphinx being overly fussy. It tries to index all indexes, including distributed ones – which never need to be indexed, so it’s nothing to worry about:

    "distributed index 'article' can not be directly indexed; skipping."

Start a Sphinx searchd daemon using Thinking Sphinx's settings

    rake thinking_sphinx:start
      
Also – you can run the index task while Sphinx is running, and it’ll reload the indexes automatically. Prior to 0.9.9 though, Sphinx doesn’t reload the configuration file, so if you’ve changed your index structure or other Sphinx settings, you will need to stop and start it for those changes to take effect.

setup a cron tab to run "rake thinking_sphinx:index" periodically or do it manually when you need it

SignUp as a new user. Activate the user by copy-pasting the activation URL from the debug log into the address field of your browser and hit enter. 

To actually get the actionmailer stuff sent, you'll need to change the SMTP settings in config/environment.rb
In that case, you'll probably want to comment out the (currently last) line in config/environments/development.rb that reads:
    
    "config.action_mailer.raise_delivery_errors = false"

so that actionmailer failures are more visible.

## LOCALIZATION

We are using Rails I18n, and [javascript_i18n](http://github.com/qoobaa/javascript_i18n/tree/master) for localization. The javascript localization is generated from the rails one (in config/locales) by running the next rake task:

    rake js:i18n:build
    
## REPORTING ISSUES

If you find an issue or would like to make a suggestion on what functionality you would like to see in echowaves, you can do it at the [echowaves issues tracker](http://code.google.com/p/echowaves/issues)

## Specific advice for different platforms and setups

### WINDOWS

To use this with MySQL, you will probably need to uncomment the lines in the database.yml file that say "Host: 127.0.0.1".  The error when this isn't put in is *not* particularly helpful, so if you're having trouble, give it a try.

### SQLITE3

change the "adapter" lines to read "adapter: sqlite3"
make the database lines something like "database: db/development.sqlite3" and "database: db/test.sqlite3"
