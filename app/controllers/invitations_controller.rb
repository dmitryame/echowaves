class InvitationsController < ApplicationController
  def ssl_required?
    true if USE_SSL
  end

  before_filter :require_user

  def index
    @invitations = Invite.find(:all, :conditions => { :user_id => current_user.id })
  end

  def destroy
    @invitation = Invite.find(params[:id], :conditions => { :user_id => current_user.id })
    @invitation.destroy
  end

  def accept
    @invitation = Invite.find(params[:id], :conditions => { :user_id => current_user.id })
    current_user.follow(@invitation.conversation, @invitation.token)
  end

end
