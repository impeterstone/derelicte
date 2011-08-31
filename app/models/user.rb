class User < ActiveRecord::Base
  @queue = :user_job
  
  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end
  
  def self.logged_in(params)
    puts "user job!: #{params}"
    facebook_access_token = params['facebook_access_token']
    udid = params['udid']
    facebook_id = params['facebook_id']
    facebook_name = params['facebook_name']
    facebook_can_publish = params['facebook_can_publish']
    time_now = Time.now.utc.to_s(:db)
    
    query = "
      INSERT INTO users (udid, facebook_access_token, facebook_id, facebook_name, facebook_can_publish, created_at, updated_at) 
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE udid = ?, facebook_access_token = ?, facebook_can_publish = ?, updated_at = ?
    "
    qresult = self.execute_sql([query, udid, facebook_access_token, facebook_id, facebook_name, facebook_can_publish, created_at, updated_at, udid, facebook_access_token, facebook_can_publish, updated_at])
  end
end
