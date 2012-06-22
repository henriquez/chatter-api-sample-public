# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Apibrowser::Application.initialize!

# used in user.rb model: sets what encryption key to use
Encryptor.default_options.merge!(:key => Apibrowser::Application.config.secret_token)
 
