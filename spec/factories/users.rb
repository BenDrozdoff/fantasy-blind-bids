# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:first_name) { |n| "test#{n}" }
    password { "password" }
    last_name { "user" }
  end
end
