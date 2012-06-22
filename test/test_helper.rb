ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  
  def setup_client
    client = Databasedotcom::Client.new
    client.version = "23.0"
    client.authenticate :token => IO.read(File.expand_path('../../test/fixtures/token.txt', __FILE__)),
                        :refresh_token => "fake refresh token",
                        :instance_url => users(:conan).instance_url
    client                    
  end  


  def login!
    session[:user_id] = users(:conan).id 
    set_token
  end
  
  
  def set_token
    u = users(:conan)
    u.access_token = IO.read(File.expand_path('../../test/fixtures/token.txt', __FILE__))
    u.refresh_token = 'fake refresh token'
    u.save!
  end
    
  
  def logout!
    session[:user_id] = nil
  end
  

  
end
