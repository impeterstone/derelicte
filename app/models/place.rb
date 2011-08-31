class Place < ActiveRecord::Base
  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end
  
  def self.create_from_json(params_json)
    
    place = JSON.parse params_json
    created_at = Time.now.utc.to_s(:db)
    updated_at = Time.now.utc.to_s(:db)
    
    # id, biz, name, rating, phone, numreviews, price, category
    # city, address, coordinates, hours, numphotos, score, created_at, updated_at
    
    query = "
      REPLACE INTO places (biz, name, score, phone, numreviews, price, category, created_at, updated_at)
      VALUES (?,?,?,?,?,?,?,?,?)
    "
    query = sanitize_sql_array([query, place['biz'], place['name'], place['score'], place['phone'], place['numreviews'], place['price'], place['category'], created_at, updated_at])
    qresult = ActiveRecord::Base.connection.execute(query)
    
  end
  
  def self.create_from_biz_json(params_json)
    
    place = JSON.parse params_json
    created_at = Time.now.utc.to_s(:db)
    updated_at = Time.now.utc.to_s(:db)
    

    # id, biz, name, rating, phone, numreviews, price, category, city, country, address, latitude, longitude, hours, numphotos, score, bizinfo, snippets, created_at, updated_at
    
    # biz, city, zip, longitude, state, latitude, country
    address = ""
    place['address'].each do |row|
      address += row+" "
    end
    
    bizDetails_json = JSON.generate place['bizDetails']
    bizcategories_json = JSON.generate place['bizcategories']
    
    query = "
      REPLACE INTO places (biz, address, city, state, zip, longitude, latitude, country, category, bizinfo, created_at, updated_at)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
    "
    query = sanitize_sql_array([query, place['biz'], address, place['city'], place['state'], place['zip'], place['longitude'], place['latitude'], place['country'], bizcategories_json, bizDetails_json, created_at, updated_at])
    qresult = ActiveRecord::Base.connection.execute(query)
    
  end
  
end


