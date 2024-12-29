class IncomingMessageHandler
  def self.get_parent_message_id (payload)
    payload['event']['ts']
  end

  def self.get_message(payload)
    full_text = payload['event']['text']
    full_text.gsub(/<@.*>/, '').strip
  end
end