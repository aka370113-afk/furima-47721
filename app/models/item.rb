class Item < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to :category
  belongs_to :item_status
  belongs_to :shipping_fee_status
  belongs_to :prefecture
  belongs_to :scheduled_delivery
  has_one_attached :image

  validates :image, presence: true
  validates :item_name, presence: true
  validates :item_info, presence: true

  validates :item_price, presence: true
  validate :item_price_must_be_half_width_digits
  validates :item_price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 300,
    less_than_or_equal_to: 9_999_999
  }, allow_blank: true

  private

  def item_price_must_be_half_width_digits
    raw = read_attribute_before_type_cast(:item_price)
    return if raw.blank?

    errors.add(:item_price, "は半角数値で入力してください") unless raw.to_s.match?(/\A[0-9]+\z/)
  end
end
