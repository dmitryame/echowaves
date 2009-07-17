require 'rake'
require 'spec'
require 'spec/rake/spectask'
require 'rake/rdoctask'

desc 'Default: run the specs.'
task :default => :spec

desc 'Run specs for rude_q plugin'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "\"spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Generate documentation for the rude_q plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'RudeQ'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
