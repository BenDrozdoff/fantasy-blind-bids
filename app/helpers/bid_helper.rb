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

  def belongs_to_current_user?(_item)
    Item.first.owner.id == current_user.id
  end

  def owner_name(item)
    return 'Me' if belongs_to_current_user?(item)

    item.owner.full_name
  end
end
