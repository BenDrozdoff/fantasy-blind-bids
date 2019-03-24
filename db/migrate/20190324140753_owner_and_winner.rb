# frozen_string_literal: true

class OwnerAndWinner < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :owner_id, :integer, foreign_key: true, null: false
    add_column :items, :winner_id, :integer, foreign_key: true
    add_column :items, :status, :integer, default: 0
    remove_column :items, :state
  end
end
