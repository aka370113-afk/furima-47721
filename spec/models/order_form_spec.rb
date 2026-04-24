# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderForm, type: :model do
  before do
    @seller = FactoryBot.create(:user)
    @buyer = FactoryBot.create(:user)
    @item = FactoryBot.create(:item, user: @seller)
  end

  describe '商品の購入' do
    before do
      @form = described_class.new(
        FactoryBot.attributes_for(:order_form).merge(user_id: @buyer.id, item_id: @item.id)
      )
    end

    context '購入できるとき' do
      it '必須の項目が存在すれば有効であること' do
        expect(@form).to be_valid
      end

      it '建物名が空でも有効であること' do
        @form.building = ''
        expect(@form).to be_valid
      end
    end

    context '購入できないとき' do
      it '郵便番号が空では無効であること' do
        @form.postal_code = ''
        @form.valid?
        expect(@form.errors[:postal_code]).to include('を入力してください')
      end

      it '郵便番号がハイフンなしでは無効であること' do
        @form.postal_code = '1234567'
        @form.valid?
        expect(@form.errors[:postal_code]).to include('は「3桁ハイフン4桁」の半角数字のみ入力してください（例: 123-4567）')
      end

      it '都道府県として選択できない値（0）の場合は無効であること' do
        @form.prefecture_id = 0
        @form.valid?
        expect(@form.errors[:prefecture_id]).to include('を選択してください')
      end

      it '市区町村が空では無効であること' do
        @form.city = ''
        @form.valid?
        expect(@form.errors[:city]).to include('を入力してください')
      end

      it '番地が空では無効であること' do
        @form.street = ''
        @form.valid?
        expect(@form.errors[:street]).to include('を入力してください')
      end

      it '電話番号が空では無効であること' do
        @form.phone_number = ''
        @form.valid?
        expect(@form.errors[:phone_number]).to include('を入力してください')
      end

      it '電話番号にハイフンが含まれる場合は無効であること' do
        @form.phone_number = '090-1234-5678'
        @form.valid?
        expect(@form.errors[:phone_number]).to include('は10桁以上11桁以内の半角数字のみ入力してください（例: 09012345678、ハイフンなし）')
      end

      it '電話番号が9桁では無効であること' do
        @form.phone_number = '090123456'
        @form.valid?
        expect(@form.errors[:phone_number]).to include('は10桁以上11桁以内の半角数字のみ入力してください（例: 09012345678、ハイフンなし）')
      end

      it '電話番号が12桁以上では無効であること' do
        @form.phone_number = '090123456789'
        @form.valid?
        expect(@form.errors[:phone_number]).to include('は10桁以上11桁以内の半角数字のみ入力してください（例: 09012345678、ハイフンなし）')
      end

      it 'トークンが空では無効であること' do
        @form.token = ''
        @form.valid?
        expect(@form.errors[:token]).to include('を入力してください')
      end

      it 'userが紐付いていない場合は無効であること' do
        @form.user_id = nil
        @form.valid?
        expect(@form.errors[:user_id]).to include('を入力してください')
      end

      it 'itemが紐付いていない場合は無効であること' do
        @form.item_id = nil
        @form.valid?
        expect(@form.errors[:item_id]).to include('を入力してください')
      end

      it '出品者が自分の商品を買おうとする場合は無効であること' do
        @form = described_class.new(
          FactoryBot.attributes_for(:order_form).merge(user_id: @seller.id, item_id: @item.id)
        )
        @form.valid?
        expect(@form.errors[:base]).to include('自分の商品は購入できません')
      end

      it '売り切れ商品の場合は無効であること' do
        FactoryBot.create(:purchase, user: @buyer, item: @item)
        @form = described_class.new(
          FactoryBot.attributes_for(:order_form).merge(user_id: FactoryBot.create(:user).id, item_id: @item.id)
        )
        @form.valid?
        expect(@form.errors[:base]).to include('売り切れです')
      end

      it '存在しない商品 id の場合は無効であること' do
        @form = described_class.new(
          FactoryBot.attributes_for(:order_form).merge(user_id: @buyer.id, item_id: 0)
        )
        @form.valid?
        expect(@form.errors[:base]).to include('商品が見つかりません')
      end
    end
  end

  describe '#save' do
    before do
      @form = described_class.new(
        FactoryBot.attributes_for(:order_form).merge(user_id: @buyer.id, item_id: @item.id)
      )
    end

    context '保存に成功するとき' do
      it 'true を返し Purchase と Address が1件ずつ作成されること' do
        saved = nil
        expect do
          saved = @form.save
        end.to change(Purchase, :count).by(1).and change(Address, :count).by(1)
        expect(saved).to be true

        purchase = Purchase.order(:id).last
        expect(purchase.user_id).to eq(@buyer.id)
        expect(purchase.item_id).to eq(@item.id)
        expect(purchase.address).to be_present
        expect(purchase.address.postal_code).to eq(FactoryBot.attributes_for(:order_form)[:postal_code])
      end
    end

    context '保存に失敗するとき' do
      it 'false を返し Purchase を増やさないこと' do
        @form.postal_code = 'invalid'
        expect(@form.save).to be false
        expect(@form).not_to be_valid
      end
    end
  end
end
