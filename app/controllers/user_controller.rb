class UserController < ApplicationController
  
  before_filter do |controller|
    # This will set the @version variable
    controller.load_version
  end
  
  def new
    Rails.logger.info request.query_parameters.inspect
    
    # A user has logged in to phototime
    Resque.enqueue(UserJob, params)
    
    respond_to do |format|
      format.json  { render :json => {:status => 'success'} }
    end
    
  end
  
end
