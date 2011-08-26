class UserController < ApplicationController
  
  before_filter do |controller|
    # This will set the @version variable
    controller.load_version
  end
  
  def new
    Rails.logger.info request.query_parameters.inspect
    
    # Create a new user if not exists
    facebook_access_token = params['facebook_access_token']
    udid = params['udid']
    facebook_id = params['facebook_id']
    name = params['name']
    query = "INSERT INTO users (facebook_access_token, udid, facebook_id, name) VALUES ('#{facebook_access_token}', '#{udid}', '#{facebook_id}', '#{name}') ON DUPLICATE KEY UPDATE facebook_access_token = '#{facebook_access_token}, udid = '#{udid}'"
    mysqlresult = ActiveRecord::Base.connection.execute(query)
    
  end
  
end
