class MealtimeController < ApplicationController
  
  before_filter do |controller|
    # This will set the @version variable
    controller.load_version
  end
  
  def dump
    # Rails.logger.info request.query_parameters.inspect
    
    response = {}
    
    begin
      jsonData = nil
      parsedData = nil
      
      # We should expect this to be gzip, but it might be text
      encoding = request.headers["Content-Encoding"]
      if encoding.include? "gzip"
        Rails.logger.info "Detected gzip response"
        jsonData = Zlib::GzipReader.new(StringIO.new(request.body.read)).read
        parsed_response = JSON.parse(jsonData)
      else
        Rails.logger.info "Detected text response"
        jsonData = request.body.read
        parsed_response = JSON.parse(jsonData)
      end
    
      query = "
        INSERT INTO dumps (metadata)
        VALUES (?)
      "
      qresult = Dump.execute_sql([query, jsonData])
      
      ### BEGIN SYNC CALL ###
      row = parsed_response

      if row['type']=='places'
        place_json = JSON.generate row['data']
        Place.create_from_json(place_json)
      elsif row['type']=='photos'
        row['biz']
        row['numphotos']
        row['data']['biz'] = row['biz']
        photo_json = JSON.generate row['data']
        Photo.create_from_json(photo_json)
      elsif row['type']=='biz'
        row['data']['biz'] = row['biz']
        place_json = JSON.generate row['data']
        Place.create_from_biz_json(place_json)
        row['timestamp']
      elsif row['type']=='reviews'
        row['data']['biz'] = row['biz']
        review_json = JSON.generate row['data']
        Review.create_from_json(review_json)
      else
        # ignore unknown response
      end
      
      ### END SYNC CALL ###
      
            

      response['status'] = "success"
    rescue => e
      Rails.logger.info e.inspect
      response['status'] = "fail"
    end
    
    respond_to do |format|
      format.json  { render :json => response }
    end
    
  end
  
  def dump_parsed
    Rails.logger.info request.query_parameters.inspect
    
    #puts params["_json"]
    
    parsed_response = JSON.parse params["_json"]
    
    row = parsed_response
    if row['type']=='places'
      place_json = JSON.generate row['data']
      Place.create_from_json(place_json)
    elsif row['type']=='photos'
      row['biz']
      row['numphotos']
      row['data']['biz'] = row['biz']
      photo_json = JSON.generate row['data']
      Photo.create_from_json(photo_json)
    elsif row['type']=='biz'
      row['data']['biz'] = row['biz']
      place_json = JSON.generate row['data']
      puts place_json
      Place.create_from_biz_json(place_json)
      row['timestamp']
    elsif row['type']=='reviews'
      row['data']['biz'] = row['biz']
      review_json = JSON.generate row['data']
      Review.create_from_json(review_json)
    else
      # ignore unknown response
    end
    
    respond_to do |format|
      format.json  { render :json => response }
    end
    
  end
  
end
