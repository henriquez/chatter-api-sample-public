require 'test_helper'


class UserTest < ActiveSupport::TestCase
  
  test "encrypted tokens can be decrypted" do
    plaintext = "abcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcde"
    user = User.new :access_token => plaintext, :refresh_token => plaintext
    # check that encryption is actually happening
    assert_not_equal user.read_attribute(:refresh_token), plaintext
    user.save!
    user = User.find(user.id)
    # check that decryption is working
    assert_equal user.access_token, plaintext
    assert_equal user.refresh_token, plaintext
  end
  
  
end