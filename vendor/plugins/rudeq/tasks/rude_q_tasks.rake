namespace :queue do
  desc "Generates your RudeQueue model"
  task :setup => :environment do
    require 'rails_generator'
    require 'rails_generator/scripts/generate'
    Rails::Generator::Scripts::Generate.new.run(["rude_q", ENV["QUEUE"] || "RudeQueue"])
  end

  desc "Removes all the old queue items"
  task :cleanup => :environment do
    queue_model = (ENV["QUEUE"] || "RudeQueue").constantize
    args = [ENV["CLEANUP_TIME"]].compact
    queue_model.cleanup!(*args) # no arg if no CLEANUP_TIME specified
  end
end

#namespace :spec do
#  namespace :plugins do
#    desc "Runs the examples for RudeQ"
#    Spec::Rake::SpecTask.new(:rude_q) do |t|
#      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
#      t.spec_files = FileList['vendor/plugins/rude_q/spec/**/*_spec.rb']
#    end
#  end
#end
