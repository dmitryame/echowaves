require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:conversations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_conversation
    assert_difference('Conversation.count') do
      post :create, :conversation => { }
    end

    assert_redirected_to conversation_path(assigns(:conversation))
  end

  def test_should_show_conversation
    get :show, :id => conversations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => conversations(:one).id
    assert_response :success
  end

  def test_should_update_conversation
    put :update, :id => conversations(:one).id, :conversation => { }
    assert_redirected_to conversation_path(assigns(:conversation))
  end

  def test_should_destroy_conversation
    assert_difference('Conversation.count', -1) do
      delete :destroy, :id => conversations(:one).id
    end

    assert_redirected_to conversations_path
  end
end
