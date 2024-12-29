# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'dotenv/load'

require 'sinatra/reloader'
require 'sinatra/activerecord'

require_relative 'ollama_connector'
require_relative 'incoming_message_handler'
require_relative 'slack_bot'

require_relative 'middlewares/slack_signature_verification'

use SlackSignatureVerification

set :port, ENV['PORT']
set :environment, :production
set :database, { adapter: 'sqlite3', database: ENV['DATABASE_URL'] }

configure :development do
  enable :reloader
  also_reload 'ollama_connector.rb'
  after_reload do
    puts 'reloaded'
  end
end

post '/chat' do
  content_type :json
  
  request.body.rewind
  
  data = JSON.parse(request.body.read)

  return { challenge: data['challenge'] }.to_json if data['challenge']

  begin
    message = IncomingMessageHandler.get_message(data)
    event_type = IncomingMessageHandler.get_event_type(data)
    is_bot_message = IncomingMessageHandler.is_bot_message(data)

    unless is_bot_message
      user_id = IncomingMessageHandler.get_user_id(data)

      if message == 'RESET_HISTORY'
        Message.where(role: 'user', user_id: user_id).delete_all
        Message.where(role: 'assistant', user_id: user_id).delete_all
        puts 'History has been reset'
        status 200
        return
      end

      if message == 'DEBUG_HISTORY'
        user_messages = Message.where(user_id: user_id)
        system_message = Message.find_by(role: 'system')
        all_messages = [system_message] + user_messages
        SlackBot.send_debug_message(all_messages)
        puts 'Debug message sent'
        status 200
        return
      end

      if message && !message.empty?
        parent_message_id = IncomingMessageHandler.get_parent_message_id(data)
        bot_reply = OllamaConnector.send_message(message, user_id)
        sent_status = SlackBot.send_message(bot_reply, parent_message_id, event_type) if bot_reply
        puts "AI reply: #{bot_reply}" if bot_reply
        puts "SLACK BOT Message Status [#{event_type}]: #{sent_status}" if sent_status
      end
    end

    status 200
  rescue StandardError => e
    puts e
    status 500
    { error: e.message }.to_json
  end
end
