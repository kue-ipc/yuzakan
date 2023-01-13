# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Mailers::UserNotify do
  # let(:config) { ConfigRepository.new.current }
  # let(:user) { UserRepository.new.by_name('user').first }
  # let(:params) {
  #   {
  #     user: user,
  #     config: config,
  #     action: 'テスト処理',
  #     description: 'テスト処理をしました。',
  #   }
  # }

  # it 'delivers email' do
  #   mail = Mailers::UserNotify.deliver(**params)
  #   expect(mail.to).to eq ['user@yuzakan.test']
  #   expect(mail.subject).to eq 'テストシステム【テスト処理】'
  #   expect(mail.body.parts.first.decoded)
  #     .to include 'テスト処理をしました。'
  #   expect(mail.body.parts.first.decoded).to include '実施日時:'
  #   expect(mail.body.parts.first.decoded).to include 'システム: テストシステム'
  #   expect(mail.body.parts.first.decoded).to include 'ユーザー: user'
  #   expect(mail.body.parts.first.decoded).to include '処理内容: テスト処理'

  #   expect(mail.body.parts.first.decoded).not_to include '実施者:'
  #   expect(mail.body.parts.first.decoded).not_to include '処理結果:'
  # end

  # it 'delivers email by self' do
  #   mail = Mailers::UserNotify.deliver(**params, by_user: :self)
  #   expect(mail.to).to eq ['user@yuzakan.test']
  #   expect(mail.body.parts.first.decoded).not_to include '実施者:'
  # end

  # it 'delivers email by self' do
  #   mail = Mailers::UserNotify.deliver(**params, by_user: :admin)
  #   expect(mail.to).to eq ['user@yuzakan.test']
  #   expect(mail.body.parts.first.decoded).to include '実施者: 管理者'
  # end

  # it 'delivers email by system' do
  #   mail = Mailers::UserNotify.deliver(**params, by_user: :system)
  #   expect(mail.to).to eq ['user@yuzakan.test']
  #   expect(mail.body.parts.first.decoded).to include '実施者: システム'
  # end

  # it 'delivers email dumy system' do
  #   mail = Mailers::UserNotify.deliver(
  #     **params,
  #     providers: [ProviderRepository.new.by_name('dummy').one])
  #   expect(mail.to).to eq ['user@yuzakan.test']
  #   expect(mail.body.parts.first.decoded).to include 'システム: ダミー'
  #   expect(mail.body.parts.first.decoded).not_to include 'システム: テストシステム'
  # end

  # it 'delivers email result success' do
  #   mail = Mailers::UserNotify.deliver(**params, result: :success)
  #   expect(mail.to).to eq ['user@yuzakan.test']
  #   expect(mail.body.parts.first.decoded).to include '処理結果: 成功'
  # end

  # it 'delivers email result failure' do
  #   mail = Mailers::UserNotify.deliver(**params, result: :failure)
  #   expect(mail.to).to eq ['user@yuzakan.test']
  #   expect(mail.body.parts.first.decoded).to include '処理結果: 失敗'
  # end

  # it 'delivers email result error' do
  #   mail = Mailers::UserNotify.deliver(**params, result: :error)
  #   expect(mail.to).to eq ['user@yuzakan.test']
  #   expect(mail.body.parts.first.decoded).to include '処理結果: エラー'
  # end

  # RSpec.describe 'contact' do
  #   before do
  #     UpdateConfig.new.call(contact_name: 'テスト管理者')
  #   end

  #   after do
  #     db_reset
  #   end

  #   it 'delivers email contact name' do
  #     mail = Mailers::UserNotify.deliver(**params)
  #     expect(mail.to).to eq ['user@yuzakan.test']
  #     expect(mail.body.parts.first.decoded).to include 'テスト管理者'
  #   end

  #   it 'delivers email contact email' do
  #     UpdateConfig.new.call(contact_email: 'support@yuzakan.test')
  #     mail = Mailers::UserNotify.deliver(**params)
  #     expect(mail.to).to eq ['user@yuzakan.test']
  #     expect(mail.body.parts.first.decoded)
  #       .to include 'メールアドレス: support@yuzakan.test'
  #   end

  #   it 'delivers email contact phone' do
  #     UpdateConfig.new.call(contact_phone: '0000-00-0000')
  #     mail = Mailers::UserNotify.deliver(**params)
  #     expect(mail.to).to eq ['user@yuzakan.test']
  #     expect(mail.body.parts.first.decoded).to include '電話番号: 0000-00-0000'
  #   end
  # end
end
