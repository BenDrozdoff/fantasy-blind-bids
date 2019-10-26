# frozen_string_literal: true

class ExpireItemJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    Item.find(item_id).expire!
  end
end
