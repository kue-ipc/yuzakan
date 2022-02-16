require_relative '../../../spec_helper'

describe Api::Controllers::Session::Destroy do
  let(:action) {
    Api::Controllers::Session::Destroy.new(activity_log_repository: activity_log_repository,
                                           config_repository: config_repository,
                                           user_repository: user_repository)
  }
  let(:params) { {**env} }
  let(:env) { {'REMOTE_ADDR' => remote_ip, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:remote_ip) { '::1' }
  let(:session) { {uuid: 'x', user_id: 42, access_time: Time.now} }
  let(:format)  { 'application/json' }
  let(:activity_log_repository) { create_mock(create: [nil, [Hash]]) }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:config_repository) { create_mock(current: [config]) }
  let(:user) { User.new(name: 'user', display_name: 'ユーザー', email: 'user@example.jp') }
  let(:user_repository) { create_mock(find: [user, [42]], find_by_name: [user, ['user']], update: [nil, [42, Hash]]) }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[2]).must_equal [JSON.generate({
      result: 'success',
      message: 'ログアウトしました。',
    })]
  end

  describe 'no login session' do
    let(:session) { {uuid: 'x', user_id: nil, access_time: Time.now} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 410
      _(response[2]).must_equal [JSON.generate({
        result: 'error',
        message: 'ログインしていません。',
      })]
    end
  end
end
