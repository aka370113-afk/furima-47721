# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    before do
      @user = FactoryBot.build(:user)
    end

    context "全ての項目が正しく入力されている場合" do
      it "保存できること" do
        expect(@user).to be_valid
      end
    end

    context "ニックネームが空の場合" do
      it "保存できないこと" do
        @user.nickname = ""
        expect(@user).not_to be_valid
        expect(@user.errors[:nickname]).to include("can't be blank")
      end
    end

    context "メールアドレスが空の場合" do
      it "保存できないこと" do
        @user.email = ""
        expect(@user).not_to be_valid
        expect(@user.errors[:email]).to include("can't be blank")
      end
    end

    context "メールアドレスがすでに登録されている場合" do
      before do
        FactoryBot.create(:user, email: "dup@example.com")
        @user = FactoryBot.build(:user, email: "dup@example.com")
      end

      it "保存できないこと" do
        expect(@user).not_to be_valid
        expect(@user.errors[:email]).to include("has already been taken")
      end
    end

    context "メールアドレスに@が含まれない場合" do
      it "保存できないこと" do
        @user.email = "invalid-email"
        expect(@user).not_to be_valid
        expect(@user.errors[:email]).to include("is invalid")
      end
    end

    context "パスワードが空の場合" do
      it "保存できないこと" do
        @user.password = ""
        @user.password_confirmation = ""
        expect(@user).not_to be_valid
        expect(@user.errors[:password]).to include("can't be blank")
      end
    end

    context "パスワードが6文字未満の場合" do
      it "保存できないこと" do
        @user.password = "ab12"
        @user.password_confirmation = "ab12"
        expect(@user).not_to be_valid
        expect(@user.errors[:password]).to include("is too short (minimum is 6 characters)")
      end
    end

    context "パスワードが英字のみの場合" do
      it "保存できないこと" do
        @user.password = "abcdef"
        @user.password_confirmation = "abcdef"
        expect(@user).not_to be_valid
        expect(@user.errors[:password]).to include("は半角英数字混合で入力してください")
      end
    end

    context "パスワードが数字のみの場合" do
      it "保存できないこと" do
        @user.password = "123456"
        @user.password_confirmation = "123456"
        expect(@user).not_to be_valid
        expect(@user.errors[:password]).to include("は半角英数字混合で入力してください")
      end
    end

    context "パスワードに全角文字が含まれる場合" do
      it "保存できないこと" do
        @user.password = "abc12あ"
        @user.password_confirmation = "abc12あ"
        expect(@user).not_to be_valid
        expect(@user.errors[:password]).to include("は半角英数字混合で入力してください")
      end
    end

    context "パスワードとパスワード確認が一致しない場合" do
      it "保存できないこと" do
        @user.password_confirmation = "abc999"
        expect(@user).not_to be_valid
        expect(@user.errors[:password_confirmation]).to include("doesn't match Password")
      end
    end

    context "姓（全角）が空の場合" do
      it "保存できないこと" do
        @user.family_name_kanji = ""
        expect(@user).not_to be_valid
        expect(@user.errors[:family_name_kanji]).to include("can't be blank")
      end
    end

    context "名（全角）が空の場合" do
      it "保存できないこと" do
        @user.given_name_kanji = ""
        expect(@user).not_to be_valid
        expect(@user.errors[:given_name_kanji]).to include("can't be blank")
      end
    end

    context "姓（全角）に半角文字が含まれる場合" do
      it "保存できないこと" do
        @user.family_name_kanji = "yamada"
        expect(@user).not_to be_valid
        expect(@user.errors[:family_name_kanji]).to include("は全角（漢字・ひらがな・カタカナ）で入力してください")
      end
    end

    context "名（全角）に半角文字が含まれる場合" do
      it "保存できないこと" do
        @user.given_name_kanji = "rikutaro"
        expect(@user).not_to be_valid
        expect(@user.errors[:given_name_kanji]).to include("は全角（漢字・ひらがな・カタカナ）で入力してください")
      end
    end

    context "姓（カナ）が空の場合" do
      it "保存できないこと" do
        @user.family_name_kana = ""
        expect(@user).not_to be_valid
        expect(@user.errors[:family_name_kana]).to include("can't be blank")
      end
    end

    context "名（カナ）が空の場合" do
      it "保存できないこと" do
        @user.given_name_kana = ""
        expect(@user).not_to be_valid
        expect(@user.errors[:given_name_kana]).to include("can't be blank")
      end
    end

    context "姓（カナ）にカタカナ以外の文字が含まれる場合" do
      it "保存できないこと" do
        @user.family_name_kana = "やまだ"
        expect(@user).not_to be_valid
        expect(@user.errors[:family_name_kana]).to include("は全角カタカナで入力してください")
      end
    end

    context "名（カナ）にカタカナ以外の文字が含まれる場合" do
      it "保存できないこと" do
        @user.given_name_kana = "たろう"
        expect(@user).not_to be_valid
        expect(@user.errors[:given_name_kana]).to include("は全角カタカナで入力してください")
      end
    end

    context "生年月日が空の場合" do
      it "保存できないこと" do
        @user.birth_date = nil
        expect(@user).not_to be_valid
        expect(@user.errors[:birth_date]).to include("can't be blank")
      end
    end
  end
end
