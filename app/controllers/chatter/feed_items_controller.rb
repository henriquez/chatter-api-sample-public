class Chatter::FeedItemsController < ApplicationController
  before_filter :require_login
  
  HEADERS = {"X-Chatter-Entity-Encoding" => "false"}
  # Ajax methods on feed items are as identical as possible to their API calls
  # for simplicity as well as to facilitate moving the client to direct API 
  # access when CORS is available or when the client is served from a domain
  # that allows direct access (e.g. force.com apps)
  
  
  # Ajax POST /chatter/feed-items/:feed_item_id/likes to create a new like
  def like
    url = "/services/data/v#{@client.version}/chatter/feed-items/#{params[:feed_item_id]}/likes"
    response = @client.http_post(url, nil, nil, HEADERS).body
    # jquery expects the mime type to be set or won't parse the data object correctly
    render :text => response, :content_type => 'application/json'  
  end
  
  
  # POST /feed_items/:id?isBookmarkedByCurrentUser=true   :: to bookmark
  # POST /feed_items/:id?isBookmarkedByCurrentUser=false  :: removes bookmark
  # (API verb is PATCH but not supported via Ajax)
  def bookmark
  end

  
  # DELETE /feed_items/:id
  def destroy
    url = "/services/data/v#{@client.version}/chatter/feed-items/#{params[:feed_item_id]}"
    response = @client.http_delete(url, {}, HEADERS)
    head :no_content if response.code == '204'
      
  rescue Databasedotcom::SalesForceError => e
      render :text => e.error_code, :status => '403', :content_type => 'application/json'
  end
  
  
  # GET /feed_items/:feed_item_id/comment
  def comments
  end
  
  
end
