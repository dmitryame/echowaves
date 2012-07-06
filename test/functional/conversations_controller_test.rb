require File.dirname(__FILE__) + '/../test_helper'

class ConversationsControllerTest < ActionController::TestCase
  def setup
    @current_user = create_user_and_authenticate
    @controller = ConversationsController.new
    @controller.stubs( :current_user ).returns( @current_user )
  end

  #context "#spawn action" do
  #  setup do
  #    @original_convo = Factory.create( :conversation )
  #    @message = Factory.create( :message, :conversation => @original_convo )
  #    Message.stubs( :find ).returns( @message )
  #    #Conversation.any_instance.stubs( :notify_of_new_spawn ).returns( @notify_message )
  #    #@controller.stubs( :current_user ).returns( @user )
  #    #@controller.stubs( :send_to_msg_broker )
  #  end
  #
  #  should "find the message to spawn from" do
  #    Message.expects( :find ).with( '1' ).returns( @message )
  #    get :spawn, :message_id => @message.id
  #    assert assigns( :message )
  #  end
  #
  #  # context "only allow 1 spawn per user per message" do
  #  #   setup do
  #  #     Conversation.stubs( :find ).returns( @conversation )
  #  #     @convos = [ @conversation ]
  #  #     @user.expects( :conversations ).returns( @convos )
  #  #   end
  #  #
  #  #   should "check if user already spawned from that message" do
  #  #     @convos.expects( :find_by_parent_message_id ).with( @message.id ).returns( nil )
  #  #     get :spawn_conversation, :conversation_id => @conversation.id, :id => '1'
  #  #   end
  #  #
  #  #   should "set flash[:error] and redirect if user already spawned from this message" do
  #  #     @convos.expects( :find_by_parent_message_id ).with( @message.id ).returns( true )
  #  #     get :spawn_conversation, :conversation_id => @conversation.id, :id => '1'
  #  #     assert flash.include?( :error )
  #  #     assert_redirected_to conversation_messages_path( @conversation )
  #  #   end
  #  # end
  #  #
  #  # should "create a new spawned conversation" do
  #  #   @message.expects( :spawn_new_conversation ).with( @user )
  #  #   get :spawn_conversation, :conversation_id => @conversation.id, :id => '1'
  #  # end
  #  #
  #  # should "send a notification message to the original conversation" do
  #  #   Conversation.any_instance.expects( :notify_of_new_spawn ).with( @user, @spawn_convo, @message )
  #  #   get :spawn_conversation, :conversation_id => @conversation.id, :id => '1'
  #  # end
  #  #
  #  # should "send stomp message" do
  #  #   # @controller.expects( :send_to_msg_broker ).with( @notify_message )
  #  #   get :spawn_conversation, :conversation_id => @conversation.id, :id => '1'
  #  # end
  #  #
  #  # should "redirect to the new spawned conversation" do
  #  #   get :spawn_conversation, :conversation_id => @conversation.id, :id => '1'
  #  #   assert_redirected_to conversation_messages_path( @spawn_convo )
  #  # end
  #end # context #spawn_conversation

  context "create action" do
    setup do
      @convo = Factory.create( :conversation )
      Conversation.expects( :new ).returns( @convo )
      @convo.stubs( :to_param ).returns( '1' )
      @user_convos = []
      # FIX
      # @current_user.expects( :conversations ).returns( @user_convos )
      @current_user.stubs( :conversations ).returns( @user_convos )
    end

    context "html request" do
      context "successful create" do
        setup do
          @user_convos.stubs( :<< ).returns( true )
        end

        should "set flash notice" do
          post :create, :user => 'foo'
          assert flash.include?( :notice )
        end

        should "redirect to conversation" do
          post :create, :user => 'foo'
          assert_redirected_to conversation_path( @convo )
        end
      end

      context "failed create" do
        setup do
          @user_convos.stubs( :<< ).returns( false )
        end

        should "render the new template" do
          post :create, :user => 'foo'
          assert_template "conversations/new"
        end

        should "not set flash notice" do
          post :create, :user => 'foo'
          assert_equal false, flash.include?( :notice )
        end
      end
    end

    context "xml request" do
      setup do
        @request.accept = 'text/xml'
        @convo.stubs( :to_xml ).returns( 'XML' )
        @convo.errors.stubs( :to_xml ).returns( 'XML errors' )
      end

      context "successful create" do
        setup do
          @user_convos.stubs( :<< ).returns( true )
        end

        should "render XML" do
          post :create, :user => 'foo'
          assert_equal 'XML', @response.body
        end

        should "set status to :created" do
          post :create, :user => 'foo'
          assert_response :created
        end
      end

      context "failed create" do
        setup do
          @user_convos.stubs( :<< ).returns( false )
        end

        should "render XML errors" do
          post :create, :user => 'foo'
          assert_equal 'XML errors', @response.body
        end

        should "set status to unprocessable_entity" do
          post :create, :user => 'foo'
          assert_response :unprocessable_entity
        end
      end
    end
  end # context create action

  context "index action" do
    setup do
      @convo = Factory.create( :conversation )
      @convos = [@convo]
      Conversation.expects( :non_private ).returns( @convos )
      @convos.expects( :paginate ).returns( @convos )
      @convos.stubs( :total_pages ).returns( 1 )
      @convos.stubs( :to_xml ).returns( 'XML' )
    end

    context "html request" do
      should "be successful" do
        get :index
        assert_response :success
      end

      should "render index template" do
        get :index
        assert_template 'conversations/index'
      end
    end

    context "xml request" do
      setup do
        @request.accept = 'text/xml'
      end

      should "be successful" do
        get :index
        assert_response :success
      end

      should "render conversations in xml" do
        get :index
        assert_equal 'XML', @response.body
      end
    end
  end # context index action

  context "new action" do
    setup do
      @convo = Factory.build( :conversation )
      Conversation.expects( :new ).returns( @convo )
    end

    context "html request" do
      should "be successful and render new template" do
        get :new
        assert_response :success
        assert_template 'conversations/new'
      end
    end

    context "xml request" do
      setup do
        @request.accept = 'text/xml'
        @convo.expects( :to_xml ).returns( 'XML' )
      end

      should "be successful and return xml format" do
        get :new
        assert_response :success
        assert_equal 'XML', @response.body
      end
    end
  end # context new action

  context "update action" do
    setup do
      @owner = Factory.create(:user, :login => 'user1')
      @conversation = Factory.create(:conversation, :user => @current_user)
    end

    context "convo belongs to other user " do
      setup do
        @other_conversation = Factory.create(:conversation, :user => @owner)
      end

      should "only allow changes if the current_user is the conversation owner" do
        # try to change to writeable
        @other_conversation.update_attribute(:read_only, true)
        put :update, :id => @other_conversation
        assert_equal true, assigns(:conversation).read_only?

        # try to change to readonly
        @other_conversation.update_attribute(:read_only, false)
        put :update, :id => @other_conversation
        assert_equal false, assigns(:conversation).read_only?
      end
    end

    context "convo belongs to current_user" do
      should "make readonly when conversation is writable" do
        put :update, :id => @conversation
        assert_equal true, assigns(:conversation).read_only?
      end

      should "make writeable when conversation is readonly" do
        @conversation.update_attribute(:read_only, true)

        put :update, :id => @conversation
        assert_equal false, assigns(:conversation).read_only?
      end
    end
  end # context update action

  context "show action" do
    setup do
      @conversation = Factory(:conversation, :user => @user)
      @message = Factory(:message, :message => "some random message", :conversation => @conversation, :user => @current_user )
      @message.stubs( :to_xml ).returns( 'XML' )
    end

    # should "find the conversation" do
    #   Conversation.stubs( :find ).with( '1' ).returns( @convo )
    #   get :show, :id => '1'
    #   assert assigns( :conversation )
    # end
    #
    # should "find and assign the published conversation messages" do
    #   get :show, :id => @convo.id
    #   assert assigns( :messages )
    # end
  end # context show action

end
