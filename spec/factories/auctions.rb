# frozen_string_literal: true

FactoryBot.define do
  factory :auction do
    sequence(:name) { |n| "Auction #{n}" }
  end
end
