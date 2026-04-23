# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderForm, type: :model do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }
  let(:item) { create(:item, user: seller) }

  let(:valid_attributes) do
    {
      postal_code: '123-4567',
      prefecture_id: 1,
      city: '渋谷区',
      street: '神南1-1-1',
      building: 'テストビル',
      phone_number: '09012345678',
      user_id: buyer.id,
      item_id: item.id,
      token: 'tok_test_dummy_value_for_validation'
    }
  end

  describe 'バリデーション' do
    subject(:form) { described_class.new(valid_attributes) }

    context '内容に問題ない場合' do
      it '有効であること' do
        expect(form).to be_valid
      end

      it '建物名が空でも有効であること' do
        form.building = ''
        expect(form).to be_valid
      end
    end

    context '郵便番号が空の場合' do
      before { form.postal_code = '' }

      it '無効であること' do
        form.valid?
        expect(form.errors[:postal_code]).to include('を入力してください')
      end
    end

    context '郵便番号がハイフンなしの場合' do
      before { form.postal_code = '1234567' }

      it '無効であること' do
        form.valid?
        expect(form.errors[:postal_code]).to include('は「3桁ハイフン4桁」の半角数字のみ入力してください（例: 123-4567）')
      end
    end

    context '都道府県が未選択の場合' do
      before { form.prefecture_id = nil }

      it '無効であること' do
        form.valid?
        expect(form.errors[:prefecture_id]).to include('を選択してください')
      end
    end

    context '市区町村が空の場合' do
      before { form.city = '' }

      it '無効であること' do
        form.valid?
        expect(form.errors[:city]).to include('を入力してください')
      end
    end

    context '番地が空の場合' do
      before { form.street = '' }

      it '無効であること' do
        form.valid?
        expect(form.errors[:street]).to include('を入力してください')
      end
    end

    context '電話番号が空の場合' do
      before { form.phone_number = '' }

      it '無効であること' do
        form.valid?
        expect(form.errors[:phone_number]).to include('を入力してください')
      end
    end

    context '電話番号にハイフンが含まれる場合' do
      before { form.phone_number = '090-1234-5678' }

      it '無効であること' do
        form.valid?
        expect(form.errors[:phone_number]).to include('は10桁以上11桁以内の半角数字のみ入力してください（例: 09012345678、ハイフンなし）')
      end
    end

    context '電話番号が9桁の場合' do
      before { form.phone_number = '090123456' }

      it '無効であること' do
        form.valid?
        expect(form.errors[:phone_number]).to include('は10桁以上11桁以内の半角数字のみ入力してください（例: 09012345678、ハイフンなし）')
      end
    end

    context 'トークンが空の場合' do
      before { form.token = '' }

      it '無効であること' do
        form.valid?
        expect(form.errors[:token]).to include('を入力してください')
      end
    end

    context '出品者が自分の商品を買おうとする場合' do
      subject(:form) { described_class.new(valid_attributes.merge(user_id: seller.id)) }

      it '無効であること' do
        form.valid?
        expect(form.errors[:base]).to include('自分の商品は購入できません')
      end
    end

    context '売り切れ商品の場合' do
      before { create(:purchase, user: buyer, item: item) }

      subject(:form) { described_class.new(valid_attributes.merge(user_id: create(:user).id)) }

      it '無効であること' do
        form.valid?
        expect(form.errors[:base]).to include('売り切れです')
      end
    end

    context '存在しない商品 id の場合' do
      subject(:form) { described_class.new(valid_attributes.merge(item_id: 0)) }

      it '無効であること' do
        form.valid?
        expect(form.errors[:base]).to include('商品が見つかりません')
      end
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(valid_attributes) }

    it 'true を返し Purchase と Address が1件ずつ作成されること' do
      saved = nil
      expect do
        saved = form.save
      end.to change(Purchase, :count).by(1).and change(Address, :count).by(1)
      expect(saved).to be true

      purchase = Purchase.order(:id).last
      expect(purchase.user_id).to eq(buyer.id)
      expect(purchase.item_id).to eq(item.id)
      expect(purchase.address).to be_present
      expect(purchase.address.postal_code).to eq('123-4567')
    end

    context '無効な入力の場合' do
      before { form.postal_code = 'invalid' }

      it 'false を返し Purchase を増やさないこと' do
        expect(form.save).to be false
        expect(form).not_to be_valid
      end
    end
  end
end
