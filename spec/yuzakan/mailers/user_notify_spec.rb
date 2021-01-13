require_relative '../../spec_helper'

describe Mailers::UserNotify do
  let(:config) { ConfigRepository.new.current }
  let(:user) { UserRepository.new.by_name('user').first }
  let(:params) { {
    user: user,
    config: config,
    action: 'テスト処理',
    description: 'テスト処理をしました。',
  } }

  it 'delivers email' do
    mail = Mailers::UserNotify.deliver(**params)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.subject).must_equal 'テストシステム【テスト処理】'
    _(mail.body.parts.first.decoded)
      .must_include 'テスト処理をしました。'
    _(mail.body.parts.first.decoded).must_include '実施日時:'
    _(mail.body.parts.first.decoded).must_include 'システム: テストシステム'
    _(mail.body.parts.first.decoded).must_include 'ユーザー: user'
    _(mail.body.parts.first.decoded).must_include '処理内容: テスト処理'

    _(mail.body.parts.first.decoded).wont_include '実施者:'
    _(mail.body.parts.first.decoded).wont_include '処理結果:'
  end

  it 'delivers email by self' do
    mail = Mailers::UserNotify.deliver(**params, by_user: :self)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).wont_include '実施者:'
  end

  it 'delivers email by self' do
    mail = Mailers::UserNotify.deliver(**params, by_user: :admin)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include '実施者: 管理者'
  end

  it 'delivers email by system' do
    mail = Mailers::UserNotify.deliver(**params, by_user: :system)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include '実施者: システム'
  end

  it 'delivers email dumy system' do
    mail = Mailers::UserNotify.deliver(
      **params,
      providers: [ProviderRepository.new.by_name('dummy').one])
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include 'システム: ダミー'
    _(mail.body.parts.first.decoded).wont_include 'システム: テストシステム'
  end

  it 'delivers email result success' do
    mail = Mailers::UserNotify.deliver(**params, result: :success)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include '処理結果: 成功'
  end

  it 'delivers email result failure' do
    mail = Mailers::UserNotify.deliver(**params, result: :failure)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded).must_include '処理結果: 失敗'
  end

  it 'delivers email result error' do
    mail = Mailers::UserNotify.deliver(**params, result: :error)
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
      mail = Mailers::UserNotify.deliver(**params)
      _(mail.to).must_equal ['user@yuzakan.test']
      _(mail.body.parts.first.decoded).must_include 'テスト管理者'
    end

    it 'delivers email contact email' do
      UpdateConfig.new.call(contact_email: 'support@yuzakan.test')
      mail = Mailers::UserNotify.deliver(**params)
      _(mail.to).must_equal ['user@yuzakan.test']
      _(mail.body.parts.first.decoded)
        .must_include 'メールアドレス: support@yuzakan.test'
    end

    it 'delivers email contact phone' do
      UpdateConfig.new.call(contact_phone: '0000-00-0000')
      mail = Mailers::UserNotify.deliver(**params)
      _(mail.to).must_equal ['user@yuzakan.test']
      _(mail.body.parts.first.decoded).must_include '電話番号: 0000-00-0000'
    end
  end
end
