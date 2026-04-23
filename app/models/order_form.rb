class OrderForm
  include ActiveModel::Model

  attr_accessor :postal_code, :prefecture_id, :city, :street, :building, :phone_number, :user_id, :item_id, :token

  # 配送先は購入の都度フォーム入力のみ（ユーザー登録情報からの自動入力はしない）

  POSTAL_CODE_REGEX = /\A[0-9]{3}-[0-9]{4}\z/
  PHONE_REGEX = /\A[0-9]{10,11}\z/

  with_options presence: { message: 'を入力してください' } do
    validates :postal_code
    validates :city
    validates :street
    validates :phone_number
    validates :user_id
    validates :item_id
    validates :token
  end

  validates :prefecture_id, presence: { message: 'を選択してください' }

  validates :postal_code,
            format: {
              with: POSTAL_CODE_REGEX,
              message: 'は「3桁ハイフン4桁」の半角数字のみ入力してください（例: 123-4567）'
            },
            allow_blank: true

  validates :prefecture_id,
            numericality: {
              only_integer: true,
              greater_than: 0,
              message: 'を選択してください'
            },
            allow_nil: true

  validates :phone_number,
            format: {
              with: PHONE_REGEX,
              message: 'は10桁以上11桁以内の半角数字のみ入力してください（例: 09012345678、ハイフンなし）'
            },
            allow_blank: true

  validate :item_must_be_purchasable
  validate :prefecture_must_exist

  def valid?(context = nil)
    normalize_address_inputs
    super
  end

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
    errors.add(:base, e.record.errors.full_messages.join(', '))
    false
  end

  private

  def normalize_address_inputs
    self.postal_code = postal_code.to_s.strip
    self.phone_number = phone_number.to_s.strip
    self.city = city.to_s.strip
    self.street = street.to_s.strip
    self.building = building.to_s.strip.presence

    self.prefecture_id =
      if prefecture_id.blank? || prefecture_id.to_s.strip.blank?
        nil
      else
        prefecture_id.to_i
      end
  end

  def prefecture_must_exist
    return if prefecture_id.blank?
    return if prefecture_id.to_i <= 0

    errors.add(:prefecture_id, 'を選択してください') if Prefecture.find_by(id: prefecture_id).blank?
  end

  def item_must_be_purchasable
    item = Item.find_by(id: item_id)
    errors.add(:base, '商品が見つかりません') && return if item.blank?

    errors.add(:base, '自分の商品は購入できません') if item.user_id == user_id
    errors.add(:base, '売り切れです') if item.purchase.present?
  end
end
