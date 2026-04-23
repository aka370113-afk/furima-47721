# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    association :purchase
    postal_code { '123-4567' }
    prefecture_id { 1 }
    city { '渋谷区' }
    street { '神南1-2-3' }
    building { nil }
    phone_number { '09012345678' }
  end
end
