class ChatterFeed 
  
  HEADERS = {"X-Chatter-Entity-Encoding" => "false"}
  
  # all class methods since there is no local db row
  class << self
    
    # convert params into a form the API will receive.  Handles any type
    # of post - file, text, link. Returns the feed item posted if successful
    # or raises InvalidFeedPost
    def post_anything(client, params)
      if file = params['feed-item-file-input'] # file post
        json_body = ChatterFeedComponent.create_file_body(params['feed-item-body'],
                                                    params['attachment-name'],
                                                    params['attachment-desc'],
                                                    file.original_filename
                                                    ).to_json
        ChatterFeed.post_file( client, "news", json_body, 
                               file.tempfile, 
                               file.content_type, 
                               file.original_filename )
                                      
      elsif params['link-url']  # link post
        json_body = ChatterFeedComponent.create_link_body(params['feed-item-body'], 
                                                     params['link-url'],
                                                     params['link-name']).to_json
        ChatterFeed.post(client, "news", json_body) # returns JSON
      else   # text post
        json_body = ChatterFeedComponent.create_text_body(params['feed-item-body']).to_json
        ChatterFeed.post(client, "news", json_body) # returns JSON
      end
    end
    
    
    # get unencoded feed strings since our templates both server and client side
    # HTML encode by default.  Also makes it possible to perform HTML attr and other
    # special encoding as required without double-encoding.  Note that in v24 and earlier
    # the API incorrectly encodes by default - it doesn't encode &
    def get(client, feed_type, params={}, subject_id="me")
      url = "/services/data/v#{client.version}/chatter/feeds/#{feed_type}/#{subject_id}/feed-items"
      client.http_get(url, params, HEADERS).body
    end
    
    
    # Post a new feed item of any type except File
    # returns JSON version of the posted feed item.
    def post(client, feed_type, data, params={}, user_id="me")
      url = "/services/data/v#{client.version}/chatter/feeds/#{feed_type}/#{user_id}/feed-items"
      client.http_post(url, data, params, HEADERS).body
    end
    
    
    def post_file(client, feed_type, data, io, content_type, file_name, params={}, user_id="me")
      url = "/services/data/v#{client.version}/chatter/feeds/#{feed_type}/#{user_id}/feed-items"
      parts = { "json" => data , "feedItemFileUpload" => UploadIO.new(io, content_type, file_name)} 
      response = client.http_multipart_post(url, parts, params, HEADERS)
      response.body
    end
  
    
    
  
  end
  
  
  
   
  
  
  
  
  
  
  
  
  
end
