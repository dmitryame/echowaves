namespace :data do

  desc "Fill the database with some test data"
  task :load => :environment do
    %w( user1 user2 user3 user4 user5 ).each do |u|
      puts u
      user = User.new(:password => 'secret', :password_confirmation => 'secret')
      user.login = u
      user.email = "#{u}@foobar.com"
      user.email_confirmation = "#{u}@foobar.com"
      user.save
      puts user.errors.inspect
      user.activate!
    end
  end

end