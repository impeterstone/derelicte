class Photo < ActiveRecord::Base
  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end
  
  def self.create_from_json(params_json)
    
    photos = JSON.parse params_json
    biz = photos['biz']
    created_at = Time.now.utc.to_s(:db)
    updated_at = Time.now.utc.to_s(:db)
    
    # photos['photos'].each do |photo|
    #       
    #       # biz, src, caption, width, height, created_at, updated_at
    #       query = "
    #         REPLACE INTO photos (biz, src, caption, created_at, updated_at)
    #         VALUES (?,?,?,?,?)
    #       "
    #       query = sanitize_sql_array([query, biz, photo['src'], photo['caption'], created_at, updated_at])
    #       qresult = ActiveRecord::Base.connection.execute(query)
    #       
    #     end
    
    columns = [:biz, :src, :caption]
    values = []
    photos['photos'].each do |photo|
      values << [biz, photo['src'], photo['caption']]
    end
    Photo.import columns, values, :on_duplicate_key_update => [:caption]

  end
  
end


