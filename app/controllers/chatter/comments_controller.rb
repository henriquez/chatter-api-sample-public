class Chatter::CommentsController < ApplicationController
  before_filter :require_login
  HEADERS = {"X-Chatter-Entity-Encoding" => "false"}
  
  
  # /chatter/comments/:comment_id/likes
  def like
    url = "/services/data/v#{@client.version}/chatter/comments/#{params[:comment_id]}/likes"
    response = @client.http_post(url, nil, nil, HEADERS).body
    # jquery expects the mime type to be set or won't parse the data object correctly
    render :text => response, :content_type => 'application/json' 
  end
  
  
  
  # POST /chatter/feed-items/:feed_item_id/comments
  # TODO: POST /feeds?originalFeedItemId=xxx  # share existing feed item
  def create     
    @comment = ChatterComment.post_anything(@client, params) # posts received content to Chatter API        
    # if 200, send a script to the child iframe (js template) to refresh 
    # the form and the feed(insert new feed item).
    render :new, :layout => false
  rescue Exception => e
    @feed_item_id = params[:feed_item_id]
    # report error to browser if post failed for any reason 
    @error = e.error_code + ": " + e.message[0..50] + " ..." + error_help(e)
    render :error, :layout => false
  end
  
  
  # XHR DELETE /comments/:id
  def destroy
    url = "/services/data/v#{@client.version}/chatter/comments/#{params[:comment_id]}"
    response = @client.http_delete(url, {}, HEADERS)
    head :no_content if response.code == '204'
      
  rescue Databasedotcom::SalesForceError => e
      render :text => e.error_code, :status => '403', :content_type => 'application/json'
  end
  
  


end