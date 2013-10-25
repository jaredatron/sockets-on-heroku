require "faye/websocket"
require "sinatra"
require 'pry'

require Bundler.root.join('event_bus')

Server = lambda do |env|
  if SocketServer.websocket?(env)
    SocketServer.call(env)
  else
    WebServer.call(env)
  end
end

Events = EventBus.new do |msg|
  puts "SENDING MESSAGE TO MY SOCKETS: #{msg.inspect}"
  SocketServer::OPEN_SOCKETS.each{|s| s.send "Received message: #{event.data}" }
end



class SocketServer

  OPEN_SOCKETS = Set.new

  def self.websocket? env
    Faye::WebSocket.websocket?(env)
  end

  def self.call env
    new.call(env)
  end

  def call env
    ws = Faye::WebSocket.new(env)

    ws.on :open do |e|
      OPEN_SOCKETS.add ws
    end

    ws.on :close do |e|
      OPEN_SOCKETS.subtract [ws]
    end

    ws.on :message do |event|
      puts "Received message: #{event.data.inspect}"
      Events.send(event.data)
      # OPEN_SOCKETS.each{|s| s.send "Received message: #{event.data}" }
    end

    ws.rack_response
  end
end

class WebServer < Sinatra::Base

  get '/' do
    erb :index
  end

end
