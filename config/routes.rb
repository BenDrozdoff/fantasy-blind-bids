# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'auction#list'
  get 'auction/:auction_id', to: 'auction#show'
  post 'auction/:auction_id/join', to: 'auction#toggle_membership', as: :join_auction
  post 'auction/:auction_id/leave', to: 'auction#toggle_membership', as: :leave_auction
  get 'bids', to: 'bid#show'
  post 'bid', to: 'bid#create'
  put 'bid/:bid_id', to: 'bid#update'
  delete 'bid/:bid_id', to: 'bid#destroy'
end
