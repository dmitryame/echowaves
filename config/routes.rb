ActionController::Routing::Routes.draw do |map|
  
  map.resource  :user_session
  map.resources :password_resets
  map.resources :attachments, :only => [:show]
  map.resource  :msgsearch, :only => [:show, :create]
  map.resource  :convosearch, :only => [:show, :create]
  map.resource  :usersearch, :only => [:show, :create]
  map.resources :users, :member =>  { :tagged_convos            => :get,
                                      :friends                  => :get,
                                      :followers                => :get,
                                      :followed_users           => :get,
                                      :followed_convos          => :get,
                                      :follow                   => :post,
                                      :unfollow                 => :post,
                                      :follow_from_list         => :post,
                                      :unfollow_from_list       => :post
                                    } do |user|
    user.resources :invitations, :only => [:destroy, :index],
      :member => { :accept => :post }
  end

  map.resources :conversations, :collection => {:bookmarked => :get, :new_messages => :get}, :member => {
    :toggle_private_status   => :put,
    :toggle_readwrite_status => :put,
    :toggle_bookmark         => :post,
    :follow_with_token       => :get,
    :follow_email_with_token => :get,
    :unfollow                => :post,
    :unfollow_from_list      => :post,
    :invite                  => :get,
    :invite_from_list        => :post,
    :invite_all_my_followers => :post,
    :invite_via_email        => :post,
    :remove_user             => :post,
    :files                   => :get,
    :images                  => :get,
    }, :new => { :spawn => :get } do |conversation|
      conversation.resources :messages, :member => { :report => :post }, 
                                        :collection => {:images => :get, :files => :get},
                                        :except => [:edit, :update, :destroy]
      conversation.resources :subscribers
    end
  
  # OAuth routes
  map.resources :oauth_clients
  map.authorize '/oauth/authorize',:controller=>'oauth',:action=>'authorize'
  map.request_token '/oauth/request_token',:controller=>'oauth',:action=>'request_token'
  map.access_token '/oauth/access_token',:controller=>'oauth',:action=>'access_token'
  map.test_request '/oauth/test_request',:controller=>'oauth',:action=>'test_request'
            
  map.root :controller => "home"
  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:perishable_token', :controller => "users", :action => "activate"
  map.disable '/disable', :controller => "users", :action => "disable"
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
