# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'abc123' }
    password_confirmation { 'abc123' }
    sequence(:nickname) { |n| "nick#{n}" }
    family_name_kanji { '山田' }
    given_name_kanji { '太郎' }
    family_name_kana { 'ヤマダ' }
    given_name_kana { 'タロウ' }
    birth_date { Date.new(1990, 1, 1) }
  end
end
