# frozen_string_literal: true

class Item < ApplicationRecord
  enum status: %i[active expired]
  belongs_to :auction
  has_many :bids, dependent: :destroy
  belongs_to :owner, class_name: 'User'
  belongs_to :winner, class_name: 'User', optional: true
end
