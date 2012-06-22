class Chatter::UsersController < ApplicationController
  before_filter :require_login
  
  # XHR request to load the mentions picker's list of following users
  def mentions
    render :text => ChatterUser.following(@client, current_user)
  rescue Databasedotcom::SalesForceError => e
    if e.message =~ /expired access*/i
      render :text => e.error_code, :status => '401', :content_type => 'application/json'
      reset_session # SFDC side session expired (only happens is token is revoked)
    else
      render :text => e.error_code, :status => '500', :content_type => 'application/json'
      Rails.logger.error e.message
    end
  end
  
  # proxy request for user profile photos (any photo really) because
  # these require an authenticated request
  def photo
    url = params[:url]
    image = @client.http_get(url).body
    send_data image,  :disposition => 'inline', :content_type => 'image'
  end
  
  
end