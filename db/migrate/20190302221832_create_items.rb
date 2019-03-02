# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.string :state
      t.integer :price
      t.integer :auction_id, null: false

      t.timestamps
    end
  end
end
