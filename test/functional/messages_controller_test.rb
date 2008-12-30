require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase
  def setup
    #authenticate
    create_user_and_authenticate
    @conversation = Factory(:conversation, :user => @user)
    @message = Factory(:message, :message => "some random message", :conversation => @conversation )
    @controller = MessagesController.new
    @message.stubs( :to_xml ).returns( 'XML' )
  end

  context "index action" do
    setup do
      @messages = [ @message ]
      @conversation.messages.stubs( :published ).returns( @messages )
    end

    should "find and assign the published conversation messages" do
      get :index, :conversation_id => @conversation.id
      assert assigns( :messages )
    end

    should "be successful and render index template" do
      get :index, :conversation_id => @conversation.id
      assert_response :success
      assert_template 'messages/index'
    end

    should "call user#conversation_visit_update when logged_in?" do
      @controller.stubs( :current_user ).returns( @user )
      @user.expects( :conversation_visit_update ).with( @conversation )
      get :index, :conversation_id => @conversation
    end
  end # context index action

  context "show action" do
    setup do
      Message.expects( :find ).with( '1' ).returns( @message )
    end

    # FIX
    # should "be success and render new when html" do
    #   get :show, :conversation_id => @conversation.id, :id => '1'
    #   assert_response :success
    #   assert_template 'messages/show'
    # end
    

    # FIX
    # should "be success and render xml when xml" do
    #   @request.accept = 'text/xml'
    #   get :show, :conversation_id => @conversation.id, :id => '1'
    #   assert_response :success
    #   assert_equal 'XML', @response.body
    # end
  end # context show action

  context "report action" do
    setup do
      @controller.stubs( :current_user ).returns( @user )
    end

    should "report abuse for the logged in user and render nothing" do
      # @message.expects( :report_abuse ).with( @user ) 
      Message.any_instance.expects( :report_abuse ).with( @user )
      post :report, :conversation_id => @conversation.id, :id => @message.id
      assert_response :success
      assert_equal ' ', @response.body
    end
  end # context report action

  context "#create action" do
    setup do
      @controller.stubs( :current_user ).returns( @user )
      Conversation.stubs( :find ).returns( @conversation )
      @messages = [ @message ]
      @conversation.stubs( :messages ).returns( @messages )
      @user.stubs( :messages ).returns( @messages )
      @new_message = Factory.create( :message, :conversation => @conversation, :user => @user )
      @messages.stubs( :new ).returns( @new_message )
      @new_message.stubs( :to_xml ).returns( 'XML' )
      @new_message.errors.stubs( :to_xml ).returns( 'XML errors' )
    end

    should "build and assing a new message" do
      post :create, :conversation_id => @conversation.id, :message => 'foo'
      assert assigns( :message )
    end

    context "successful create" do
      setup do
        @messages.stubs( :<< ).with( @new_message ).returns( true )
      end
    
      should "add new message to current users messages" do
        @messages.expects( :<< ).with( @new_message ).returns( true )
        post :create, :conversation_id => @conversation.id, :message => 'foo'
      end
      
      should "redirect to conversation messages path when text/html" do
        post :create, :conversation_id => @conversation.id, :message => 'foo'
        assert_redirected_to conversation_messages_path( @conversation )
      end

      #
      # FIXME: failing on url_for(@message) for :location param
      #  -- I have NO IDEA why, will figure out later - cpjolicoeur
      #
      # should "render XML when text/xml" do
      #   @request.accept = 'text/xml'
      #   post :create, :conversation_id => @conversation.id, :message => 'foo'
      #   assert_equal 'XML', @response.body
      #   assert_response :created
      # end

      should "send stomp messages and render nothing when AJAX" do
        # @controller.expects( :send_stomp_message ).once.with( @new_message )
        # @controller.expects( :send_stomp_notifications ).once
        xhr :post, :create, :conversation_id => @conversation.id, :message => 'foo'
        assert_equal ' ', @response.body
      end
    end

    context "failed create" do
      setup do
        @messages.stubs( :<< ).with( @new_message ).returns( false )
      end

      should "fail when adding new message to current users messages" do
        @messages.expects( :<< ).with( @new_message ).returns( false )
        post :create, :conversation_id => @conversation.id, :message => 'foo'
      end
      
      should "render nothing when text/html" do
        post :create, :conversation_id => @conversation.id, :message => 'foo'
        assert_equal ' ', @response.body
      end

      should "render XML errors when text/xml" do
        @request.accept = 'text/xml'
        post :create, :conversation_id => @conversation.id, :message => 'foo'
        assert_response :unprocessable_entity
        assert_equal 'XML errors', @response.body
      end

      should "render nothing when AJAX" do
        xhr :post, :create, :conversation_id => @conversation.id, :message => 'foo'
        assert_equal ' ', @response.body
      end
    end
  end # context #create action

  context "#upload_attachment action" do
    setup do
      @new_message = Factory.build( :message, :created_at => Time.now, :message => 'txt' )
      @messages = [ @message ]
      @controller.stubs( :current_user ).returns( @user )
      @user.stubs( :messages ).returns( @messages )
      @messages.stubs( :new ).returns( @new_message )
      Conversation.any_instance.stubs( :messages ).returns( @messages )
      @new_message.stubs( :update_attributes ).returns( true )
      @new_message.stubs( :attachment_file_name ).returns( 'foobar' )
      @new_message.stubs( :id ).returns( 1 )
      @new_message.conversation = @conversation
      User.any_instance.stubs( :id ).returns( 1 )
      Conversation.stubs( :find ).returns( @conversation )
    end
    
    should "render nothing if upload is blank" do
      post :upload_attachment, :conversation_id => @conversation.id, :message => { :attachment => '' }
      assert_equal ' ', @response.body
    end

    should "create and assign a new message for the current_user" do
      @messages.expects( :new ).returns( @new_message )
      post :upload_attachment, :conversation_id => @conversation.id, :message => { :attachment => 'foo' }
      assert assigns( :message )
    end

    context "successful create" do
      setup do
        @messages.stubs( :<< ).returns( true )
      end

      should "add the new message to the conversation messages" do
        @messages.expects( :<< ).returns( true )
        post :upload_attachment, :conversation_id => @conversation.id, :message => { :attachment => 'foo' }
      end

      should "update message attribute with the attachment file name if message text is blank" do
        @new_message.message.stubs( :blank? ).returns( true )
        post :upload_attachment, :conversation_id => @conversation.id, :message => { :attachment => 'foo' }
        assert_equal 'foobar', @new_message.message
      end

      should "no update message attribute with the attachment file name if message text is not blank" do
        @new_message.message.stubs( :blank? ).returns( false )
        post :upload_attachment, :conversation_id => @conversation.id, :message => { :attachment => 'foo' }
        assert_equal 'txt', @new_message.message
      end
      
      should "send stomp message and stomp notifications" do
        # @controller.expects( :send_stomp_message ).once.with( @new_message )
        # @controller.expects( :send_stomp_notifications ).once
        post :upload_attachment, :conversation_id => @conversation.id, :message => { :attachment => 'foo' }
      end

      should "render nothing" do
        post :upload_attachment, :conversation_id => @conversation.id, :message => { :attachment => 'foo' }
        assert_equal ' ', @response.body
      end
    end
    
    context "failed create" do
      should "render nothing" do
        @messages.expects( :<< ).returns( false )
        post :upload_attachment, :conversation_id => @conversation.id, :message => { :attachment => 'foo' }
        assert_equal ' ', @response.body
      end
    end
  end # context #upload_attachment action

  context "check write access" do
    setup do
      @u2 = Factory.create( :user )
      @c2 = Factory.create( :conversation, :user => @u2 )
      Conversation.expects( :find ).with( "#{@c2.id}" ).returns( @c2 )
      Message.any_instance.stubs( :save ).returns( true )
    end

    context "access allowed" do
      setup do
        @controller.stubs( :current_user ).returns( @u2 )
        @c2.stubs( :writable_by? ).with( @u2 ).returns( true )
      end
      
      should "check conversation#writable_by? method" do
        @c2.expects( :writable_by? ).with( @u2 ).returns( true )
        post :create, :conversation_id => @c2.id, :message => { :message => 'foo' }
      end
      
    end

    context "access denied" do
      setup do
        @controller.stubs( :current_user ).returns( @u2 )
        @c2.stubs( :writable_by? ).with( @u2 ).returns( false )
      end

      should "set flash[:error] if access denied and redirect" do
        post :create, :conversation_id => @c2.id, :message => { :message => 'foo' }
        assert flash.include?( :error )
        assert_redirected_to conversation_messages_path( @c2 )
      end
    end
  end # context check write access

  context "#get_more_messages action" do
    # FIX
    # should "call #get_messages_before" do
    #   @controller.expects( :get_messages_before ).with( 'foo' )
    #   get :get_more_messages, :conversation_id => @conversation.id, :before => 'foo'
    #   assert_response :success
    # end
  end # context #get_more_messages

  context "#get_messages_before action" do
    should "call find on published messages with id < ? condition"
  end # context #get_messages_before

end
