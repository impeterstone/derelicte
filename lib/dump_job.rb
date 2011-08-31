class DumpJob < ActiveRecord::Base
  @queue = :dump_job
  
  def self.perform(json_data)
    begin
      puts "dump job!"
      parsed_data = JSON.parse(json_data)
      
      query = "
        INSERT INTO dumps (metadata)
        VALUES (?)
      "
      qresult = self.execute_sql([query, json_data])
      
      ### BEGIN SYNC CALL ###
      row = parsed_data
      
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
    rescue => e
      puts e.inspect
    end
  end
  
  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end
  
end