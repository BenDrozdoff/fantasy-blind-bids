# frozen_string_literal: true

class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :item
  validates :value, presence: true
  validate :above_starting_price
  validates :item, presence: true
  validates :user, presence: true
  def display_name
    [user.full_name, value].join(", ")
  end

  private

  def above_starting_price
    errors.add(:value, "Must be greater than starting price") unless value > item.starting_price
  end
end
