# frozen_string_literal: true

class AuctionController < ApplicationController
  before_action :validate_membership, only: :show

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

  private

  def validate_membership
    return if current_user && Auction.find(params[:auction_id]).user_ids.include?(current_user.id)

    flash[:alert] = 'You must join this auction to see this content'
    redirect_to action: 'list'
  end
end
