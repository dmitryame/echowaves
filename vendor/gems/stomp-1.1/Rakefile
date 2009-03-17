#   Copyright 2005-2006 Brian McCallister
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

# read the contents of the gemspec, eval it, and assign it to 'spec'
# this lets us maintain all gemspec info in one place.  Nice and DRY.
spec = eval(IO.read("stomp.gemspec"))

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
  pkg.need_tar = true
end

task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{VERSION}}
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'doc'
  rd.options = spec.rdoc_options
end

desc "RSpec : run all"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ["--color", "--format", "specdoc"]
end

