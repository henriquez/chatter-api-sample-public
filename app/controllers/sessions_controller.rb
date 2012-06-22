# The Chatter Sample application uses login.salesforce.com as a login provider - this 
# app doesn't provide its own username/password so that the user doesn't have to 
# create and remember another set of credentials. Obviously you can change
# the app to store and require its own credentials if desired.
# After logging in at login.salesforce.com the Chatter sample app saves its own
# cookie so that the user can use the app independent of the saleforce session.  
# This cookie is not tied to the 
# salesforce session, so the user's login status in this app is independent of their
# login status with salesforce.  When the user logs out of this app, the session
# cookie is deleted and the user must login again.  The cookie
# expires after 2 hours (see config/initializers/session_store.rb).  If the user is 
# already logged into salesforce and has previously used this app, the user won't 
# see a login dialog but will just be redirected to the app.

# The app uses its Oauth access token for all data access, including getting static assets
# The app also stores a refresh token, and automatically recovers from expired 
# access tokens using the refresh token.  (See https://github.com/heroku/databasedotcom/blob/master/lib/databasedotcom/client.rb
# the ensure_expected_response method.

class SessionsController < ApplicationController
  before_filter :require_login, :except => [:create, :failure]
  
  
  # salesforce calls this after the user approves the application in the Oauth dialog
  # and also after logging in subsequently.  Set an 2 hour session cookie.
  def create
    auth_hash = request.env["omniauth.auth"] #=> OmniAuth::AuthHash
    user = User.find_or_create_context_user(auth_hash)
     
    if user
      session[:user_id] = user.id # local db model user id used for user identification, not available to browser
      cookies[:user_id] = user.user_id # SFDC user id, used for creating the view, available to browser code  
      redirect_to things_path
    else  # this should never happen
      Rails.logger.error "No user after login via Salesforce"
      flash[:error] = "No user after login via Salesforce"
      redirect_to root_path
    end
  end


  # OAuth application approval failed - user clicked "Deny" on OAuth dialog
  # and Omniauth sends the user here.
  def failure
    flash[:error] = params[:message] # putting the error on the redirect doens't work!
    flash[:error] << ". Note that if the Salesforce organization you are authenticating against has IP or other login restrictions, you cannot use it with this application."
    redirect_to root_path 
  end
  
  
  # user signs out of this app (not salesforce). Delete the cookie.
  # Note that the app still has an access token and refresh token so can 
  # still hit the api for notifications. 
  def destroy
    reset_session
    redirect_to root_path
  end
  
  
  # user revokes this app's access to the API, equivalent to "remove this app"
  # here we delete the whole user object including the tokens.def tokens.
  # could call the Oauth "revoke token" endpoint too to revoke on the SFDC side.
  def revoke
    # Optional - exercise for the reader.
  end
  
  
end
