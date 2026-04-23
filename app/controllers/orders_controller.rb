class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item

  def index
    redirect_to root_path if @item.user_id == current_user.id
    redirect_to root_path if @item.purchase.present?

    set_gon_public_key
    @order_form = OrderForm.new
  end

  def create
    redirect_to root_path and return if @item.user_id == current_user.id || @item.purchase.present?

    @order_form = OrderForm.new(order_form_params)
    if @order_form.valid?
      begin
        pay_item
      rescue Payjp::PayjpError => e
        @order_form.errors.add(:base, e.to_s)
        set_gon_public_key
        render :index, status: :unprocessable_entity and return
      end

      if @order_form.save
        redirect_to root_path
      else
        set_gon_public_key
        render :index, status: :unprocessable_entity
      end
    else
      set_gon_public_key
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = Item.includes(image_attachment: :blob).find(params[:item_id])
  end

  def set_gon_public_key
    gon.public_key = ENV.fetch('PAYJP_PUBLIC_KEY', '')
  end

  def pay_item
    Payjp.api_key = ENV.fetch('PAYJP_SECRET_KEY', '')
    Payjp::Charge.create(
      amount: @item.item_price,
      card: @order_form.token,
      currency: 'jpy'
    )
  end

  def order_form_params
    params.require(:order_form).permit(
      :postal_code,
      :prefecture_id,
      :city,
      :street,
      :building,
      :phone_number
    ).merge(user_id: current_user.id, item_id: @item.id, token: params[:token])
  end
end
