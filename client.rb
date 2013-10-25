require 'websocket-eventmachine-client'
require 'pry'

# SERVER_URI = 'http://safe-peak-6565.herokuapp.com/'
SERVER_URI = 'ws://localhost:5001'

EM.run do

  ws = nil

  connect = -> do
    ws = WebSocket::EventMachine::Client.connect(:uri => SERVER_URI)

    ws.onopen do
      puts "Connected"
    end

    ws.onmessage do |msg, type|
      puts msg
    end

    ws.onclose do
      puts "Disconnected"
      EventMachine.next_tick do
        connect.()
      end
    end

  end

  connect.()

  # EventMachine.next_tick do
  #   ws.send "Hello Server!"
  # end

  buffer = []
  receive_data = -> char do
    if char == "\n"
      ws.send buffer.join
      buffer.clear
    else
      buffer.push char
    end
  end

  EM.open_keyboard(Module.new{define_method(:receive_data, receive_data)})

end
