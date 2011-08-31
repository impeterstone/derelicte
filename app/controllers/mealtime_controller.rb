class MealtimeController < ApplicationController
  
  before_filter do |controller|
    # This will set the @version variable
    controller.load_version
  end
  
  def dump
    Rails.logger.info request.query_parameters.inspect
    
    begin
      jsonData = nil
      parsedData = nil
      
      # We should expect this to be gzip, but it might be text
      encoding = request.headers["Content-Encoding"]
      if encoding.include? "gzip"
        Rails.logger.info "Detected gzip response"
        jsonData = Zlib::GzipReader.new(StringIO.new(request.body.read)).read
        parsedData = JSON.parse(jsonData)
      else
        Rails.logger.info "Detected text response"
        jsonData = request.body.read
        parsedData = JSON.parse(jsonData)
      end
    
      query = "
        INSERT INTO dumps (metadata)
        VALUES (?)
      "
      qresult = Dump.execute_sql([query, jsonData])
            
      response = {}
      response['status'] = "success"
    rescue => e
      Rails.logger.info e.inspect
      response['status'] = "fail"
    end
    
    respond_to do |format|
      format.json  { render :json => response }
    end
    
  end
  
end
