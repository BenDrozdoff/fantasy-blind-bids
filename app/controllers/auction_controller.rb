# frozen_string_literal: true

class AuctionController < ApplicationController
  def show
    @auction = Auction.find(params[:auction_id])
  end

  def list
    @auctions = Auction.all
  end

  def toggle_membership
    auction = Auction.find(params[:auction_id])
    if auction.user_ids.include? current_user.id
      auction.users.delete(current_user)
      redirect_to action: 'list'
    else
      auction.users.push current_user
      redirect_to action: 'show', auction_id: auction.id
    end
  end
end
