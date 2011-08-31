class UserJob < ActiveRecord::Base
  @queue = :user_job
  
  def self.perform(params)
    begin
      puts "user job!"
      facebook_access_token = params['facebook_access_token']
      udid = params['udid']
      facebook_id = params['facebook_id']
      facebook_name = params['facebook_name']
      facebook_can_publish = params['facebook_can_publish']
      created_at = Time.now.utc.to_s(:db)
      updated_at = Time.now.utc.to_s(:db)

      query = "
        INSERT INTO users (udid, facebook_access_token, facebook_id, facebook_name, facebook_can_publish, created_at, updated_at) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE udid = ?, facebook_access_token = ?, facebook_can_publish = ?, updated_at = ?
      "
      qresult = self.execute_sql([query, udid, facebook_access_token, facebook_id, facebook_name, facebook_can_publish, created_at, updated_at, udid, facebook_access_token, facebook_can_publish, updated_at])
    rescue => e
      puts e.inspect
    end
  end
  
  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end
  
end