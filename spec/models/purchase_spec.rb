# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Purchase, type: :model do
  describe '購入の保存' do
    let(:seller) { FactoryBot.create(:user) }
    let(:buyer) { FactoryBot.create(:user) }
    let(:item) { FactoryBot.create(:item, user: seller) }

    context '保存できるとき' do
      it 'user と item が揃っていれば保存できること' do
        purchase = FactoryBot.build(:purchase, user: buyer, item: item)
        expect(purchase).to be_valid
        expect { purchase.save! }.to change(described_class, :count).by(1)
      end
    end

    context '保存できないとき' do
      it 'user がないと保存できないこと' do
        purchase = FactoryBot.build(:purchase, user: nil, item: item)
        expect(purchase).not_to be_valid
        purchase.valid?
        expect(purchase.errors[:user]).to include('must exist')
      end

      it 'item がないと保存できないこと' do
        purchase = FactoryBot.build(:purchase, user: buyer, item: nil)
        expect(purchase).not_to be_valid
        purchase.valid?
        expect(purchase.errors[:item]).to include('must exist')
      end

      it '同じ item に purchase が既にあると2件目は保存できないこと' do
        FactoryBot.create(:purchase, user: buyer, item: item)
        other_buyer = FactoryBot.create(:user)
        dup = FactoryBot.build(:purchase, user: other_buyer, item: item)
        expect { dup.save! }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
