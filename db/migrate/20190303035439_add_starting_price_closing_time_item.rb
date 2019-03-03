# frozen_string_literal: true

class AddStartingPriceClosingTimeItem < ActiveRecord::Migration[5.2]
  def change
    remove_column :items, :price
    add_column :items, :starting_price, :integer, null: false, default: 1
    add_column :items, :final_price, :integer
    add_column :items, :closes_at, :timestamp
  end
end
