# frozen_string_literal: true

class AuctionController < ApplicationController
  def show
    @auction = Auction.find(params[:auction_id])
  end

  def list
    @auctions = Auction.all
  end
end
