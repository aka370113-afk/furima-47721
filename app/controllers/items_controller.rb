class ItemsController < ApplicationController
  # 未ログインはログイン画面へ。edit/update は販売状況に関わらず（new/create も同様）
  before_action :authenticate_user!, only: [:new, :create, :edit, :update]
  before_action :set_item, only: [:show, :edit, :update]
  # 出品者本人だけ edit/update 可。ログイン中でも他人の商品は販売状況に関わらずトップへ
  before_action :redirect_unless_owner, only: [:edit, :update]

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
  end

  def edit
  end

  def update
    if @item.update(item_params_for_update)
      # 商品詳細へ。次の GET /items/:id で show が走り、DB に保存した内容が表示される
      redirect_to @item
    else
      # 保存されない。@item に送信値が載ったままなので、画像・手数料・利益以外の入力はフォームに残る
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = Item.includes(:user, image_attachment: :blob).find(params[:id])
  end

  def redirect_unless_owner
    return if current_user.id == @item.user_id

    redirect_to root_path
  end

  # 新規出品: ログインユーザーを出品者に紐づける（user_id はフォームから送らせない）
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

  # 更新: 商品属性のみ。user_id は permit せず merge もしない（出品者は変えない）
  # 画像を選ばずに「変更する」したときは :image を渡さない（既存画像を消さない）
  def item_params_for_update
    permitted = params.require(:item).permit(
      :item_name,
      :item_info,
      :item_price,
      :category_id,
      :item_status_id,
      :shipping_fee_status_id,
      :prefecture_id,
      :scheduled_delivery_id,
      :image
    )
    permitted.delete(:image) if permitted[:image].blank?
    permitted
  end
end
