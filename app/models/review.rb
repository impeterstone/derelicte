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
    
    
    data = JSON.parse params_json
    columns = [:biz, :srid, :rating, :comment, :date, :created_at, :updated_at]
    values = []
    data['reviews'].each do |review|
      # review_hash = {}
      # review_hash['biz'] = row['biz']
      # review_hash['srid'] = review['srid']
      # review_hash['rating'] = review['rating']
      # review_hash['comment'] = review['comment']
      # review_hash['date'] = review['date']
      # review_json = JSON.generate review_hash
      review['biz'] = row['biz']
      values << review         
    end

    Review.import columns, values, :on_duplicate_key_update => [:biz, :rating, :comment, :date, :updated_at]
    
  end
  
end


