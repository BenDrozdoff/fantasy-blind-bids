# frozen_string_literal: true

class CreateAuctions < ActiveRecord::Migration[5.2]
  def change
    create_table :auctions do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :auctions, :name, unique: true
  end
end
