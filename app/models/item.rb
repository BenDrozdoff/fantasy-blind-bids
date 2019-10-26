# frozen_string_literal: true

class Item < ApplicationRecord
  enum status: %i(active expired)
  belongs_to :auction
  has_many :bids, dependent: :destroy
  belongs_to :owner, class_name: "User"
  belongs_to :winner, class_name: "User", optional: true
  validates :closes_at, presence: true
  scope :available_to_user, lambda { |user_id|
    active.includes(:bids).references(:bids).where(bids: { user_id: [nil, user_id] }).where.not(owner_id: user_id)
  }
  scope :active_belonging_to_user, lambda { |user_id|
                                     active.includes(bids: :user).where(owner_id: user_id).order("bids.value DESC")
                                   }
  after_save :schedule_expiration

  def winning_bid_value
    return unless expired?

    bids.maximum(:value)
  end

  def current_high_bid
    bids.maximum(:value)
  end

  def bid_count
    bids.length
  end

  def current_high_bidder
    bids.max_by(&:value)&.user
  end

  def expire!
    with_lock do
      break unless active?

      update!(status: :expired, final_price: current_high_bid, winner: current_high_bidder)
    end
  end

  private

  def schedule_expiration
    ExpireItemJob.set(wait_until: closes_at).perform_later(id)
  end
end
