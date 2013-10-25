require 'thin'
require './server'
$stdout.sync = true
Faye::WebSocket.load_adapter('thin')
run Server
