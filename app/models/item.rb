# frozen_string_literal: true

class Item < ApplicationRecord
  enum status: %i(active expired pending_match tied)
  enum arb_status: { arb_1: "arb_1", arb_2: "arb_2", arb_3: "arb_3" }
  belongs_to :auction
  has_many :bids, dependent: :destroy
  belongs_to :owner, class_name: "User"
  belongs_to :winner, class_name: "User", optional: true
  validates :closes_at, presence: true
  scope :available_to_user, lambda { |user_id|
    active.includes(:bids, :owner).where.not(owner_id: user_id)
  }
  scope :available_to_match, lambda { |user_id|
    pending_match.includes(:bids).where(owner_id: user_id).order("bids.value DESC")
  }
  scope :active_belonging_to_user, ->(user_id) { active.includes(bids: :user).where(owner_id: user_id) }
  scope :won_by_user, ->(user_id) { expired.where(winner_id: user_id).includes(:owner, :winner) }

  delegate :name, to: :auction, prefix: true

  def self.ransackable_attributes(auth_object = nil)
    ["name", "owner_id", "winner_id", "starting_price", "final_price", "status", "arb_status"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["auction", "bids", "owner", "winner"]
  end

  def current_high_bid
    bids.maximum(:value) || starting_price
  end

  def bid_count
    bids.length
  end

  def current_high_bidders
    return [owner] unless bids.any?

    bids.where(value: current_high_bid).map(&:user)
  end

  def current_high_bidder
    current_high_bidders.first if current_high_bidders.count == 1
  end

  def currently_tied?
    !current_high_bidder.is_a? User
  end

  def matching_price
    return final_price unless arb_status.present?

    rate = case arb_status
           when "arb_2"
             0.25
           when "arb_3"
             0.5
           end
    (final_price.to_f * rate).ceil
  end

  def match!
    with_lock do
      break unless pending_match?

      update(status: :expired, closes_at: Time.now, winner: owner, final_price: matching_price)
    end
    ResultsGroupmeWorker.new.perform(id)
  end

  def matched?
    winner_id == owner_id && bids.any?
  end

  def expire!
    with_lock do
      break unless (active? && closes_at <= Time.now.utc) || pending_match?

      if active?
        expire_active!
      elsif pending_match?
        currently_tied? ? tie! : decline_match!
      end

      ResultsGroupmeWorker.new.perform(id)
    end
  end

  def bid_report
    BidReporter.report(self)
  end

  private

  def expire_active!
    if bids.none?
      update!(status: :expired, final_price: starting_price, winner: current_high_bidder)
    else
      update!(status: :pending_match, closes_at: 3.hours.from_now, final_price: current_high_bid)
    end
  end

  def tie!
    update!(status: :tied)
  end

  def decline_match!
    update!(status: :expired, winner: current_high_bidder)
  end
end
