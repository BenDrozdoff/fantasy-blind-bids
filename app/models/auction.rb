class Auction < ApplicationRecord
  has_many :items, dependent: :destroy
end
