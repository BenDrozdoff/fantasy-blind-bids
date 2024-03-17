# frozen_string_literal: true

class Auction < ApplicationRecord
  has_many :items, dependent: :destroy
  has_and_belongs_to_many :users, join_table: :memberships

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["items"]
  end
end
