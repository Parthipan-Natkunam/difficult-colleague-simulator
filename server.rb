# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'dotenv/load'

require 'sinatra/reloader'

require_relative 'ollama_connector'
require_relative 'incoming_message_handler'

set :port, ENV['PORT']
set :environment, ENV['RACK_ENV']

configure :development do
  enable :reloader
  also_reload 'ollama_connector.rb'
  after_reload do
    puts 'reloaded'
  end
end

post '/chat' do
  content_type :json
  data = JSON.parse(request.body.read)

  return { challenge: data['challenge'] }.to_json if data['challenge']

  begin
    parent_message_id = IncomingMessageHandler.get_parent_message_id(data)
    message = IncomingMessageHandler.get_message(data)
    bot_reply = OllamaConnector.send_message(message) if message && !message.empty?
    puts "Parent message id: #{parent_message_id}"
    puts "Message: #{message}"

    return { message: bot_reply }.to_json if bot_reply

    { error: 'No message to send' }.to_json
  rescue StandardError => e
    puts e
    status 500
    { error: e.message }.to_json
  end
end
