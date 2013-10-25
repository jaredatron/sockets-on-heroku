
require "faye/websocket"
require "sinatra"
require 'redis'

def new_redis_connection
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

Thread.new do
  new_redis_connection.subscribe('events') do |on|
    on.message do |_, event|
      message = {type: 'event', event: event}.to_json
      SocketServer.sockets.each{|ws| ws.send message}
    end
  end
end

Server = lambda do |env|
  if SocketServer.websocket?(env)
    SocketServer.call(env)
  else
    WebServer.call(env)
  end
end

module SocketServer

  def self.sockets
    @sockets ||= []
  end

  def self.websocket? env
    Faye::WebSocket.websocket?(env)
  end

  def self.redis
    @redis ||= new_redis_connection
  end

  def self.call env
    ws = Faye::WebSocket.new(env)

    ws.on :open do |e|
      sockets << ws
    end

    ws.on :close do |e|
      sockets.delete ws
    end

    ws.on :message do |frame|
      message = JSON.parse(frame.data)
      case message['type']
      when 'subscribe'

      when 'unsubscribe'

      when 'event'
        redis.publish 'events', message['event']
      end
    end

    ws.rack_response
  end

end

class WebServer < Sinatra::Base

  get '/' do
    erb :index
  end

end
