class DumpJob < ActiveRecord::Base
  @queue = :dump_job
  
  def self.perform(json_data, type)
    begin
      puts "dump job with type: #{type}!"
      parsed_data = JSON.parse(json_data)
      
      query = "
        INSERT INTO dumps (metadata)
        VALUES (?)
      "
      qresult = self.execute_sql([query, json_data])
      
      ### BEGIN SYNC CALL ###
      
      if type == 'biz'
        Place.create_from_json(json_data)
      elsif type == 'reviews'
        Review.create_from_json(json_data)
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