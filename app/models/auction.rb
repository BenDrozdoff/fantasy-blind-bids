# frozen_string_literal: true

class Auction < ApplicationRecord
  has_many :items, dependent: :destroy
  has_and_belongs_to_many :users, join_table: :memberships
end
