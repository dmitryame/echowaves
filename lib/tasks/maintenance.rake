namespace :maintenance do
  namespace :messages do
    
    desc "Regenerate message html"
    task :regenerate_html => :environment do
      Message.find_each(:batch_size => 100) do |m|
        m.auto_html_prepare
        m.save!
      end
    end
    
  end
end