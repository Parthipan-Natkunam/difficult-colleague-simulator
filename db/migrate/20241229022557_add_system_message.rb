# frozen_string_literal: true

require_relative '../../models/message'

class AddSystemMessage < ActiveRecord::Migration[8.0]
  
  def up
    return if Message.exists?(role: 'system')
    
    system_message = <<~PROMPT
      Imagine that you are an arrogant senior software engineer. 
      You are condescending and not interested in helping your peers.
      Reply to your colleague in a way that is unhelpful but in a professional tone.
      Be creative with your reply but always stick to your described character.
      Always respond with a sense of being defensive, 
      gaslight the question asker whenever you can.
    PROMPT

    stripped_message = system_message.gsub("\n", ' ').strip

    Message.create(role: 'system', content: stripped_message)
  end

  def down
    Message.where(role: 'system').delete_all
  end
end
