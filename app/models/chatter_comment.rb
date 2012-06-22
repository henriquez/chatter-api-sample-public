class ChatterComment
  
  HEADERS = {"X-Chatter-Entity-Encoding" => "false"}
  
  # all class methods since there is no local db row
  class << self
    
    # convert params into a form the API will receive.  Handles any type
    # of post - file, text, link. Returns the feed item posted if successful
    # or raises InvalidFeedPost
    def post_anything(client, params)
      if file = params['file-input'] # file post
        json_body = ChatterFeedComponent.create_file_body(params['body'],
                                                    params['attachment-name'],
                                                    params['attachment-desc'],
                                                    file.original_filename
                                                    ).to_json
        ChatterComment.post_file( client, params['feed_item_id'], json_body, 
                               file.tempfile, 
                               file.content_type, 
                               file.original_filename )
                                      
       else   # text post
        json_body = ChatterFeedComponent.create_text_body(params['body']).to_json
        ChatterComment.post(client, params['feed_item_id'], json_body) # returns JSON
      end
    end
    
    
    # get more comments if there are more than the 3 served in the feed.
    def get(next_page_url, client, page_size=100)    
      client.http_get(url, { :pageSize => page_size}, HEADERS).body
    end
    
    
    # Post a new text comment 
    # returns JSON version of the posted feed item.
    def post(client, feed_item_id, data, params={})
      url = "/services/data/v#{client.version}/chatter/feed-items/#{feed_item_id}/comments"
      client.http_post(url, data, params, HEADERS).body
    end
    
    
    def post_file(client, feed_item_id, data, io, content_type, file_name, params={})
      url = "/services/data/v#{client.version}/chatter/feed-items/#{feed_item_id}/comments"
      parts = { "json" => data , "feedItemFileUpload" => UploadIO.new(io, content_type, file_name)} 
      response = client.http_multipart_post(url, parts, params, HEADERS)
      response.body
    end
  
    
    
  
  end
  
  
  
   
  
  
  
  
  
  
  
  
  
end
