# require 'faye/websocket'

# App = lambda do |env|
#   if Faye::WebSocket.websocket?(env)
#     ws = Faye::WebSocket.new(env)

#     ws.on :message do |event|
#       ws.send(event.data)
#     end

#     ws.on :close do |event|
#       p [:close, event.code, event.reason]
#       ws = nil
#     end

#     # Return async Rack response
#     ws.rack_response

#   else
#     # Normal HTTP request
#     [200, {'Content-Type' => 'text/plain'}, ['Hello']]
#   end
# end


require 'sinatra'
require 'faye/websocket'
require 'json'
Faye::WebSocket.load_adapter('thin')

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)

    ws.on :open do |e|
      puts "websocket connection open"
      timer = EM.add_periodic_timer(1) do
        begin
          ws.send(Time.now.to_s.to_json)
        rescue NoMethodError
          EM.cancel_timer(timer)
        end
      end
    end

    ws.on :close do |event|
      puts "websocket connection closed"
      ws = nil
    end

    # p ws.rack_response
    [200, {}, []]
  else
    if env["REQUEST_PATH"] == "/"
      [200, {}, [File.read('./index.html')]]
    else
      [404, {}, ['']]
    end
  end
end
