class CommandHandler
  REGISTERED_COMMANDS = ['RESET_HISTORY', 'DEBUG_HISTORY']

  def self.is_command?(message)
    REGISTERED_COMMANDS.include?(message)
  end

  def self.handle_command(message, user_id)
    case message
    when 'RESET_HISTORY'
      reset_history(user_id)
    when 'DEBUG_HISTORY'
      debug_history(user_id)
    end
  end

  def self.reset_history(user_id)
    Message.where(role: 'user', user_id: user_id).delete_all
    Message.where(role: 'assistant', user_id: user_id).delete_all
    puts 'History has been reset'
  end

  def self.debug_history(user_id)
    user_messages = Message.where(user_id: user_id)
    system_message = Message.find_by(role: 'system')
    all_messages = [system_message] + user_messages
    SlackBot.send_debug_message(all_messages)
    puts 'Debug message sent'
  end
end