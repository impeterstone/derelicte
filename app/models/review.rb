class Review < ActiveRecord::Base
  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end
  
  def self.create_from_json(params_json)
    
    # review = JSON.parse params_json
    # created_at = Time.now.utc.to_s(:db)
    # updated_at = Time.now.utc.to_s(:db)
    # 
    # query = "
    #   REPLACE INTO reviews (biz, srid, rating, comment, date, created_at, updated_at)
    #   VALUES (?, ?, ?, ?, ?, ?, ?)
    # "
    # query = sanitize_sql_array([query, review['biz'], review['srid'], review['rating'], review['comment'], review['date'], created_at, updated_at])
    # qresult = ActiveRecord::Base.connection.execute(query)
    
    
    dump = JSON.parse params_json
    reviews = dump['data']
    
    columns = [:biz, :srid, :rating, :comment, :date]
    values = []
    data['reviews'].each do |review|
      values << [dump['biz'], review['srid'], review['rating'], review['comment'], review['date']]
    end

    Review.import columns, values, :on_duplicate_key_update => [:rating, :comment, :date]
    
  end
  
end


