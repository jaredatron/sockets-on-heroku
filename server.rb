
require "faye/websocket"
require "sinatra"
require 'redis'
require 'pry'

require Bundler.root.join('redis')

# Creating a thread for the redis subscribe block
Thread.new do
  redis = NewRedisConnection.call
  redis.subscribe('events') do |on|
    # When a message is published to 'ws'
    on.message do |_, message|
     puts "sending message: #{message}"
     # Send out the message on each open socket
     SocketServer::SOCKETS.each {|s| s.send message}
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

# Events = EventBus.new do |msg|
#   puts "SENDING MESSAGE TO MY SOCKETS: #{msg.inspect}"
#   SocketServer::SOCKETS.each{|s| s.send "Received message: #{event.data}" }
# end



class SocketServer

  SOCKETS = Set.new

  def self.websocket? env
    Faye::WebSocket.websocket?(env)
  end

  def self.call env
    new.call(env)
  end

  def redis
    @redis ||= NewRedisConnection.call
  end

  def call env
    ws = Faye::WebSocket.new(env)

    ws.on :open do |e|
      SOCKETS.add ws
    end

    ws.on :close do |e|
      SOCKETS.subtract [ws]
    end

    ws.on :message do |event|
      puts "Received message: #{event.data.inspect}"
      redis.publish 'events', event.data
      # Events.send(event.data)
      # SOCKETS.each{|s| s.send "Received message: #{event.data}" }
    end

    ws.rack_response
  end
end

class WebServer < Sinatra::Base

  get '/' do
    erb :index
  end

end
