# frozen_string_literal: true

class CreateMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :memberships, id: false do |t|
      t.integer :auction_id, foreign_key: true, null: false
      t.integer :user_id, foreign_key: true, null: false
    end

    add_index :memberships, :auction_id
    add_index :memberships, :user_id
  end
end
