# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'dotenv/load'

require 'sinatra/reloader'

require_relative 'ollama_connector'

set :port, 3000
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
    bot_reply = OllamaConnector.send_message(data['message'])
    { message: bot_reply }.to_json
  rescue StandardError => e
    puts e
    status 500
    { error: e.message }.to_json
  end
end
