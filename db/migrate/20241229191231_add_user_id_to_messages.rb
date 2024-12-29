# frozen_string_literal: true

class AddUserIdToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :user_id, :string
  end
end