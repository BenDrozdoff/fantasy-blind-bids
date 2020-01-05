# frozen_string_literal: true

class ExpireItemWorker
  include Sidekiq::Worker

  def perform(item_id)
    Item.find(item_id).expire!
  end
end
