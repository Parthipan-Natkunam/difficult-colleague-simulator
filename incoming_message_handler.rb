# frozen_string_literal: true

class IncomingMessageHandler
  def self.get_event_type(payload)
    payload['event']['type']
  end

  def self.is_bot_message(payload)
    !payload['event']['subtype'].nil?
  end

  def self.get_parent_message_id(payload)
    payload['event']['ts']
  end

  def self.get_user_id(payload)
    payload['event']['user']
  end

  def self.get_message(payload)
    full_text = payload['event']['text']
    full_text&.gsub(/<@.*>/, '')&.strip
  end
end
