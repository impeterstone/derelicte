class MealtimeController < ApplicationController
  
  before_filter do |controller|
    # This will set the @version variable
    controller.load_version
  end
  
  def dump
    Rails.logger.info request.query_parameters.inspect
    
    # We should expect this to be gzip, but it might be text
    encoding = request.headers["Content-Encoding"]
    jsonData = nil
    parsedData = nil
    if encoding.include? "gzip"
      puts "found gzip response"
      jsonData = Zlib::GzipReader.new(StringIO.new(request.body.read)).read
      parsedData = JSON.parse(jsonData)
    else
      puts "found text response"
      jsonData = request.body.read
      parsedData = JSON.parse(jsonData)
    end
    
    query = "
      INSERT INTO dumps (metadata)
      VALUES (?)
    "
    
    response = {}
    begin
      qresult = Dump.execute_sql([query, jsonData])
      response['status'] = "success"
    rescue => e
      Rails.logger.info e.inspect
      response['status'] = "fail"
    end
    
    # Create a new user if not exists
    # facebook_access_token = params['facebook_access_token']
    # udid = params['udid']
    # facebook_id = params['facebook_id']
    # facebook_name = params['facebook_name']
    # facebook_can_publish = params['facebook_can_publish']
    # time_now = Time.now.utc.to_s(:db)
    # query = "INSERT INTO users (udid, facebook_access_token, facebook_id, facebook_name, facebook_can_publish, created_at, updated_at) VALUES ('#{udid}', '#{facebook_access_token}', '#{facebook_id}', '#{facebook_name}', '#{facebook_can_publish}', '#{time_now}', '#{time_now}') ON DUPLICATE KEY UPDATE udid = '#{udid}', facebook_access_token = '#{facebook_access_token}', facebook_can_publish = '#{facebook_can_publish}', updated_at = '#{time_now}'"
    # mysqlresult = ActiveRecord::Base.connection.execute(query)
    
    respond_to do |format|
      format.json  { render :json => response }
    end
    
  end
  
end
