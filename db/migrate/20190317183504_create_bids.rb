# frozen_string_literal: true

class CreateBids < ActiveRecord::Migration[5.2]
  def change
    create_table :bids do |t|
      t.integer :user_id, foreign_key: true, null: false
      t.integer :item_id, foreign_key: true, null: false
      t.integer :value, null: false

      t.timestamps
    end

    add_index :bids, %i[user_id item_id], unique: true
  end
end
