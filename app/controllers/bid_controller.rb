# frozen_string_literal: true

class BidController < ApplicationController
  def create
    Bid.create(user: current_user, item_id: params[:item_id], value: bid_value)
    redirect_back fallback_location: "/"
  end

  def update
    Bid.find(params[:bid_id]).update!(value: bid_value)
    redirect_back fallback_location: "/"
  end

  def destroy
    Bid.find(params[:bid_id]).destroy!
    redirect_back fallback_location: "/"
  end

  private

  def bid_value
    params[:bid][:value].to_i
  end
end
