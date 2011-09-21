class Place < ActiveRecord::Base
  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end
  
  def self.create_from_json(params_json)
    
    data = JSON.parse params_json
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
    
    place_columns = [:biz, :name, :latitude, :longitude, :score, :rating, :phone, :price, :numphotos, :numreviews, :category, :address, :hours]
    photo_columns = [:biz, :src, :caption]
    place_values = []
    photo_values = []
    data['places'].each do |place|
      # Get Place
      address = place['address'].join(' ')
      hours = place['hours'].join(' ')
      place_values << [place['biz'], place['name'], place['latitude'], place['longitude'], place['score'], place['rating'], place['phone'], place['price'], place['numphotos'], place['numreviews'], place['category'], address, hours]
      # Get Photos
      place['photos'].each do |photo|
        photo_values << [place['biz'], photo['src'], photo['caption']]
      end
    end
    Place.import place_columns, place_values, :on_duplicate_key_update => [:name, :latitude, :longitude, :score, :rating, :phone, :price, :numphotos, :numreviews, :category, :address, :hours]
    Photo.import photo_columns, photo_values, :on_duplicate_key_update => [:src, :caption]
    
  end
  
end


