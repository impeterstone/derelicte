class MealtimeController < ApplicationController
  
  before_filter do |controller|
    # This will set the @version variable
    controller.load_version
    controller.force_ssl
  end
  
  def dump
    # Rails.logger.info request.query_parameters.inspect

    # We should expect this to be gzip, but it might be text
    encoding = request.headers["Content-Encoding"]
    
    if encoding.include? "gzip"
      Rails.logger.info "Detected gzip response"
      json_data = Zlib::GzipReader.new(StringIO.new(request.body.read)).read
    else
      Rails.logger.info "Detected text response"
      json_data = request.body.read
    end
        
    # Enqueue Job with post data
    Resque.enqueue(DumpJob, json_data)
    
    respond_to do |format|
      format.json  { render :json => {:status => 'success'} }
    end
  end
  
  def async_dump(request_body)
    begin

      
      ### BEGIN SYNC CALL ###
      # row = parsed_response
      # 
      # if row['type']=='places'
      #   place_json = JSON.generate row['data']
      #   Place.create_from_json(place_json)
      # elsif row['type']=='photos'
      #   row['biz']
      #   row['numphotos']
      #   row['data']['biz'] = row['biz']
      #   photo_json = JSON.generate row['data']
      #   Photo.create_from_json(photo_json)
      # elsif row['type']=='biz'
      #   row['data']['biz'] = row['biz']
      #   place_json = JSON.generate row['data']
      #   Place.create_from_biz_json(place_json)
      #   row['timestamp']
      # elsif row['type']=='reviews'
      #   row['data']['biz'] = row['biz']
      #   review_json = JSON.generate row['data']
      #   Review.create_from_json(review_json)
      # else
      #   # ignore unknown response
      # end
      
      ### END SYNC CALL ###
    
    rescue => e
      Rails.logger.info e
    end
  end
    
end
