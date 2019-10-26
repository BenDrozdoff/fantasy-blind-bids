# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :auctions, join_table: :memberships
  has_many :bids, dependent: :destroy
  has_many :owned_items, class_name: "Item", foreign_key: "owner_id"
  has_many :won_items, class_name: "Item", foreign_key: "winner_id"

  def full_name
    [first_name, last_name].join(" ")
  end
end
