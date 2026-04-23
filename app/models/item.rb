class Item < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  # 一覧は出品日時が新しい順（左上から読む順と一致）
  scope :newest_first, -> { order(created_at: :desc) }

  belongs_to :user
  belongs_to :category
  belongs_to :item_status
  belongs_to :shipping_fee_status
  belongs_to :prefecture
  belongs_to :scheduled_delivery
  has_one_attached :image
  has_one :purchase, dependent: :destroy

  def sold?
    purchase.present?
  end

  validates :image, presence: true
  validates :item_name, presence: true
  validates :item_info, presence: true
  # ActiveHash 先の belongs_to は optional になりがちなため、必須は *_id で明示する
  validates :category_id, presence: true
  validates :item_status_id, presence: true
  validates :shipping_fee_status_id, presence: true
  validates :prefecture_id, presence: true
  validates :scheduled_delivery_id, presence: true

  validates :item_price, presence: true
  validate :item_price_must_be_half_width_digits
  validates :item_price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 300,
    less_than_or_equal_to: 9_999_999
  }, allow_blank: true

  # def sold?
  #   purchase.present?
  # end

  private

  def item_price_must_be_half_width_digits
    raw = read_attribute_before_type_cast(:item_price)
    return if raw.blank?

    errors.add(:item_price, "は半角数値で入力してください") unless raw.to_s.match?(/\A[0-9]+\z/)
  end
end
