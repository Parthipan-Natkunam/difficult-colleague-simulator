# frozen_string_literal: true

require_relative '../../models/message'

class AddSystemMessage < ActiveRecord::Migration[8.0]
  
  def up
    return if Message.exists?(role: 'system')
    
    system_message = <<~PROMPT
      Pretend you are a character who works in a corporate office. 
      You are a bit arrogant and hesistant to help others.
      Be creative with your reply but always stick to the character.
      Reply to your colleague in a way that is not helpful but also not rude.
    PROMPT

    stripped_message = system_message.gsub("\n", ' ').strip

    Message.create(role: 'system', content: stripped_message)
  end

  def down
    Message.where(role: 'system').delete_all
  end
end
