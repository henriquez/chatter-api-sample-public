require 'test_helper'

######################################################
# Requires a valid access token in the test/fixtures/token.txt  
# The Chatter API is actually used in this test, not stubbed, so
# you also need an internet connection.  # use docapp@api.ly user for live api tests 
# when getting an access token or sid - or any other user 
# on na12 instance because tied to users(:conan) in some tests.
######################################################

class FeedsControllerTest < ActionController::TestCase

  

  test "authenticated user should see feed" do
    login!
    get :index
    assert_response :success
    assert assigns(:feed)
  end


  test "un-authenticated user should not be able to get feed" do
    get :index
    assert_response :redirect
    assert_nil assigns(:feed)
  end
  
  

end
