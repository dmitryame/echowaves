ActionController::Routing::Routes.draw do |map|
  
  map.resource  :user_session
  map.resources :password_resets
  map.resource  :msgsearch, :only => [:show, :create]
  map.resource  :convosearch, :only => [:show, :create]
  map.resources :users, :member =>  { :tagged_convos => :get,
                                      :followers => :get,
                                      :followed_users => :get,
                                      :followed_convos => :get
                                    }

  map.resources :conversations, :collection => {:bookmarked => :get}, :member => {
    :private_status          => :put,
    :readwrite_status        => :put,
    :toogle_bookmark         => :post,
    :follow                  => :post,
    :follow_with_token       => :get,
    :follow_email_with_token => :get,
    :unfollow                => :post,
    :follow_from_list        => :post,
    :unfollow_from_list      => :post,
    :invite                  => :get,
    :invite_from_list        => :post,
    :invite_all_my_followers => :post,
    :invite_via_email        => :post,
    :remove_user             => :post,
    :files                   => :get,
    :images                  => :get,
    :system_messages         => :get
    }, :new => { :spawn => :get } do |conversation|
      conversation.resources :messages, :member => { :report => :post }, 
                                        :collection => {:images => :get, :files => :get, :system_messages => :get},
                                        :except => [:edit, :update, :destroy]
    end
  
  # OAuth routes
  map.resources :oauth_clients
  map.authorize '/oauth/authorize',:controller=>'oauth',:action=>'authorize'
  map.request_token '/oauth/request_token',:controller=>'oauth',:action=>'request_token'
  map.access_token '/oauth/access_token',:controller=>'oauth',:action=>'access_token'
  map.test_request '/oauth/test_request',:controller=>'oauth',:action=>'test_request'
            
  map.home '/', :controller => "home", :action => "index"
  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:perishable_token', :controller => "users", :action => "activate"
  
  map.complete_conversation_name '/complete_conversation_name', :controller => 'conversations', :action => "complete_name"
  map.complete_user_name '/complete_user_name', :controller => 'users', :action => "complete_name"
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
