require_relative '../../spec_helper'

describe Mailers::ChangePassword do
  let(:config) { ConfigRepository.new.current }
  let(:user) { UserRepository.new.by_name('user').first }

  it 'delivers email' do
    mail = Mailers::ChangePassword.deliver(user: user, config: config)
    _(mail.to).must_equal ['user@yuzakan.test']
    _(mail.body.parts.first.decoded)
      .must_include 'パスワードを変更しました。'
    _(mail.body.parts.first.decoded).must_include '実施日時:'
    _(mail.body.parts.first.decoded).must_include 'システム: テストシステム'
    _(mail.body.parts.first.decoded).must_include 'ユーザー: user'
    _(mail.body.parts.first.decoded).must_include '処理内容: パスワード変更'

    _(mail.body.parts.first.decoded).wont_include '実施者:'
    _(mail.body.parts.first.decoded).wont_include '処理結果:'
  end
end
