class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def load_version(valid_versions = ["v1"])
    @version =  params[:version]
    if !valid_versions.include?(@version)
      error_response = {}
      error_response["error_type"] = "APIException"
      error_response["error_message"] = "Unknown API Version"
      render :json => error_response, :status => :unauthorized
    end
  end
  
end
