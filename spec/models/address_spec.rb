# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  describe '保存' do
    let(:seller) { create(:user) }
    let(:buyer) { create(:user) }
    let(:item) { create(:item, user: seller) }
    let(:purchase) { create(:purchase, user: buyer, item: item) }

    context '必須項目が揃っている場合' do
      it '保存できること' do
        address = build(:address, purchase: purchase)
        expect(address).to be_valid
        expect { address.save! }.to change(described_class, :count).by(1)
      end
    end

    context 'purchase がない場合' do
      it '保存できないこと' do
        address = build(:address, purchase: nil)
        expect(address).not_to be_valid
        expect(address.errors[:purchase]).to include('must exist')
      end
    end
  end
end
