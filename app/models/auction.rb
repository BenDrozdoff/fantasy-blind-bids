# frozen_string_literal: true

class Auction < ApplicationRecord
  has_many :items, dependent: :destroy
end
