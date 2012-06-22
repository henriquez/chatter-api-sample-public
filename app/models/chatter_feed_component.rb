class ChatterFeedComponent
  
  class InvalidPost < StandardError; end
  
  
  
   # all class methods since there is no local db row
  class << self  
     
    # create the body of the post (not the body value) 
    def create_file_body(post, title, description, filename)
      body = create_text_body(post)
      body.merge( { :attachment => { :title => title, :desc => description, :fileName => filename  } } )
    end
       
     
    def create_link_body(post, url, url_name)
      body = create_text_body(post)
      body.merge( { :attachment => { :url => url, :urlName => url_name  } } )
    end   
     
       
    # Takes the form body posted with mentions and parses the mentions
    # format into message segments for posting to the API
    def create_text_body(post)
      # not equal to api's post length because here we just want to protect 
      # our resources and let the api return an error due to length as the
      # api's limits may change over time. Also the client checks for the 1000 char length
      raise InvalidPost, "post body missing" if post.blank?
      raise InvalidPost, "post too large" if post.length > 3000 
      segments = ChatterMessageSegment.build_segments(post) 
      raise InvalidPost, "invalid mention" if !segments # blank posts should also be error on client
      { :body => { :messageSegments => segments } }  
    end
    
    
  end
  
end
