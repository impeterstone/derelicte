# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Derelicte::Application.initialize!

Derelicte::Application.configure do
  
Mime::Type.register "gzip/json", :gzipjson
  config.middleware.delete "ActionDispatch::ParamsParser"
  config.middleware.use ActionDispatch::ParamsParser , {Mime::GZIPJSON => Proc.new {|raw_request | data = ActiveSupport::JSON.decode(ActiveSupport::Gzip.decompress(raw_request)); data = {:_json => data} unless data.is_a?(Hash)   ;  data.with_indifferent_access}}
end