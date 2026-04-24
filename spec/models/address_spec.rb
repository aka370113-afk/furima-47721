# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  describe '住所の保存' do
    let(:seller) { FactoryBot.create(:user) }
    let(:buyer) { FactoryBot.create(:user) }
    let(:item) { FactoryBot.create(:item, user: seller) }
    let(:purchase) { FactoryBot.create(:purchase, user: buyer, item: item) }

    context '保存できるとき' do
      it '必須項目が揃っていれば保存できること' do
        address = FactoryBot.build(:address, purchase: purchase)
        expect(address).to be_valid
        expect { address.save! }.to change(described_class, :count).by(1)
      end
    end

    context '保存できないとき' do
      it 'purchase がないと保存できないこと' do
        address = FactoryBot.build(:address, purchase: nil)
        expect(address).not_to be_valid
        address.valid?
        expect(address.errors[:purchase]).to include('must exist')
      end
    end
  end
end
