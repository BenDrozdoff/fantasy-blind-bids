# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    auction
    association :owner, factory: :user
    sequence(:name) { |n| "Item #{n}" }
    closes_at { 3.days.from_now }

    trait :won do
      association :winner, factory: :user
      final_price { 15 }
      closes_at { 1.day.ago }
      status { "expired" }
    end
  end
end
