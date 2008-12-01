# namespace :test do
#   desc "Generate code coverage with rcov"
#   task :coverage do
#     rm_f "doc/coverage/coverage.data"
#     rm_f "doc/coverage"
#     mkdir "doc/coverage"
#     rcov = %(rcov --rails --aggregate doc/coverage/coverage.data --text-summary -Ilib --html -o doc/coverage test/**/*_test.rb)
#     system rcov
#     system "open doc/coverage/index.html" if PLATFORM['darwin']
#   end
# end
# 

# 
# 
# require 'rcov/rcovtask' 
#  
# namespace :test do 
#   namespace :coverage do 
#     desc "Delete aggregate coverage data." 
#     task(:clean) { rm_f "coverage.data" } 
#   end 
# 
#   desc 'Aggregate code coverage for unit, functional and integration tests' 
#   task :coverage => "test:coverage:clean" 
#     %w[unit functional integration].each do |target| 
#     namespace :coverage do 
#       Rcov::RcovTask.new(target) do |t| 
#       t.libs << "test" 
#       t.test_files = FileList["test/#{target}/*_test.rb"] 
#       t.output_dir = "test/coverage/#{target}" 
#       t.verbose = true 
#       t.rcov_opts << '--rails --aggregate coverage.data' 
#     end 
#   end 
#   task :coverage => "test:coverage:#{target}" 
#   end 
# end 
# 
namespace :test do

  desc 'Measures test coverage'
  task :coverage do
    rm_f "coverage"
    rm_f "coverage.data"
    rcov = "rcov --rails --aggregate coverage.data --text-summary -Ilib"
    system("#{rcov} --no-html test/unit/*_test.rb")
    system("#{rcov} --no-html test/functional/*_test.rb")
    system("#{rcov} --html test/integration/*_test.rb")
    system("open coverage/index.html") if PLATFORM['darwin']
  end

end

