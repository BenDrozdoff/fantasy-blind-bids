# frozen_string_literal: true

ActiveAdmin.register Auction do
  permit_params :name
  controller do
    actions :index, :show
  end

  action_item :expired_items, only: :show do
    link_to "Expired Items", admin_items_path(q: { status_eq: 1 })
  end

  show do
    tabs do
      tab "Available Items", id: :available_items do
        paginated_collection(
          resource.items.available_to_user(current_user.id).order(:closes_at).page(params[:page]).per(15)
        ) do
          table_for collection do
            column :name
            column :starting_price
            column :my_bid do |item|
              item.bids.select { |bid| bid.user_id == current_user.id }.first&.value
            end
            column :closes_at
            column :action do |item|
              div do
                if item.bids.select { |bid| bid.user_id == current_user.id }.empty?
                  form_for :bid, url: admin_bids_path do |f|
                    f.number_field :value
                    f.hidden_field :item_id, value: item.id
                    f.submit :bid
                  end
                else
                  form_for :bid, url: admin_bid_path(item.bids.first.id), html: { method: :patch } do |f|
                    f.number_field :value, value: item.bids.select { |bid| bid.user_id == current_user.id }.first&.value
                    f.submit "Update Bid"
                  end
                end
              end
            end
            column :owner
          end
        end
      end
      tab "Pending Match", id: :pending_match do
        table_for resource.items.available_to_match(current_user.id) do
          column :name
          column :starting_price
          column :final_price
          column :current_high_bidder
          column :bids
          column :action do |item|
            form_for(:item, url: match_admin_item_path(item), method: :put) do |f|
              f.submit "Match for $#{item.final_price}"
            end
          end
        end
      end
      tab "My Items", id: :my_items do
        table_for resource.items.active_belonging_to_user(current_user.id) do
          column :name
          column :starting_price
          column :closes_at
          column :bid_count
          column :current_high_bid
          column :current_high_bidder
          column :bids
        end
      end
      tab "Won Items", id: :won_items do
        table_for resource.items.where(winner: current_user) do
          column :name
          column :final_price
          column :closes_at
          column :owner
        end
      end
    end
  end

  filter :name
end
