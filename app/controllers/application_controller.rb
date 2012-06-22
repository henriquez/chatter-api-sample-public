class ApplicationController < ActionController::Base
  protect_from_forgery

# TODO: remove this after debug
# VCR.configure do |c|
#   c.allow_http_connections_when_no_cassette = true
#   c.cassette_library_dir = 'fixtures/vcr_cassettes'
#   c.hook_into :webmock # or :fakeweb
# end

  API_VERSION = "25.0"
  
  rescue_from ActiveRecord::RecordNotFound, 
              ActionController::UnknownController, AbstractController::ActionNotFound, 
              ActionController::MethodNotAllowed, :with => :render_404
  
  
  # returns helpful info depending on the type of API error
  def error_help(error)
    if error.error_code == 'API_DISABLED_FOR_ORG'
      return "Your user may have the API enabled user profile perm off, or your user or org may not have Chatter turned on. Check with your administrator"
    else
      return ''
    end
  end
  
  
               
  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue Exception
    Rails.logger.error "User had cookie but no user with that id found in the db-treating as no user found."
    return nil
  end
  helper_method :current_user
  
  
  def logged_in?
    return current_user != nil 
  end
  helper_method :logged_in?
  
  
  # filter for pages that may only be visited by users logged in.
  def require_login
    if !current_user
      if request.url =~ %r|/chatter/| # chatter controller
        # /chatter controllers have their own error handler for unauthenticated scenarios because none of the actions
        # refresh the page and thus the redirect will disappear in the XHR or hidden iframe.
        if request.xhr?
          render :text => 'You are not authenticated', :status => '401', :content_type => 'application/json'
        else
          render '/chatter/shared/login_error', :layout => false
        end
      else  
        store_location
        flash[:notice] = "Please log in first."
        redirect_to root_url        
      end
      return false
    else # we have a current user
      setup_api_client 
    end  
  end
  helper_method :require_user


  def require_no_login
    redirect_to things_url if current_user   
  end
  helper_method :require_no_login  


  def store_location
    session[:return_to] = request.fullpath
  end
   
   
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
    
     
  # setup the api client for this web request centrally so that  this
  # client may be used for this user across multiple API requests. 
  def setup_api_client
    # see http://rubydoc.info/github/heroku/databasedotcom/master/Databasedotcom/Client:initialize
    # add :debugging => true to constructor hash to log API request/responses
    @client = Databasedotcom::Client.new({})
    @client.version = API_VERSION
    @client.authenticate :token => @current_user.access_token,
                         :refresh_token => @current_user.refresh_token,
                         :instance_url => @current_user.instance_url
  end
  
  
  def render_404
    Rails.logger.error $! # logs the exception object
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end


  def render_500
    Rails.logger.error $! # logs the exception object
    render :file => "#{Rails.root}/public/500.html", :status => 500, :layout => false
  end  
    
end
