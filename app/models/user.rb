class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  PASSWORD_REGEX = /\A(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]+\z/.freeze

  validates :password,
            format: { with: PASSWORD_REGEX, message: "は半角英数字混合で入力してください" },
            allow_blank: true

  with_options presence: true do
    # ひらがな、カタカナ、漢字のみ許可する（名字・名前）
    validates :family_name_kanji,
              format: { with: /\A[ぁ-んァ-ヶ一-龥々ー]+\z/, message: "は全角（漢字・ひらがな・カタカナ）で入力してください", allow_blank: true }
    validates :given_name_kanji,
              format: { with: /\A[ぁ-んァ-ヶ一-龥々ー]+\z/, message: "は全角（漢字・ひらがな・カタカナ）で入力してください", allow_blank: true }
    # カタカナのみ許可する（名字カナ・名前カナ）
    validates :family_name_kana,
              format: { with: /\A[ァ-ヶー]+\z/, message: "は全角カタカナで入力してください", allow_blank: true }
    validates :given_name_kana,
              format: { with: /\A[ァ-ヶー]+\z/, message: "は全角カタカナで入力してください", allow_blank: true }
    validates :nickname
    validates :birth_date
  end

  has_many :items
  has_many :purchases
end
