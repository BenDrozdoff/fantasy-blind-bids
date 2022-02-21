# frozen_string_literal: true

class ResultsGroupmeWorker
  include Sidekiq::Worker

  def perform(item_id)
    item = Item.includes(:bids).find(item_id)
    item.with_lock do
      item.reload
      GroupmeClient.post_message(item.bid_report)
    end
  end
end
