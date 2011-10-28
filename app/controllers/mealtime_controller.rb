class MealtimeController < ApplicationController
  
  @@consumer_key = '59qAq_rFiMt26wRMTOXTMA'
  @@consumer_secret = 'N5BxbhjpRp5g3iA-SXaDx78jWI0'
  @@token = 'ifKMaMyp7X9JqmCePD3BzskBGYZ1q0Tb'
  @@token_secret = 'vKrHGl5-gGin81a6Mb5ZIwjiHd0'
  
  @@yelp_api_host = 'api.yelp.com'
  
  before_filter do |controller|
    # This will set the @version variable
    controller.load_version
    # controller.force_ssl
  end
  
  def search
    # This endpoing takes in parameters and proxies a request to the Yelp API
    # We also intercept the data coming back, cache it, and reformat for iOS client
    
    # Process Parameters
    term = !params[:term].nil? ? params[:term] : nil
    ll = !params[:ll].nil? ? params[:ll] : nil # lat,lng - takes precedence over location
    location = !params[:location].nil? ? params[:location] : nil # city, address, neighborhood
    sort = !params[:sort].nil? ? params[:sort] : 0 # 0 - best match, 1 - distance, 2 - rating
    cflt = !params[:cflt].nil? ? params[:cflt] : "food,bars" # category filter
    radius = !params[:radius].nil? ? params[:radius] : "3218" # meters, default 2 miles
    offset = !params[:offset].nil? ? params[:offset] : 0
    limit = !params[:limit].nil? ? params[:limit] : 20
    
    # Build URL
    path = "/v2/search?category_filter=#{cflt}&sort=#{sort}&radius_filter=#{radius}&offset=#{offset}&limit=#{limit}"
    if !term.nil?
      path += "&term=#{term}"
    end
    if !ll.nil?
      path += "&ll=#{ll}"
    elsif !location.nil?
      path += "&location=#{location}"
    else
      path += "&ll=37.32798,-122.01382" # default to Cupertino, CA
    end
    
    consumer = OAuth::Consumer.new(@@consumer_key, @@consumer_secret, {:site => "http://#{@@yelp_api_host}"})
    access_token = OAuth::AccessToken.new(consumer, @@token, @@token_secret)

    # path = "/v2/search?term=restaurants&ll=37.788022,-122.399797&limit=20&sort=0"

    res = access_token.get(path).body
    output = JSON.parse(res)
    
    total = output["total"]
    businesses = output["businesses"] # array
    
    places_array = []
    businesses.each do |b|
      puts "\n\nBiz: #{b.inspect}\n\n"
      p = {}
      p["biz"] = b["mobile_url"].sub("http://m.yelp.com/biz/","") # strip the mobile url to get biz
      p["cover_photo"] = !b["image_url"].nil? ? b["image_url"].sub("ms.jpg","l.jpg") : "http://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/I-404.svg/200px-I-404.svg.png" # image_url can be nil
      p["rating"] = b["rating"]
      p["name"] = b["name"]
      p["yid"] = b["id"]
      p["review_count"] = b["review_count"]
      
      # Categories is an array of arrays, each one having the display text and the identifier as elements
      cat_array = []
      b["categories"].each do |cat|
        cat_array << cat.first
      end
      p["categories"] = cat_array.join(', ')
      
      l = b["location"] # location hash
      p["city"] = l["city"]
      p["postal_code"] = l["postal_code"]
      p["address"] = l["address"].join(' ')
      p["state_code"] = l["state_code"]
      p["formatted_address"] = "#{p["address"]}, #{p["city"]}, #{p["state_code"]} #{p["postal_code"]}"
      
      c = l["coordinate"] # coordinate hash
      p["latitude"] = c["latitude"]
      p["longitude"] = c["longitude"]
      
      places_array << p
    end
    
    response = {}
    response["total"] = total
    response["places"] = places_array
    
    Rails.logger.info "Requested Path: #{path}" # Log the url path
    Rails.logger.info "Total: #{total}"
    
    respond_to do |format|
      format.json  { render :json => response }
    end
  end
  
  def business
    # This endpoing takes in parameters and proxies a request to the Yelp API
    # We also intercept the data coming back, cache it, and reformat for iOS client
    
    # Process Parameters
    yid = !params[:yid].nil? ? params[:yid] : nil
    
    # Build URL
    if !yid.nil?
      path = "/v2/business/#{yid}"
    end
    
    consumer = OAuth::Consumer.new(@@consumer_key, @@consumer_secret, {:site => "http://#{@@yelp_api_host}"})
    access_token = OAuth::AccessToken.new(consumer, @@token, @@token_secret)
    
    res = access_token.get(path).body
    output = JSON.parse(res)
    
    response = output # debug, reformat this response later
    
    respond_to do |format|
      format.json  { render :json => response }
    end
  end
  
  # def force_ssl
  #   if !request.ssl? && !Rails.env.development?
  #     redirect_to :protocol => 'https://', :status => :moved_permanently
  #   end
  # end
  
  def dump
    # Rails.logger.info request.query_parameters.inspect
    puts "type: #{params[:type]}"
    puts "is ssl: #{request.ssl?}"
    
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
    if !params[:type].nil?
      Resque.enqueue(DumpJob, json_data, params[:type])
    end
    
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
