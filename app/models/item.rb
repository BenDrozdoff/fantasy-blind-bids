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
    bids.maximum(:value) || starting_price
  end

  def bid_count
    bids.length
  end

  def current_high_bidder
    bids.max_by(&:value)&.user || owner
  end

  def expire!
    with_lock do
      break unless active?

      update!(status: :expired, final_price: current_high_bid, winner: current_high_bidder)

      ResultsGroupmeWorker.perform_async(id)
    end
  end

  def bid_report
    BidReporter.new(self).report
  end

  private

  def schedule_expiration
    ExpireItemWorker.perform_at(closes_at, id)
  end

  BidReporter = Struct.new(:item) do
    def self.report(item)
      new(item).report
    end

    def no_bids_made
      "No bids made for #{item.name}, remains with #{item.owner.full_name} for $#{item.starting_price}"
    end

    def winner
      "#{item.winner} wins #{item.name} for $#{final_price}"
    end

    def report
      item.bids.any? ? winner : no_bids_made
    end
  end
end
