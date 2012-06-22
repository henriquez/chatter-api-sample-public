require 'test_helper'


######################################################
# Requires a valid access token in the test/fixtures/token.txt  
# The Chatter API is actually used in this test.  Use docapp@api.ly user 
# when getting an access token or sid - or any other user 
# on na12 instance because tied to users(:conan) in some tests.
######################################################

class FeedTest < ActiveSupport::TestCase

  API_VERSION = "24.0"
  
    # setup the api client for this web request centrally so that  this
  # client may be used for this user across multiple API requests. 
  def setup   
    @current_user = User.new
    @current_user.access_token = ""
    @current_user.instance_url = "https://na12.salesforce.com"
    # see http://rubydoc.info/github/heroku/databasedotcom/master/Databasedotcom/Client:initialize
    @client = Databasedotcom::Client.new({:debugging => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE})
    @client.version = API_VERSION
    @client.authenticate :token => @current_user.access_token,
                         :instance_url => @current_user.instance_url
  end
  
  
  test "post to feed with file" do
    tempfile = '/Users/lhenriquez/Desktop/maui.jpg'
    json_body = ChatterFeedItem.create_file_body("test post with file",
                                                 "fake attachment name",
                                                 "fake attachment description",
                                                 'maui.jpg').to_json
                                                    
    @feed_item = ChatterFeed.post_file( @client, "news", json_body, 
                                        tempfile, 
                                        "image/png", 
                                        "maui.jpg" )
  end
  
  
end
