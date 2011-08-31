uri = URI.parse("redis://redistogo:4b38763dd63cf2a4837d22f9d1e3b4f1@angler.redistogo.com:9353")
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)