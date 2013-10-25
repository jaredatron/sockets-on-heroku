require 'redis'
require 'em-websocket'

SOCKETS = []

PORT = ARGV.shift || '5000'

# Creating a thread for the EM event loop
Thread.new do

  EventMachine.run do
    # Creates a websocket listener
    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => PORT) do |ws|
      ws.onopen do
        # When someone connects I want to add that socket to the SOCKETS array that
        # I instantiated above
        puts 'creating socket'
        SOCKETS << ws
      end

      ws.onclose do
        # Upon the close of the connection I remove it from my list of running sockets
        puts 'closing socket'
        SOCKETS.delete ws
      end

      ws.onmessage do |message|
        puts "publishing event #{message.inspect}"
        p Redis.new.publish 'events', message
        puts "done"
      end

    end
  end
end

# Creating a thread for the redis subscribe block
Thread.new do
  Redis.new.subscribe('events') do |on|
    # When a message is published to 'ws'
    on.message do |_, message|
     puts "sending message: #{message}"
     # Send out the message on each open socket
     SOCKETS.each {|s| s.send message}
    end
  end
end

sleep
