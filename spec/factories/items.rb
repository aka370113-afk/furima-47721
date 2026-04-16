# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    association :user, strategy: :create
    item_name { Faker::Commerce.product_name }
    item_info { Faker::Lorem.sentence }
    item_price { 300 }
    category_id { 1 }
    item_status_id { 1 }
    shipping_fee_status_id { 1 }
    prefecture_id { 1 }
    scheduled_delivery_id { 1 }

    after(:build) do |item|
      item.image.attach(
        io: File.open(Rails.root.join('public/images/test_image.png')),
        filename: 'test_image.png'
      )
    end
  end
end
