
class Chatter::FeedsController < ApplicationController
  before_filter :require_login
  



  # GET /feeds/:feed_type
  # XHR call that returns the user's news feed in JSON
  def show
    # get JSON from the api and pass to browser for rendering, we're
    # only passing through the controller to work around SOP
    parameters = {"pageSize" => params[:pageSize]} # always present
    parameters.merge!({"page" => params[:page]}) unless params[:page].blank?
    @feed = ChatterFeed.get(@client, params[:type], parameters)
    # add instance URL to start of payload for rendering purposes -note that right bracket
    # is purposely missing to allow the merge
    @feed.sub!(/\A\s*{/, %Q|{ "instance_url": "#{current_user.instance_url}", "rails_csrf_token": "#{form_authenticity_token.to_s}", |)
    render :text => @feed, :content_type => 'application/json'
  rescue Databasedotcom::SalesForceError => e
    if e.message =~ /expired access*/i
      render :text => e.error_code, :status => '401', :content_type => 'application/json'
      reset_session # SFDC side session expired (only happens is token is revoked)
    else
      render :text => e.error_code, :status => '500', :content_type => 'application/json'
      Rails.logger.error e.message
    end
  rescue Exception => e
    # report error to browser if post failed for any reason 
    Rails.logger.error e  # some errors are obscured if you try to parse the error.
    render :text => e.error_code, :status => '500', :content_type => 'application/json'
  ensure  
    
  end
  
    

    
  # POST /feeds
  # TODO: POST /feeds?originalFeedItemId=xxx  # share existing feed item
  def create     
    @feed_item = ChatterFeed.post_anything(@client, params) # posts received content to Chatter API    
    # if 200, send a script to the child iframe (js template) to refresh 
    # the form and the feed(insert new feed item).
    @form_authenticity_token = form_authenticity_token.to_s
    render :new, :layout => false # only load the js in the template not the whole layout
  rescue Exception => e
    # report error to browser if post failed for any reason 
    @error = e.error_code + ": " + e.message[0..50] + " ..." + error_help(e)
    Rails.logger.info @error
    render :error, :layout => false
  end

  
end
