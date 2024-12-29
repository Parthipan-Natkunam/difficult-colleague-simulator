# frozen_string_literal: true

require 'httparty'
require 'json'
require 'dotenv/load'

class SlackBot
  WEBHOOK_URL = ENV['SLACK_WEBHOOK_URL']

  def self.send_message(message, parent_message_id)
    message_to_send = message || 'Sorry, I couldn\'t understand that, could you please rephrase it?'
    HTTParty.post(
      WEBHOOK_URL,
      body: { text: message_to_send, thread_ts: parent_message_id }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end
