# frozen_string_literal: true

require 'httparty'
require 'json'
require 'dotenv/load'

class SlackBot
  def self.send_message(message, parent_message_id, type)
    message_to_send = message || 'Sorry, I couldn\'t understand that, could you please rephrase it?'

    payload = { text: message_to_send }
    payload[:thread_ts] = parent_message_id if type == 'app_mention'

    web_hook_url = type == 'app_mention' ? ENV['SLACK_MENTION_WEBHOOK_URL'] : ENV['SLACK_DM_WEBHOOK_URL']

    HTTParty.post(
      web_hook_url,
      body: payload.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end
