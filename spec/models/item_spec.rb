# frozen_string_literal: true

require "rails_helper"

RSpec.describe Item, type: :model do
  describe "バリデーション" do
    before do
      @item = FactoryBot.build(:item)
    end

    context "全ての項目が正しく入力されている場合" do
      it "保存できること" do
        expect(@item).to be_valid
      end
    end

    context "商品画像が空の場合" do
      it "保存できないこと" do
        @item.image.purge
        expect(@item).not_to be_valid
        expect(@item.errors[:image]).to include("can't be blank")
      end
    end

    context "商品名が空の場合" do
      it "保存できないこと" do
        @item.item_name = ""
        expect(@item).not_to be_valid
        expect(@item.errors[:item_name]).to include("can't be blank")
      end
    end

    context "商品の説明が空の場合" do
      it "保存できないこと" do
        @item.item_info = ""
        expect(@item).not_to be_valid
        expect(@item.errors[:item_info]).to include("can't be blank")
      end
    end

    context "カテゴリーが空の場合" do
      it "保存できないこと" do
        @item.category_id = nil
        expect(@item).not_to be_valid
        expect(@item.errors[:category_id]).to include("can't be blank")
      end
    end

    context "商品の状態が空の場合" do
      it "保存できないこと" do
        @item.item_status_id = nil
        expect(@item).not_to be_valid
        expect(@item.errors[:item_status_id]).to include("can't be blank")
      end
    end

    context "配送料の負担が空の場合" do
      it "保存できないこと" do
        @item.shipping_fee_status_id = nil
        expect(@item).not_to be_valid
        expect(@item.errors[:shipping_fee_status_id]).to include("can't be blank")
      end
    end

    context "発送元の地域が空の場合" do
      it "保存できないこと" do
        @item.prefecture_id = nil
        expect(@item).not_to be_valid
        expect(@item.errors[:prefecture_id]).to include("can't be blank")
      end
    end

    context "発送までの日数が空の場合" do
      it "保存できないこと" do
        @item.scheduled_delivery_id = nil
        expect(@item).not_to be_valid
        expect(@item.errors[:scheduled_delivery_id]).to include("can't be blank")
      end
    end

    context "価格が空の場合" do
      it "保存できないこと" do
        @item.item_price = nil
        expect(@item).not_to be_valid
        expect(@item.errors[:item_price]).to include("can't be blank")
      end
    end

    context "価格に半角数字以外が含まれる場合" do
      it "保存できないこと" do
        allow(@item).to receive(:read_attribute_before_type_cast).and_wrap_original do |method, attr|
          attr == :item_price ? "300a" : method.call(attr)
        end
        expect(@item).not_to be_valid
        expect(@item.errors[:item_price]).to include("は半角数値で入力してください")
      end
    end

    context "価格が300円未満の場合" do
      it "保存できないこと" do
        @item.item_price = 299
        expect(@item).not_to be_valid
        expect(@item.errors[:item_price]).to include("must be greater than or equal to 300")
      end
    end

    context "価格が9,999,999円を超える場合" do
      it "保存できないこと" do
        @item.item_price = 10_000_000
        expect(@item).not_to be_valid
        expect(@item.errors[:item_price]).to include("must be less than or equal to 9999999")
      end
    end
  end
end
