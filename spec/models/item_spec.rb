# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  describe '商品出品' do
    before do
      @item = FactoryBot.build(:item)
    end

    context '出品できるとき' do
      it '全ての項目が正しく入力されていれば保存できること' do
        expect(@item).to be_valid
      end
    end

    context '出品できないとき' do
      it 'ユーザーが紐づいていないと保存できないこと' do
        @item.user_id = nil
        @item.valid?
        expect(@item.errors[:user]).to include('must exist')
      end

      it '商品画像が空では保存できないこと' do
        @item.image.purge
        @item.valid?
        expect(@item.errors[:image]).to include("can't be blank")
      end

      it '商品名が空では保存できないこと' do
        @item.item_name = ''
        @item.valid?
        expect(@item.errors[:item_name]).to include("can't be blank")
      end

      it '商品の説明が空では保存できないこと' do
        @item.item_info = ''
        @item.valid?
        expect(@item.errors[:item_info]).to include("can't be blank")
      end

      it 'カテゴリーが空では保存できないこと' do
        @item.category_id = nil
        @item.valid?
        expect(@item.errors[:category_id]).to include("can't be blank")
      end

      it '商品の状態が空では保存できないこと' do
        @item.item_status_id = nil
        @item.valid?
        expect(@item.errors[:item_status_id]).to include("can't be blank")
      end

      it '配送料の負担が空では保存できないこと' do
        @item.shipping_fee_status_id = nil
        @item.valid?
        expect(@item.errors[:shipping_fee_status_id]).to include("can't be blank")
      end

      it '発送元の地域が空では保存できないこと' do
        @item.prefecture_id = nil
        @item.valid?
        expect(@item.errors[:prefecture_id]).to include("can't be blank")
      end

      it '発送までの日数が空では保存できないこと' do
        @item.scheduled_delivery_id = nil
        @item.valid?
        expect(@item.errors[:scheduled_delivery_id]).to include("can't be blank")
      end

      it '価格が空では保存できないこと' do
        @item.item_price = nil
        @item.valid?
        expect(@item.errors[:item_price]).to include("can't be blank")
      end

      it '価格に半角数字以外が含まれると保存できないこと' do
        allow(@item).to receive(:read_attribute_before_type_cast).and_wrap_original do |method, attr|
          attr == :item_price ? '300a' : method.call(attr)
        end
        @item.valid?
        expect(@item.errors[:item_price]).to include('は半角数値で入力してください')
      end

      it '価格が300円未満では保存できないこと' do
        @item.item_price = 299
        @item.valid?
        expect(@item.errors[:item_price]).to include('must be greater than or equal to 300')
      end

      it '価格が9,999,999円を超えると保存できないこと' do
        @item.item_price = 10_000_000
        @item.valid?
        expect(@item.errors[:item_price]).to include('must be less than or equal to 9999999')
      end
    end
  end

  describe '#sold?' do
    let(:seller) { create(:user) }
    let(:item) { create(:item, user: seller) }

    context 'purchase がない場合' do
      it 'false を返すこと' do
        expect(item.sold?).to be false
      end
    end

    context 'purchase がある場合' do
      let(:buyer) { create(:user) }

      before { create(:purchase, user: buyer, item: item) }

      it 'true を返すこと' do
        expect(item.reload.sold?).to be true
      end
    end
  end
end
