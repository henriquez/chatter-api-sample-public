source 'http://rubygems.org'

gem 'rails', '3.2.2'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem "omniauth-salesforce", ">=1.0.3"
gem "omniauth"
gem 'faraday' 

# hacked version with request logging:
#gem "databasedotcom", :path => "/Users/lhenriquez/Sites/databasedotcom"
gem 'databasedotcom', "1.3.0"  
gem "mocha", :require => false
gem "encryptor"
gem 'jquery-rails'
gem 'less-rails-bootstrap' # loads up bootstrap and less into asset pipeline
gem "thin"  # recommended for heroku too on cedar stack need to specify it
gem "multipart-post", :git => 'git://github.com/henriquez/multipart-post'
gem 'therubyracer' # required for less 

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.0.3' # messes with constructor.name in coffeescript - cause bugs
  gem 'eco'
end

group :production do
  gem 'pg'  # heroku gem provides pg in dev mode for prod consistency
end

group :development, :test do
  gem 'sqlite3'
  gem 'quiet_assets'
  gem "jasmine" # javascript testing framework
  #gem "webmock"
  #gem "vcr"
end



# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

