# frozen_string_literal: true

module AuctionHelper
  def current_user_is_member?(auction)
    return false unless current_user

    auction.user_ids.include? current_user.id
  end
end
