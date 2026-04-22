class OrderForm
  include ActiveModel::Model

  attr_accessor :postal_code, :prefecture_id, :city, :street, :building, :phone_number, :user_id, :item_id, :token

  with_options presence: true do
    validates :postal_code,
              format: { with: /\A[0-9]{3}-[0-9]{4}\z/, message: "はハイフンを含む半角7桁で入力してください" }
    validates :city
    validates :street
    validates :phone_number
    validates :user_id
    validates :item_id
    validates :token
  end

  validates :prefecture_id, numericality: { only_integer: true, greater_than: 0, message: "を選択してください" }

  validate :item_must_be_purchasable

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      purchase = Purchase.create!(user_id: user_id, item_id: item_id)
      Address.create!(
        postal_code: postal_code,
        prefecture_id: prefecture_id,
        city: city,
        street: street,
        building: building.presence,
        phone_number: phone_number,
        purchase_id: purchase.id
      )
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.record.errors.full_messages.join(", "))
    false
  end

  private

  def item_must_be_purchasable
    item = Item.find_by(id: item_id)
    errors.add(:base, "商品が見つかりません") && return if item.blank?

    errors.add(:base, "自分の商品は購入できません") if item.user_id == user_id
    errors.add(:base, "売り切れです") if item.purchase.present?
  end
end
