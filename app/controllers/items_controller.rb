class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create] # 未ログインは出品ページ・出品保存へ進めずログイン画面へ

  def index
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path # 保存できたらトップページへ
    else
      render :new, status: :unprocessable_entity # 保存失敗したら入力画面に戻る
    end
  end

  private

  def item_params
    params.require(:item).permit(
      :item_name,
      :item_info,
      :item_price,
      :category_id,
      :item_status_id,
      :shipping_fee_status_id,
      :prefecture_id,
      :scheduled_delivery_id,
      :image
    ).merge(user_id: current_user.id)
  end
end
