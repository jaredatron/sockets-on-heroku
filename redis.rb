require 'redis'

NewRedisConnection = -> do
  if ENV.has_key? "REDISCLOUD_URL"
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    Redis.connect(
      :host => uri.host,
      :port => uri.port,
      :password => uri.password
    )
  else
    Redis.connect(db: 5)
  end
end
