Gem::Specification.new do |s|
  s.name = "rudeq"
  s.version = "2.1.0"
  s.date = "2009-06-09"
  s.summary = "ActiveRecord-based DB-queue"
  s.email = "MatthewRudyJacobs@gmail.com"
  s.homepage = "http://github.com/matthewrudy/rudeq"
  s.description = "A simple DB queueing library built on top of ActiveRecord."
  s.has_rdoc = true
  s.authors = ["Matthew Rudy Jacobs"]
  s.files = [
    "README", "Rakefile", "MIT-LICENSE",
    
    "lib/rude_q/worker.rb", "lib/rude_q/scope.rb", "lib/rude_q.rb",
    
    "generators/rude_q/templates/rude_q_model.rb", "generators/rude_q/templates/rude_q_model_spec.rb", "generators/rude_q/templates/rude_q_migration.rb", "generators/rude_q/rude_q_generator.rb", "generators/rude_q/USAGE",

    "spec/spec.opts", "spec/worker_spec.rb", "spec/spec_helper.rb", "spec/database.yml", "spec/rude_q_spec.rb", "spec/models/rude_queue.rb", "spec/models/something.rb", "spec/schema.rb",

    "tasks/rude_q_tasks.rake"
  ]

  s.test_files = ["spec/rude_q_spec.rb", "spec/worker_spec.rb"]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
  s.add_dependency("activerecord")
end
