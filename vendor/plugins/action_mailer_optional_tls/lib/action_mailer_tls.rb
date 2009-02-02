require "rubygems"
gem "actionmailer"
ActionMailer::Base.class_eval do
  private
  def perform_delivery_smtp(mail)
    destinations = mail.destinations
    mail.ready_to_send

    Net::SMTP.start(smtp_settings[:address], smtp_settings[:port], smtp_settings[:domain], 
        smtp_settings[:user_name], smtp_settings[:password], smtp_settings[:authentication], smtp_settings[:tls]) do |smtp|
      smtp.sendmail(mail.encoded, mail.from, destinations)
    end
  end
end