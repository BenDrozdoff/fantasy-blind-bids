# frozen_string_literal: true

ActiveAdmin.register Bid do
  menu false
  permit_params :value, :item_id
  before_create { @bid.user = current_user }
  controller do
    actions :update, :create, :destroy
    def create
      super do |success, failure|
        success.html { redirect_to admin_auction_path(@bid.item.auction) }
        failure.html do
          redirect_to admin_auction_path(@bid.item.auction), flash: { error: @bid.errors.values.join(", ") }
        end
      end
    end

    def update
      super do |success, failure|
        success.html { redirect_to admin_auction_path(@bid.item.auction) }
        failure.html do
          redirect_to admin_auction_path(@bid.item.auction), flash: { error: @bid.errors.values.join(",") }
        end
      end
    end

    def destroy
      super do |success, failure|
        success.html { redirect_to admin_auction_path(@bid.item.auction) }
        failure.html do
          redirect_to admin_auction_path(@bid.item.auction), flash: { error: @bid.errors.values.join(",") }
        end
      end
    end
  end
end
