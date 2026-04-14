# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "有効なファクトリなら保存できる" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "ニックネームが空では保存できない" do
      user = build(:user, nickname: "")
      expect(user).not_to be_valid
      expect(user.errors[:nickname]).to include("can't be blank")
    end

    it "メールが空では保存できない" do
      user = build(:user, email: "")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "メールが重複していれば保存できない" do
      create(:user, email: "dup@example.com")
      other = build(:user, email: "dup@example.com")
      expect(other).not_to be_valid
      expect(other.errors[:email]).to include("has already been taken")
    end

    it "メールに@がない形式では保存できない" do
      user = build(:user, email: "invalid-email")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it "パスワードが空では保存できない" do
      user = build(:user, password: "", password_confirmation: "")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "パスワードが5文字以下では保存できない" do
      user = build(:user, password: "ab12", password_confirmation: "ab12")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
    end

    it "パスワードが英字のみでは保存できない" do
      user = build(:user, password: "abcdef", password_confirmation: "abcdef")
      expect(user).not_to be_valid
      expect(user.errors[:password]).not_to be_empty
    end

    it "パスワードと確認が一致しなければ保存できない" do
      user = build(:user, password_confirmation: "abc999")
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end

    it "お名前(全角)が半角だけでは保存できない" do
      user = build(:user, family_name_kanji: "yamada")
      expect(user).not_to be_valid
      expect(user.errors[:family_name_kanji]).not_to be_empty
    end

    it "お名前カナがひらがなでは保存できない" do
      user = build(:user, family_name_kana: "やまだ")
      expect(user).not_to be_valid
      expect(user.errors[:family_name_kana]).not_to be_empty
    end

    it "生年月日が空では保存できない" do
      user = build(:user, birth_date: nil)
      expect(user).not_to be_valid
      expect(user.errors[:birth_date]).to include("can't be blank")
    end
  end
end
