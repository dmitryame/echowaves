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

    should_require_attributes :message
    should_require_attributes :user_id, :conversation_id

    should_have_attached_file :attachment
    
    should "be valid if honeypot field is blank" do
      assert @message.valid?
    end
    
    should "not be valid if honeypot field is not blank" do
      @message.something = "spam"
      assert !@message.valid?
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
    assert_equal false, message.published?
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
    assert_equal false, message.published?
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
