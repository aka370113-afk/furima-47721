# 購入画面用のフォームオブジェクト。Purchase / Address をまとめて扱う。
#
# 処理の流れ（面接・コードリーディングで説明しやすい単位）:
# 1. 正規化 … パラメータの前後空白・空文字・都道府県の未選択を揃えてから検証する
# 2. バリデーション … ActiveModel の validates と、商品が買えるかのカスタム検証
# 3. 保存 … トランザクション内で Purchase と Address を同時に作成（片方だけ残らない）
class OrderForm
  include ActiveModel::Model

  attr_accessor :postal_code, :prefecture_id, :city, :street, :building, :phone_number, :user_id, :item_id, :token

  # 配送先は購入の都度フォーム入力のみ（ユーザー登録情報からの自動入力はしない）

  POSTAL_CODE_REGEX = /\A[0-9]{3}-[0-9]{4}\z/.freeze
  PHONE_REGEX = /\A[0-9]{10,11}\z/.freeze

  # --- バリデーション（valid? 内で先に正規化が走る前提）---

  with_options presence: { message: "を入力してください" } do
    validates :postal_code
    validates :city
    validates :street
    validates :phone_number
    validates :user_id
    validates :item_id
    validates :token
  end

  validates :postal_code,
            format: {
              with: POSTAL_CODE_REGEX,
              message: "は「3桁ハイフン4桁」の半角数字のみ入力してください（例: 123-4567）"
            }

  validates :prefecture_id,
            presence: { message: "を選択してください" },
            inclusion: { in: Prefecture.all.map(&:id), message: "を選択してください" }

  validates :phone_number,
            format: {
              with: PHONE_REGEX,
              message: "は10桁以上11桁以内の半角数字のみ入力してください（例: 09012345678、ハイフンなし）"
            }

  validate :item_must_be_purchasable

  # --- 公開 API ---

  # 検証の直前に正規化する（空白のみの入力を空扱いにし、prefecture は整数 or nil に揃える）
  def valid?(context = nil)
    normalize_for_validation
    super
  end

  # 検証 OK のときだけ DB へ書き込む。失敗時は例外を握りつぶさず errors に載せて false
  def save
    return false if invalid?

    ActiveRecord::Base.transaction { persist_purchase_and_address! }
    true
  rescue ActiveRecord::RecordInvalid => e
    assign_record_invalid_errors(e)
    false
  end

  private

  # --- 正規化 ---

  def normalize_for_validation
    normalize_text_fields
    normalize_prefecture_id
  end

  def normalize_text_fields
    self.postal_code = postal_code.to_s.strip
    self.phone_number = phone_number.to_s.strip
    self.city = city.to_s.strip
    self.street = street.to_s.strip
    self.building = building.to_s.strip.presence
  end

  def normalize_prefecture_id
    self.prefecture_id =
      if prefecture_id.blank? || prefecture_id.to_s.strip.blank?
        nil
      else
        prefecture_id.to_i
      end
  end

  # --- カスタムバリデーション ---

  def item_must_be_purchasable
    item = Item.find_by(id: item_id)
    errors.add(:base, "商品が見つかりません") && return if item.blank?

    errors.add(:base, "自分の商品は購入できません") if item.user_id == user_id
    errors.add(:base, "売り切れです") if item.purchase.present?
  end

  # --- 永続化 ---

  def persist_purchase_and_address!
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

  def assign_record_invalid_errors(exception)
    errors.add(:base, exception.record.errors.full_messages.join(", "))
  end
end
