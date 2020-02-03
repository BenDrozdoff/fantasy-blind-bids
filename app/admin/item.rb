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
  filter :status, as: :select, collection: Item.statuses

  member_action :match, method: :put do
    return head :unauthorized unless current_user.id == resource.owner_id

    resource.match!
    flash[:success] = "#{resource.name} matched for $#{resource.final_price}"
    redirect_to request.referer
  end

  member_action :expire, method: :put do
    return head :unauthorized unless current_user.id == resource.owner_id

    resource.expire!
    flash[:success] = "Declined match for #{resource.name}"
    redirect_to request.referer
  end
end
