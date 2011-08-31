class MealtimeController < ApplicationController
  
  before_filter do |controller|
    # This will set the @version variable
    controller.load_version
  end
  
  def dump
    Rails.logger.info request.query_parameters.inspect
    
    metadata = params[:metadata]
    parsedData = JSON.parse(metadata)
    
    # puts "META: #{parsedData}"
    
    query = "
      INSERT INTO dumps (metadata)
      VALUES (?)
    "
    
    qresult = Dump.execute_sql([query, metadata])
    
    # Create a new user if not exists
    # facebook_access_token = params['facebook_access_token']
    # udid = params['udid']
    # facebook_id = params['facebook_id']
    # facebook_name = params['facebook_name']
    # facebook_can_publish = params['facebook_can_publish']
    # time_now = Time.now.utc.to_s(:db)
    # query = "INSERT INTO users (udid, facebook_access_token, facebook_id, facebook_name, facebook_can_publish, created_at, updated_at) VALUES ('#{udid}', '#{facebook_access_token}', '#{facebook_id}', '#{facebook_name}', '#{facebook_can_publish}', '#{time_now}', '#{time_now}') ON DUPLICATE KEY UPDATE udid = '#{udid}', facebook_access_token = '#{facebook_access_token}', facebook_can_publish = '#{facebook_can_publish}', updated_at = '#{time_now}'"
    # mysqlresult = ActiveRecord::Base.connection.execute(query)
    
    render :text => qresult.nil?
    
  end
  
end
