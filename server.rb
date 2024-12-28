require 'sinatra'
require 'json'
require 'dotenv/load'

require "sinatra/reloader"

set :port, 3000
set :environment, ENV['RACK_ENV']

configure :development do
  enable :reloader
end

post '/chat' do
  content_type :json
  request_payload = JSON.parse(request.body.read)
  status 200
  puts request_payload
end