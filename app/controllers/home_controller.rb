class HomeController < ApplicationController
  before_filter :require_no_login
  
  # root of the site - unauthenticated users land here to login
  def index
    
  end
  
  
end
