class Place < ActiveRecord::Base
  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end
  
  def self.create_from_json(params_json)
    
    dump = JSON.parse params_json
    place = dump['data']

    # created_at = Time.now.utc.to_s(:db)
    #     updated_at = Time.now.utc.to_s(:db)
    
    # id, biz, name, rating, phone, numreviews, price, category
    # city, address, coordinates, hours, numphotos, score, created_at, updated_at
    
    # query = "
    #   REPLACE INTO places (biz, name, score, phone, numreviews, price, category, created_at, updated_at)
    #   VALUES (?,?,?,?,?,?,?,?,?)
    # "
    # query = sanitize_sql_array([query, place['biz'], place['name'], place['score'], place['phone'], place['numreviews'], place['price'], place['category'], created_at, updated_at])
    # qresult = ActiveRecord::Base.connection.execute(query)
    
    place_columns = [:biz, :alias, :name, :score, :rating, :phone, :price, :category, :num_photos, :num_reviews, :cover_photo, :latitude, :longitude, :hours, :address, :city, :zip, :country]
    photo_columns = [:biz, :src, :caption]
    place_values = []
    photo_values = []

    # Get Place Biz Details
    # biz = place['bizDetails']['bizSafe']
    # bizdetails = JSON.generate place['bizDetails']
    # bizdetails = ''
    
    biz = place['biz']
    p_alias = place['alias']
    name = place['name']
    score = place['score']
    rating = place['rating']
    phone = place['formattedPhone']
    price = place['price']
    category = place['category']
    num_photos = place['numPhotos']
    num_reviews = place['numReviews']
    cover_photo = place['coverPhoto']
    latitude = place['latitude']
    longitude = place['longitude']

    if !place['hours'].nil?
      hours = place['hours'].join(',')
    else
      hours = nil
    end
    
    address = place['formattedAddress']
    
    attrs = place['attrs']
    if !attrs.nil?
      city = attrs['city']
      zip = attrs['zipcode']
      country = attrs['country']
    else
      city = nil
      zip = nil
      country = nil
    end
    
    place_values << [biz, p_alias, name, score, rating, phone, price, category, num_photos, num_reviews, cover_photo, latitude, longitude, hours, address, city, zip, country]
    Place.import place_columns, place_values, :on_duplicate_key_update => [:name, :score, :rating, :phone, :price, :category, :num_photos, :num_reviews, :cover_photo, :latitude, :longitude, :hours, :address, :city, :zip, :country]
    
    # Get Photos
    photos = place['photos']
    if !photos.nil?
      place['photos'].each do |photo|
        photo_values << [place['biz'], photo['src'], photo['caption']]
      end
      Photo.import photo_columns, photo_values, :on_duplicate_key_update => [:src, :caption]
    end

  end
  
  def self.create_from_biz_json(params_json)
    
    place = JSON.parse params_json
    # created_at = Time.now.utc.to_s(:db)
    # updated_at = Time.now.utc.to_s(:db)
    # # id, biz, name, rating, phone, numreviews, price, category, city, country, address, latitude, longitude, hours, numphotos, score, bizinfo, snippets, created_at, updated_at
    # 
    # # biz, city, zip, longitude, state, latitude, country
    # address = ""
    # place['address'].each do |row|
    #   address += row+" "
    # end
    # 
    # bizDetails_json = JSON.generate place['bizDetails']
    # 
    # query = "
    #   REPLACE INTO places (biz, address, city, state, zip, longitude, latitude, country, bizinfo, created_at, updated_at)
    #   VALUES (?,?,?,?,?,?,?,?,?,?,?)
    # "
    # query = sanitize_sql_array([query, place['biz'], address, place['city'], place['state'], place['zip'], place['longitude'], place['latitude'], place['country'], bizDetails_json, created_at, updated_at])
    # qresult = ActiveRecord::Base.connection.execute(query)
    
    columns = [:biz, :address, :city, :state, :zip, :longitude, :latitude, :country, :bizinfo]
    values = []
    bizDetails_json = JSON.generate place['bizDetails']
    address = ""
    place['address'].each do |row|
      address += row+" "
    end
    values << [place['biz'], address, place['city'], place['state'], place['zip'], place['longitude'], place['latitude'], place['country'], bizDetails_json]

    Place.import columns, values, :on_duplicate_key_update => [:address, :city, :state, :zip, :longitude, :latitude, :country, :bizinfo]
    
  end
  
end


