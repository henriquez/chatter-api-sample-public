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
  # TODO: the blitz01 credentials need to be created/configured
  provider OmniAuth::Strategies::Blitz01, ENV['BLITZ01_CLIENT_ID'], ENV['BLITZ01_CLIENT_SECRET']
end

