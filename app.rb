require 'thin'
require 'sinatra/base'
require 'em-websocket'

EventMachine.run do
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
  end
  @clients = []

  # EM::WebSocket.run(:host => "0.0.0.0", :port => 3001) do |ws|
  #   ws.onopen { |handshake|
  #     puts "WebSocket connection open"

  #     # Access properties on the EM::WebSocket::Handshake object, e.g.
  #     # path, query_string, origin, headers

  #     # Publish message to the client
  #     ws.send "Hello Client, you connected to #{handshake.path}"
  #   }

  #   ws.onclose { puts "Connection closed" }

  #   ws.onmessage { |msg|
  #     puts "Recieved message: #{msg}"
  #     ws.send "Pong: #{msg}"
  #   }
  # end
  EM::WebSocket.start(:host => '0.0.0.0', :post => '3001') do |ws|
    ws.onopen do |handshake|
      @clients << ws
      puts "WebSocket Connection open"
      ws.send "Connected to #{handshake.path}."
    end

    ws.onclose do 
      ws.send "closed."
      @clients.delete ws
    end

    ws.onmessage do |msg|
      puts "Received Message: #{msg}"
      @clients.each do |socket|
        socket.send msg
      end
    end
  end
  # our WebSockets server logic will go here

  App.run! :port => 3000

end

