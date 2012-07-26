class OmniAuth::Strategies::GUS < OmniAuth::Strategies::Salesforce
  default_options[:client_options][:site] = 'https://gus.salesforce.com/'
end  

class OmniAuth::Strategies::Blitz01 < OmniAuth::Strategies::Salesforce
  default_options[:client_options][:site] = 'https://na1-blitz01.soma.salesforce.com/'
end  

Rails.application.config.middleware.use OmniAuth::Builder do
  # GUS RA app credentials need to be configured
  provider OmniAuth::Strategies::GUS, ENV['GUS_CLIENT_ID'], ENV['GUS_CLIENT_SECRET']
  # login.salesforce.com
  provider :salesforce, ENV['DATABASEDOTCOM_CLIENT_ID'], ENV['DATABASEDOTCOM_CLIENT_SECRET']
  # 180 testing - note that the callback url must be https://localhost/auth/blitz01/callback in the RA app
  # since the part after "auth" is taken from the strategy subclass name.
  provider OmniAuth::Strategies::Blitz01, ENV['BLITZ01_CLIENT_ID'], ENV['BLITZ01_CLIENT_SECRET']
end

