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
      after :create do |item|
        create :bid, value: 15, item: item
      end
    end

    trait :pending_match do
      final_price { 15 }
      closes_at { 3.hours.from_now }
      status { "pending_match" }
      after(:create) do |item|
        create :bid, item: item, value: 15
      end
    end

    trait :pending_match_tied do
      pending_match
      after(:create) do |item|
        create :bid, item: item, value: 15
      end
    end

    trait :active_with_bid do
      after :create do |item|
        create :bid, item: item
      end
    end

    trait :active_tied do
      after :create do |item|
        create :bid, item: item, value: 15
        create :bid, item: item, value: 15
      end
    end

    trait :tied do
      closes_at { 1.day.ago }
      final_price { 15 }
      status { "tied" }
      after :create do |item|
        create :bid, item: item, value: 15
        create :bid, item: item, value: 15
      end
    end

    trait :matched do
      closes_at { 1.day.ago }
      final_price { 15 }
      winner { owner }
      status { "expired" }
      after :create do |item|
        create :bid, item: item, value: 15
      end
    end
  end
end
