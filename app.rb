require 'thin'
require 'em-websocket'
require 'sinatra/base'

EM.run do
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
  end

  @clients = []

  # EventMachine - Ruby implementation of HTML5 websockets
  # don't understand why we need this and the JS - I think this is supposed to create the server and the JS line [host = "ws://localhost:3001";] just identifies it.
  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      @clients << ws
      P @clients
      ws.send "Connected to #{handshake.path}."
    end

    ws.onclose do
      ws.send "Closed."
      @clients.delete ws
    end

    ws.onmessage do |msg|
      puts "Received Message: #{msg}"
      @clients.each do |socket|
        socket.send msg
      end
    end
  end

  App.run! :port => 3000
end
