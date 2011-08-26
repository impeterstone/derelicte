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
    facebook_name = params['facebook_name']
    time_now = Time.now.utc.to_s(:db)
    query = "INSERT INTO users (udid, facebook_access_token, facebook_id, facebook_name, created_at, updated_at) VALUES ('#{udid}', '#{facebook_access_token}', '#{facebook_id}', '#{facebook_name}', '#{time_now}', '#{time_now}') ON DUPLICATE KEY UPDATE udid = '#{udid}', facebook_access_token = '#{facebook_access_token}', updated_at = '#{time_now}'"
    mysqlresult = ActiveRecord::Base.connection.execute(query)
    
    render :text => "OK"
    
  end
  
end
