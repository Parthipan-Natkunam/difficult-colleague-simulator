# frozen_string_literal: true

require 'httparty'
require 'json'
require 'dotenv/load'

class OllamaConnector
  OLLAMA_SERVER_URL = ENV['OLLAMA_URL']
  AI_MODEL = ENV['AI_MODEL']

  @@message_history = [
    {
      role: 'system',
      content: 'You are a colleague of the user who disagrees a lot. Role play this conversation.'
    }
  ]

  def self.send_message(message)
    add_to_history(message, 'user')
    body_payload = build_body(message)
    puts "Sending message: #{body_payload}"
    response = HTTParty.post(
      OLLAMA_SERVER_URL,
      body: body_payload,
      headers: { 'Content-Type' => 'application/json' },
      format: :json
    )
    if response['message'] && response['message']['content']
      add_to_history(message, 'assistant')
      return response['message']['content']
    end

    raise 'Invalid response from the Model'
  end

  private  
    def self.format_message(message)
      [
        *@@message_history,
      ]
    end

    def self.build_body(message)
      {
        model: AI_MODEL,
        stream: false,
        messages: format_message(message)
      }.to_json
    end

    def self.add_to_history(message, role)
      @@message_history << {
        role: role,
        content: message
      }
    end
end
