Capistrano::Configuration.instance(:must_exist).load do
  namespace :thinking_sphinx do
    namespace :install do
      desc "Install Sphinx by source"
      task :sphinx do
        with_postgres = false
        run "which pg_config" do |channel, stream, data|
          with_postgres = !(data.nil? || data == "")
        end

        args = []
        if with_postgres
          run "pg_config --pkgincludedir" do |channel, stream, data|
            args << "--with-pgsql=#{data}"
          end
        end

        commands = <<-CMD
        wget -q http://www.sphinxsearch.com/downloads/sphinx-0.9.8.1.tar.gz >> sphinx.log
        tar xzvf sphinx-0.9.8.1.tar.gz
        cd sphinx-0.9.8.1
        ./configure #{args.join(" ")}
        make
        sudo make install
        rm -rf sphinx-0.9.8.1 sphinx-0.9.8.1.tar.gz
        CMD
        run commands.split(/\n\s+/).join(" && ")
      end

      desc "Install Thinking Sphinx as a gem from GitHub"
      task :ts do
        sudo "gem install freelancing-god-thinking-sphinx --source http://gems.github.com"
      end
    end

    desc "Generate the Sphinx configuration file"
    task :configure do
      rake "thinking_sphinx:configure"
    end

    desc "Index data"
    task :index do
      rake "thinking_sphinx:index"
    end

    desc "Start the Sphinx daemon"
    task :start do
      configure
      rake "thinking_sphinx:start"
    end

    desc "Stop the Sphinx daemon"
    task :stop do
      configure
      rake "thinking_sphinx:stop"
    end

    desc "Stop and then start the Sphinx daemon"
    task :restart do
      stop
      start
    end

    desc "Stop, re-index and then start the Sphinx daemon"
    task :rebuild do
      stop
      index
      start
    end

    desc "Add the shared folder for sphinx files for the production environment"
    task :shared_sphinx_folder, :roles => :web do
      sudo "mkdir -p #{shared_path}/db/sphinx/production"
    end

    def rake(*tasks)
      tasks.each do |t|
        run "cd #{current_path} && rake #{t} RAILS_ENV=production"
      end
    end
  end
end
