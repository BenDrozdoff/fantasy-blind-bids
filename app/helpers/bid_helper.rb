# frozen_string_literal: true

module BidHelper
  def current_user_bid_value(item)
    bid = current_user_bid(item)
    return unless bid.present?

    number_to_currency(bid.value, precision: 0)
  end

  def current_user_bid(item)
    Bid.find_by(item: item, user: current_user)
  end
end
