require 'websocket-eventmachine-client'
require 'pry'

module UnbufferedKeyboardHandler
  class << self
    attr_accessor :ws
  end
  def receive_data(buffer)

  end
  def anon
    Class.new
  end
end

EM.run do

  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://localhost:8080')

  ws.onopen do
    puts "Connected"
  end

  ws.onmessage do |msg, type|
    puts msg
  end

  ws.onclose do
    puts "Disconnected"
  end

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
