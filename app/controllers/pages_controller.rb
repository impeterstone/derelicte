class PagesController < ApplicationController
  caches_page :privacy
  caches_page :terms
  
  def privacy
    @title = "Privacy Policy"
  end

  def terms
    @title = "Terms of Service"
  end
  
  def home
    @title = "Home"
  end
  
  def beta
  end
  
end
