require 'thin'
require 'sinatra/base'
require 'em-websocket'

EM.run do
	class App < Sinatra::Base
		get '/' do
			erb :index
		end
	end

	@clients = []

	EM::WebSocket.start(host: '0.0.0.0', port: '3001') do |ws|
		ws.onopen do |handshake|
			@clients << ws
			ws.send "Connected to #{handshake.path}"
		end

		ws.onclose do |handshake|
			ws.send "Closed."
			@clients.delete(ws)
		end

		ws.onmessage do |msg|
			puts "Received Message: #{msg}"
			@clients.each do |socket|
				socket.send(msg)
			end
		end
		# run Sinatra server
	end
	# probably need to move this up to "run Sinatra server" line
	App.run! port: 3000
end