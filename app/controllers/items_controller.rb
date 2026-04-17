class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create] # 未ログインは出品ページ・出品保存へ進めずログイン画面へ

  def index
    # shipping_fee_status は ActiveHash のため includes 不可（DB にテーブルがない）
    @items = Item.includes(image_attachment: :blob).newest_first
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

  def show
    @item = Item.includes(:user, :purchase, image_attachment: :blob).find(params[:id])
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
