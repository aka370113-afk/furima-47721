# frozen_string_literal: true

FactoryBot.define do
  factory :purchase do
    association :user
    association :item
  end
end
