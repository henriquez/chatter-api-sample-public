require 'test_helper'
require "mocha"

######################################################
# Requires a valid access token in the test/fixtures/token.txt  
# The Chatter API is actually used in this test.  Only
# the Oauth/Omniauth interaction is stubbed out.
######################################################

class AuthFlowsTest < ActionDispatch::IntegrationTest
  fixtures :users
  
  def setup
  end
  
    
  test "unauthenticated user should be able to get root page with https" do
    https!
    get root_path # get the index page that doesn't require a logged in user
    assert_response :success
  end
  
      
  # See https://github.com/intridea/omniauth/wiki/Integration-Testing
  # for how to stub omniauth requests    
  test "valid login should set cookie and allow browsing authenticated pages" do
    login
    browse_authenticated_page
  end
  
  
  test "logout should kill session and render root path and prevent feed page viewing" do
    login
    post_via_redirect '/logout'
    assert_response :success # because the previous method follows the redirect
    assert_equal '/', path # should not be on authenticated page
    assert session[:user_id] == nil
    get feeds_path
    assert_response :redirect
  end
  
  
  test "login failure should show error message and render root path" do
    https!
    get_via_redirect '/auth/failure'
    assert_response :success # because the previous method follows the redirect
    assert_not_nil flash[:notice]
    assert_equal '/', path
  end
  
  
  test "unauthenticated user should not be able to see feed page" do
    https!
    get_via_redirect feeds_path
    assert_response :success
    assert_equal '/', path
  end
  
  
  ################### helper methods ####################
  private 
  
    
  def browse_authenticated_page
    https!
    get feeds_path
    assert_response :success
    assert assigns(:feed)
  end
  
  
  # simulate login.  stubs out Omniauth's oauth dance, but requires
  # a valid access token in the token.txt fixture so that the 
  # Chatter API is actually used.
  def login
    OmniAuth.config.test_mode = true
    uid = "https://login.salesforce.com/id/00DU0000000J8pvMAC/005U0000000EUjcIAG"
    OmniAuth.config.mock_auth[:salesforce] = {
      'provider' => 'salesforce',
      'credentials' => { 'instance_url'  => 'https://na12.salesforce.com/',
                         'refresh_token' => 'invalid refresh token',
                         'token'         => IO.read(File.expand_path('../../../test/fixtures/token.txt', __FILE__))
                     },
      'uid' => uid,
      'extra' => { 'display_name' => 'conan the barbarian',
               'organization_id'  => '00DU0000000J8pvMAC',
               'user_id'          => '005U0000000EUjcIAG',
               'email'            => 'conan@jungle.com',
               'first_name'       => 'Conan',
               'last_name'        => 'The Barbarian'
               }
    }

    https!
    post_via_redirect '/auth/salesforce' # test mode will auto-redirect to sessions#create
    assert_response :success
    assert_not_nil session[:user_id] 
    assert assigns(:feed)
  end
     
end


