# frozen_string_literal: true

class BidReporter
  UnexpectedBidState = Class.new(StandardError)
  delegate :name, :owner, :starting_price, :winner, :final_price, :current_high_bidders,
           :current_high_bidder, :current_high_bid, :closes_at, to: :item

  attr_reader :item
  def initialize(item)
    @item = item
  end

  def self.report(item)
    new(item).report
  end

  def no_bids_made
    "You can put it on the board! No bids made for #{name}, remains with #{owner.full_name} for $#{starting_price}."
  end

  def single_winner
    "#{reported_winner.full_name} wins #{name} for $#{final_price}."
  end

  def tied
    "You've got to be bleepin kidding me! "\
    "#{current_high_bidders.map(&:full_name).join(' and ')} tied on #{name} for $#{current_high_bid}."
  end

  def pending_match
    "#{owner.full_name} has 3 hours to match."
  end

  def matched
    "#{owner.full_name} has matched #{name} for $#{final_price}. Dagnabbit!"
  end

  def not_matched
    "#{owner.full_name} has chosen not to match. He gone!"
  end

  def report
    if item.bids.none?
      no_bids_made
    elsif item.pending_match? && item.currently_tied?
      [tied, pending_match].join(" ")
    elsif item.pending_match?
      [single_winner, pending_match].join(" ")
    elsif item.expired? && item.matched?
      matched
    elsif item.expired? && !item.matched? && !item.tied?
      [single_winner, not_matched].join(" ")
    elsif item.tied?
      [tied, not_matched].join(" ")
    else
      raise UnexpectedBidState.new(item.id)
    end
  end

  private

  def reported_winner
    winner || current_high_bidder
  end
end
