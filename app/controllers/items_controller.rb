class ItemsController < ApplicationController
  def index
  end

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
