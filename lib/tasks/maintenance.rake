namespace :maintenance do
  namespace :messages do
    
    desc "Regenerate message html"
    task :regenerate_html => :environment do
      Message.find_each(:batch_size => 100) do |m|
        m.auto_html_prepare
        m.save(false)
      end
    end
    
    desc "Fix attachments for spawned messages"
    task :fix_attachments_in_spawned_messages => :environment do
      spawned_convos = Conversation.find(:all, :conditions => 'parent_message_id IS NOT NULL')
      spawned_convos.each do |c|
        parent_message = c.parent_message
        spawned_message = c.messages.first
        if parent_message.has_attachment?
          spawned_message.auto_html_prepare          
          spawned_message.message_html = spawned_message.message_html + attachment_markup(parent_message)
          spawned_message.save(false)
        end
      end
    end
    
    desc "Save attachment size in the database"
    task :save_attachment_size => :environment do
      Message.with_image.find_in_batches(:batch_size => 100 ) do |messages|
        messages.each do |m|
          begin
            m.attachment_height = Paperclip::Geometry.from_file(m.attachment.path(:big)).height.to_i
            m.attachment_width = Paperclip::Geometry.from_file(m.attachment.path(:big)).width.to_i          
            m.save(false)
            puts "#----------------------------------------------------------------------------"
            puts "#{m.attachment_width}x#{m.attachment_height} px: #{m.attachment.path(:big)}"
            puts "#----------------------------------------------------------------------------"
          rescue
            RAILS_DEFAULT_LOGGER.error "[ Maintenance ] There is a problem with the attachment #{m.id}"
          end
        end
      end
    end
    
    def attachment_markup(message)
      if message.has_image?
        %Q( <div class="img_attachment"><a href="#{message.attachment.url}" style="display:block;height:#{message.attachment_height+40}px;width:#{message.attachment_width+40}px;"><img src="#{message.attachment.url(:big)}" alt="#{message.message}" height="#{message.attachment_height}" width="#{message.attachment_width}" /></a></div> )
      elsif message.has_file?
        %Q( <div class="file_attachment"><a href="#{message.attachment.url}" style="display:block;height:100px;"><img src="/images/icons/#{message.attachment_type}_large.jpg" alt="#{message.attachment_type}" height="100" /></a></div> )
      end
    end
    
  end
end