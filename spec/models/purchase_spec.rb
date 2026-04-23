# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Purchase, type: :model do
  describe 'アソシエーション・保存' do
    let(:seller) { create(:user) }
    let(:buyer) { create(:user) }
    let(:item) { create(:item, user: seller) }

    context 'user と item が揃っている場合' do
      it '保存できること' do
        purchase = build(:purchase, user: buyer, item: item)
        expect(purchase).to be_valid
        expect { purchase.save! }.to change(described_class, :count).by(1)
      end
    end

    context 'user がない場合' do
      it '保存できないこと' do
        purchase = build(:purchase, user: nil, item: item)
        expect(purchase).not_to be_valid
        expect(purchase.errors[:user]).to include('must exist')
      end
    end

    context 'item がない場合' do
      it '保存できないこと' do
        purchase = build(:purchase, user: buyer, item: nil)
        expect(purchase).not_to be_valid
        expect(purchase.errors[:item]).to include('must exist')
      end
    end

    context '同じ item に対して purchase を2件作ろうとする場合' do
      before { create(:purchase, user: buyer, item: item) }

      it '2件目は一意制約で保存できないこと' do
        other_buyer = create(:user)
        dup = build(:purchase, user: other_buyer, item: item)
        expect { dup.save! }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
