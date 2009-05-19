# == Schema Info
# Schema version: 20090514235226
#
# Table name: messages
#
#  id                      :integer(4)      not null, primary key
#  abuse_report_id         :integer(4)
#  conversation_id         :integer(4)
#  user_id                 :integer(4)
#  attachment_content_type :string(255)
#  attachment_file_name    :string(255)
#  attachment_file_size    :integer(4)
#  delta                   :boolean(1)
#  message                 :text
#  message_html            :text
#  something               :string(255)     default("")
#  system_message          :boolean(1)
#  attachment_updated_at   :datetime
#  created_at              :datetime
#  updated_at              :datetime

require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < ActiveSupport::TestCase
  context "Message" do
    setup do
      @message = Factory.create(:message)
      
      @deactivated_message = Factory.create(:message)
      @abuse_report = Factory.create(:abuse_report, :user => @deactivated_message.user, :message => @deactivated_message)
      @deactivated_message.abuse_report = @abuse_report
      @deactivated_message.save
    end
    
    should "return 2 messages when find" do
      assert_equal Message.find(:all).length, 2
    end
    
    should "return only activated messages when find with published named_scope" do
      assert_equal Message.published.length, 1
    end
  end
  
  context "A Message instance" do    
    setup do
      @message = Factory(:message)
    end

    should_belong_to :conversation
    should_belong_to :user

    should_have_many :abuse_reports
    should_belong_to :abuse_report
    
    should_have_many :conversations #conversations spawned from this message

    should_have_index :user_id
    should_have_index :conversation_id
    should_have_index :created_at

    should_validate_presence_of :message
    should_validate_presence_of :user_id, :conversation_id

    should_have_attached_file :attachment
    
    should "be valid if honeypot field is blank" do
      assert @message.valid?
    end
    
    should "not be valid if honeypot field is not blank" do
      @message.something = "spam"
      assert !@message.valid?
    end
    
    should "return the date of creation in m/d/Y format" do
      assert_equal @message.date, @message.created_at.strftime("%Y/%m/%d")
    end
  end

  context "filter message (video, links, html, ...)" do
    setup do
      @message = Message.create(:message => '<script>dangerous</script>', :user_id => Factory(:user).id, :conversation_id => Factory(:conversation).id)
    end
    
    should "filter message on create" do
      assert_equal "<p>&lt;script&gt;dangerous&lt;/script&gt;</p>", @message.message_html
    end
    
    # messages can't be edited by the users, so this is not a problem, this way the system can modify
    # the message_html to add custom html code
    should "not filter message on save or update" do
      @message.message = @message.message + "<script>this code should not be filtered and added to message_html</script>"
      @message.save
      assert_equal "<p>&lt;script&gt;dangerous&lt;/script&gt;</p>", @message.message_html
    end
  end
  
  def test_should_check_over_abuse_reports_limit?
    @message1 = Factory.create(:message)
    @message2 = Factory.create(:message)
    @ab1 = Factory.create(:abuse_report, :message => @message1, :user => @message1.user) 
    @ab2 = Factory.create(:abuse_report, :message => @message1, :user => @message1.user) 
    @ab3 = Factory.create(:abuse_report, :message => @message1, :user => @message1.user) 

    assert @message1.over_abuse_reports_limit?
    assert_equal false, @message2.over_abuse_reports_limit?
  end

  def test_published?_method
    message = Factory.create(:message)
    assert message.published?
    
    abuse_report = Factory.create(:abuse_report, :message => message)
    message.update_attribute(:abuse_report, abuse_report)
    assert_equal false, message.published?
  end

  def test_report_abuse_method_by_non_owner
    message_owner = Factory.create(:user)
    report_user = Factory.create(:user)
    message = Factory.create(:message, :user => message_owner)
    
    assert_equal 0, message.abuse_reports.size
    message.report_abuse(report_user)
    assert_equal 1, message.abuse_reports.size
    message.report_abuse(report_user)
    assert_equal 1, message.abuse_reports.size
    assert_nil message.abuse_report
  end

  def test_report_abuse_method_by_owner
    message_owner = Factory.create(:user)
    convo = Factory.create(:conversation, :user => message_owner)
    message = Factory.create(:message, :conversation => convo)

    assert message.published?
    assert_equal 0, message.abuse_reports.size

    message.report_abuse(message_owner)
    assert_equal 1, message.abuse_reports.size
    # assert_equal false, message.published?
  end

  def test_report_abuse_method_over_limit
    message_owner = Factory.create(:user)
    u1 = Factory.create(:user)
    u2 = Factory.create(:user)
    u3 = Factory.create(:user)
    message = Factory.create(:message, :user => message_owner)

    assert message.published?
    assert_equal 0, message.abuse_reports.size

    message.report_abuse(u1)
    assert message.published?

    message.report_abuse(u2)
    assert message.published?

    message.report_abuse(u3)
    # assert_equal false, message.published?
    assert_equal 3, message.abuse_reports.size
  end

  def test_has_attachment_method
    message = Factory.create(:message)
    assert_equal false, message.has_attachment?

    # FIXME: not sure how to mock/stub out the attachment from Paperclip
  end

  private

  def create_attachment( type = :image )
    case type
    when :pdf
      attachment = stub(
        :nil? => false,
        :exists? => true,
        :to_tempfile => self,
        :original_filename => 'filename.pdf',
        :content_type => 'application/pdf',
        :size => 10
      )
    else
      attachment = stub( 
        :nil? => false,
        :exists? => true,
        :to_tempfile => self,
        :original_filename => 'filename.png',
        :content_type => 'image/png',
        :size => 10
      )
    end
    assert attachment.exists?
    attachment
  end


end
