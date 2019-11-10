# frozen_string_literal: true

class ResultsGroupmeJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.includes(:bids).find(item_id)
    GroupmeClient.post_message(item.bid_report)
  end
end
