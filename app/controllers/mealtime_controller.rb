class MealtimeController < ApplicationController
  
  before_filter do |controller|
    # This will set the @version variable
    controller.load_version
  end
  
  def dump
    
    metadata = JSON.generate(params[:_json])
    
    # puts metadata
    # parsedData = JSON.parse(metadata)
    
    # puts "META: #{parsedData}"
    
    query = "
      INSERT INTO dumps (metadata)
      VALUES (?)
    "
    
    response = {}
    begin
      qresult = Dump.execute_sql([query, metadata])
      response['status'] = "success"
    rescue => e
      response['status'] = "fail"
    end
    
  end
  
  def dump_parsed
    Rails.logger.info request.query_parameters.inspect
    
    #puts params["_json"]
    
    parsed_response = JSON.parse params["_json"]
    
    row = parsed_response
      
    if row['type']=='places'
      
      row['data']['places'].each do |place|
        place_json = JSON.generate place
        Place.create_from_json(place_json)
      end
      
    elsif row['type']=='photos'
      
      row['biz']
      row['numphotos']
      row['data']['biz'] = row['biz']
      photo_json = JSON.generate row['data']
      Photo.create_from_json(photo_json)
      
    elsif row['type']=='biz'
      
      row['biz']
      row['data'].each do |bizdetail|
        puts bizdetail
      end
      row['timestamp']
      
    elsif row['type']=='reviews'
      row['data']['reviews'].each do |review|
        # review_hash = {}
        # review_hash['biz'] = row['biz']
        # review_hash['srid'] = review['srid']
        # review_hash['rating'] = review['rating']
        # review_hash['comment'] = review['comment']
        # review_hash['date'] = review['date']
        # review_json = JSON.generate review_hash
        review['biz'] = row['biz']
        review_json = JSON.generate review
        Review.create_from_json(review_json)          
      end
      row['timestamp']
  
    else
      # ignore unknown response
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
