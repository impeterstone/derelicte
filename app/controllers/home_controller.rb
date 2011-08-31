class HomeController < ApplicationController

  def beta
    @foos = params[:email]
    puts @foos
    
    respond_to do |format|
        format.html { redirect_to(home_url, :notice => "Email saved.") }
        format.js
    end
  end
  
end
