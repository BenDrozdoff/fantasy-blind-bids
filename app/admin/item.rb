# frozen_string_literal: true

ActiveAdmin.register Item do
  menu false
  controller do
    actions :index
  end
  index do
    column :name
    column :winner
    column :starting_price
    column :final_price
    column :closes_at
  end

  filter :owner
  filter :winner
  filter :name
  filter :starting_price
  filter :final_price
  filter :status
end
