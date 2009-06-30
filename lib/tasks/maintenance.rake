namespace :maintenance do
  namespace :messages do
    
    desc "Regenerate message html"
    task :regenerate_html => :environment do
      Message.find_each(:batch_size => 100) do |m|
        m.auto_html_prepare
        m.save(false)
      end
    end
    
    desc "Save attachment height in the database"
    task :save_attachment_height => :environment do
      Message.with_image.find_in_batches(:batch_size => 100 ) do |messages|
        messages.each do |m|
          begin
            m.attachment_height = Paperclip::Geometry.from_file(m.attachment.path(:big)).height.to_i          
            m.save(false)
          rescue
            RAILS_DEFAULT_LOGGER.error "[ Maintenance ] There is a problem with the attachment #{m.id}"
          end
        end
      end
    end
    
  end
end