# frozen_string_literal: true

class AddArbStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :arb_status, :string
  end
end
