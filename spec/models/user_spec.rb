# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'ユーザー新規登録' do
    before do
      @user = FactoryBot.build(:user)
    end

    context '新規登録できるとき' do
      it 'nicknameとemail、passwordとpassword_confirmationが存在すれば登録できる' do
        expect(@user).to be_valid
      end
    end

    context '新規登録できないとき' do
      it 'nicknameが空では登録できない' do
        @user.nickname = ''
        @user.valid?
        expect(@user.errors[:nickname]).to include("can't be blank")
      end

      it 'emailが空では登録できない' do
        @user.email = ''
        @user.valid?
        expect(@user.errors[:email]).to include("can't be blank")
      end

      it '重複したemailが存在する場合は登録できない' do
        FactoryBot.create(:user, email: 'dup@example.com')
        @user = FactoryBot.build(:user, email: 'dup@example.com')
        @user.valid?
        expect(@user.errors[:email]).to include('has already been taken')
      end

      it 'emailは@を含まないと登録できない' do
        @user.email = 'invalid-email'
        @user.valid?
        expect(@user.errors[:email]).to include('is invalid')
      end

      it 'passwordが空では登録できない' do
        @user.password = ''
        @user.password_confirmation = ''
        @user.valid?
        expect(@user.errors[:password]).to include("can't be blank")
      end

      it 'passwordとpassword_confirmationが不一致では登録できない' do
        @user.password_confirmation = 'abc999'
        @user.valid?
        expect(@user.errors[:password_confirmation]).to include("doesn't match Password")
      end

      it 'passwordが5文字以下では登録できない' do
        @user.password = 'ab12'
        @user.password_confirmation = 'ab12'
        @user.valid?
        expect(@user.errors[:password]).to include('is too short (minimum is 6 characters)')
      end

      it 'passwordが129文字以上では登録できない' do
        long = "a#{'1' * 64}#{'b' * 64}"
        expect(long.length).to eq(129)
        @user.password = long
        @user.password_confirmation = long
        @user.valid?
        expect(@user.errors[:password]).to include('is too long (maximum is 128 characters)')
      end

      it 'passwordが英字のみの場合は登録できない' do
        @user.password = 'abcdef'
        @user.password_confirmation = 'abcdef'
        @user.valid?
        expect(@user.errors[:password]).to include('は半角英数字混合で入力してください')
      end

      it 'passwordが数字のみの場合は登録できない' do
        @user.password = '123456'
        @user.password_confirmation = '123456'
        @user.valid?
        expect(@user.errors[:password]).to include('は半角英数字混合で入力してください')
      end

      it 'passwordに全角文字が含まれる場合は登録できない' do
        @user.password = 'abc12あ'
        @user.password_confirmation = 'abc12あ'
        @user.valid?
        expect(@user.errors[:password]).to include('は半角英数字混合で入力してください')
      end

      it '姓（全角）が空では登録できない' do
        @user.family_name_kanji = ''
        @user.valid?
        expect(@user.errors[:family_name_kanji]).to include("can't be blank")
      end

      it '名（全角）が空では登録できない' do
        @user.given_name_kanji = ''
        @user.valid?
        expect(@user.errors[:given_name_kanji]).to include("can't be blank")
      end

      it '姓（全角）に半角文字が含まれる場合は登録できない' do
        @user.family_name_kanji = 'yamada'
        @user.valid?
        expect(@user.errors[:family_name_kanji]).to include('は全角（漢字・ひらがな・カタカナ）で入力してください')
      end

      it '名（全角）に半角文字が含まれる場合は登録できない' do
        @user.given_name_kanji = 'rikutaro'
        @user.valid?
        expect(@user.errors[:given_name_kanji]).to include('は全角（漢字・ひらがな・カタカナ）で入力してください')
      end

      it '姓（カナ）が空では登録できない' do
        @user.family_name_kana = ''
        @user.valid?
        expect(@user.errors[:family_name_kana]).to include("can't be blank")
      end

      it '名（カナ）が空では登録できない' do
        @user.given_name_kana = ''
        @user.valid?
        expect(@user.errors[:given_name_kana]).to include("can't be blank")
      end

      it '姓（カナ）にカタカナ以外の文字が含まれる場合は登録できない' do
        @user.family_name_kana = 'やまだ'
        @user.valid?
        expect(@user.errors[:family_name_kana]).to include('は全角カタカナで入力してください')
      end

      it '名（カナ）にカタカナ以外の文字が含まれる場合は登録できない' do
        @user.given_name_kana = 'たろう'
        @user.valid?
        expect(@user.errors[:given_name_kana]).to include('は全角カタカナで入力してください')
      end

      it '生年月日が空では登録できない' do
        @user.birth_date = nil
        @user.valid?
        expect(@user.errors[:birth_date]).to include("can't be blank")
      end
    end
  end
end
