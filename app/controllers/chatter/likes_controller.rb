class Chatter::LikesController < ApplicationController
  before_filter :require_login

  HEADERS = {"X-Chatter-Entity-Encoding" => "false"}



  
  
  # DELETE /likes/:like_id to delete existing like
  def destroy
    url = "/services/data/v#{@client.version}/chatter/likes/#{params[:like_id]}"
    @client.http_delete(url, nil, HEADERS)
    render :text => "" # no body on delete, will mess with ajax call if body returned
  end
  
  
  # GET /feed_items/:feed_item_id/likes to get like collection for this feed item
  def index
  end
  
  
  
end