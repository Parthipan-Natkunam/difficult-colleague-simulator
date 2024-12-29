# frozen_string_literal: true

require 'httparty'
require 'json'
require 'dotenv/load'

require_relative 'models/message'

class OllamaConnector
  OLLAMA_SERVER_URL = ENV['OLLAMA_URL']
  AI_MODEL = ENV['AI_MODEL']

  def self.send_message(message, user_id)
    add_to_history(message, 'user', user_id)
    body_payload = build_body(message, user_id)

    response = HTTParty.post(
      OLLAMA_SERVER_URL,
      body: body_payload,
      headers: { 'Content-Type' => 'application/json' },
      format: :json
    )
    if response['message'] && response['message']['content']
      add_to_history(response['message']['content'], 'assistant', user_id)
      return response['message']['content']
    end

    raise 'Invalid response from the Model'
  end

  def self.format_message(_user_id)
    system_message = Message.find_by(role: 'system')
    user_chat = Message.where(user_id: _user_id)
    [system_message] + user_chat.map { |msg| { role: msg.role, content: msg.content } }
  end

  def self.build_body(_message, user_id)
    {
      model: AI_MODEL,
      stream: false,
      messages: format_message(user_id)
    }.to_json
  end

  def self.add_to_history(_message, _role, user_id = nil)
    Message.create(content: _message, role: _role, user_id: user_id)
  end
end
