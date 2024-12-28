require 'sinatra'
require 'json'
require 'dotenv/load'

require "sinatra/reloader"

set :port, 3000
set :environment, ENV['RACK_ENV']

configure :development do
  enable :reloader
end

get '/' do
  'Hello world!!'
end