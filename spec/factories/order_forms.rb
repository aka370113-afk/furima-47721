# frozen_string_literal: true

FactoryBot.define do
  factory :order_form, class: 'OrderForm' do
    postal_code { '123-4567' }
    prefecture_id { 1 }
    city { '渋谷区' }
    street { '神南1-1-1' }
    building { 'テストビル' }
    phone_number { '09012345678' }
    token { 'tok_test_dummy_value_for_validation' }
  end
end
