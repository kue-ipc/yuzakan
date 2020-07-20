# frozen_string_literal: true

require_relative '../../spec_helper'

describe Mailers::ResetPassword do
  let(:config) { ConfigRepository.new.current }
  let(:user) { UserRepository.new.by_name('user').first }

  it 'delivers email' do
    mail = Mailers::ResetPassword.deliver(user: user, config: config)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded)
      .must_include 'パスワードをリセットしました。'
    _(mail.body.parts.first.decoded).must_include '実施日時:'
    _(mail.body.parts.first.decoded).must_include 'システム: テストシステム'
    _(mail.body.parts.first.decoded).must_include 'ユーザー: user'
    _(mail.body.parts.first.decoded).must_include '処理内容: パスワードリセット'

    _(mail.body.parts.first.decoded).wont_include '実施者:'
    _(mail.body.parts.first.decoded).wont_include '処理結果:'
  end

  it 'delivers email by self' do
    mail = Mailers::ResetPassword.deliver(user: user, config: config,
                                          by_user: :self)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).wont_include '実施者:'
  end

  it 'delivers email by self' do
    mail = Mailers::ResetPassword.deliver(user: user, config: config,
                                          by_user: :admin)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include '実施者: 管理者'
  end

  it 'delivers email by system' do
    mail = Mailers::ResetPassword.deliver(user: user, config: config,
                                          by_user: :system)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include '実施者: システム'
  end

  it 'delivers email dumy system' do
    mail = Mailers::ResetPassword.deliver(
      user: user, config: config,
      systems: [ProviderRepository.new.by_name('dummy').one])
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include 'システム: ダミー'
    _(mail.body.parts.first.decoded).wont_include 'システム: テストシステム'
  end

  it 'delivers email result success' do
    mail = Mailers::ResetPassword.deliver(user: user, config: config,
                                          result: :success)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include '処理結果: 成功'
  end

  it 'delivers email result failure' do
    mail = Mailers::ResetPassword.deliver(user: user, config: config,
                                          result: :failure)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include '処理結果: 失敗'
  end

  it 'delivers email result error' do
    mail = Mailers::ResetPassword.deliver(user: user, config: config,
                                          result: :error)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include '処理結果: エラー'
  end

  describe 'contact' do
    before do
      UpdateConfig.new.call(contact_name: 'テスト管理者')
    end

    after do
      db_reset
    end

    it 'delivers email contact name' do
      mail = Mailers::ResetPassword.deliver(user: user, config: config)
      _(mail.to).must_equal ['user@yuzakan.test']
      _(mail.body.parts.first.decoded).must_include 'テスト管理者'
    end

    it 'delivers email contact email' do
      UpdateConfig.new.call(contact_email: 'support@yuzakan.test')
      mail = Mailers::ResetPassword.deliver(user: user, config: config)
      _(mail.to).must_equal ['user@yuzakan.test']
      _(mail.body.parts.first.decoded)
        .must_include 'メールアドレス: support@yuzakan.test'
    end

    it 'delivers email contact phone' do
      UpdateConfig.new.call(contact_phone: '0000-00-0000')
      mail = Mailers::ResetPassword.deliver(user: user, config: config)
      _(mail.to).must_equal ['user@yuzakan.test']
      _(mail.body.parts.first.decoded).must_include '電話番号: 0000-00-0000'
    end
  end
end
