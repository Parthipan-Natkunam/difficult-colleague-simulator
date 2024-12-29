# frozen_string_literal: true

require 'httparty'
require 'json'
require 'dotenv/load'

require_relative 'models/message'

class OllamaConnector
  OLLAMA_SERVER_URL = ENV['OLLAMA_URL']
  AI_MODEL = ENV['AI_MODEL']

  def self.send_message(message)
    add_to_history(message, 'user')
    body_payload = build_body(message)
    puts "Body payload: #{body_payload}"
    response = HTTParty.post(
      OLLAMA_SERVER_URL,
      body: body_payload,
      headers: { 'Content-Type' => 'application/json' },
      format: :json
    )
    if response['message'] && response['message']['content']
      add_to_history(response['message']['content'], 'assistant')
      return response['message']['content']
    end

    raise 'Invalid response from the Model'
  end

  def self.format_message(_message)
    Message.all.map { |msg| { role: msg.role, content: msg.content } }
  end

  def self.build_body(message)
    {
      model: AI_MODEL,
      stream: false,
      messages: format_message(message)
    }.to_json
  end

  def self.add_to_history(message, role)
    Message.create(role: role, content: message)
  end
end
