# == Schema Info
# Schema version: 20090514235226
#
# Table name: invites
#
#  id              :integer(4)      not null, primary key
#  conversation_id :integer(4)
#  requestor_id    :integer(4)
#  user_id         :integer(4)
#  token           :string(255)
#  created_at      :datetime
#  updated_at      :datetime

require File.dirname(__FILE__) + '/../test_helper'

class InviteTest < ActiveSupport::TestCase
  context "An invite instance for a public convo" do    
    setup do
      user = Factory.create(:user, :login => "user1")              
      @invite = Factory.create(:invite, :requestor => user)
    end
    subject { @invite }
    
    should_belong_to :user
    should_belong_to :requestor
    should_belong_to :conversation
    
    should_have_db_indices :user_id, :requestor_id, :conversation_id
    should_validate_presence_of :requestor_id, :conversation_id
    
    should "be public" do
      assert @invite.public?
    end
  end
   
  context "An invite instance for a private convo" do
    setup do
      user = Factory.create(:user, :login => "user1")              
      @invite = Factory.create(:invite, :requestor => user)
      @invite.token = user.perishable_token
      @invite.save
    end
    
    should "be private" do
      assert @invite.private?
    end
  end
end
