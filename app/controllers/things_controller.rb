class ThingsController < ApplicationController
  before_filter :require_login
  
  # The main page displayed after authentication.
  # Displays the chatter sidebar as well.  This is meant as a generic page 
  # where a real app would put its stuff post authentication.
  def index

  end
  
end