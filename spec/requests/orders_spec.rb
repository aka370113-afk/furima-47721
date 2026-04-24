# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  describe 'GET /items/:item_id/orders' do
    let(:seller) { create(:user) }
    let(:buyer) { create(:user) }
    let(:item) { create(:item, user: seller) }

    context 'ログインしていないとき' do
      it 'サインインページへリダイレクトすること' do
        get item_orders_path(item)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログインしているとき' do
      context '他人の出品で未購入の商品のとき' do
        before { sign_in buyer }

        it '購入画面を表示すること' do
          get item_orders_path(item)
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('購入内容の確認')
        end
      end

      context '自分の出品のとき' do
        before { sign_in seller }

        it 'トップへリダイレクトすること' do
          get item_orders_path(item)
          expect(response).to redirect_to(root_path)
        end
      end

      context '売り切れの商品のとき' do
        before do
          sign_in buyer
          create(:purchase, user: buyer, item: item)
        end

        it 'トップへリダイレクトすること' do
          get item_orders_path(item)
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
