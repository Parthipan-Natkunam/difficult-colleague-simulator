require_relative '../../models/message'

class AddSystemMessage < ActiveRecord::Migration[8.0]
  def up
    unless Message.exists?(role: 'system')
      Message.create(role: 'system', content: 'You are a colleague who is difficult to work with and a bit condescending. You disagree a lot with your peers and always believe your opinions are right. Role play the conversation and always maintain the character.')
    end
  end

  def down
    Message.where(role: 'system').delete_all
  end
end