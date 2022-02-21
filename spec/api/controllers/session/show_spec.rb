require_relative '../../../spec_helper'

describe Api::Controllers::Session::Show do
  let(:action) {
    Api::Controllers::Session::Show.new(activity_log_repository: activity_log_repository,
                                        config_repository: config_repository,
                                        user_repository: user_repository)
  }
  let(:params) { {**env} }
  let(:env) { {'REMOTE_ADDR' => remote_ip, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:remote_ip) { '192.0.2.1' }
  let(:session) { {uuid: 'ffffffff-ffff-4fff-bfff-ffffffffffff', user_id: 42, access_time: Time.now} }
  let(:format)  { 'application/json' }
  let(:activity_log_repository) { create_mock(create: [nil, [Hash]]) }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:config_repository) { create_mock(current: [config]) }
  let(:user) { User.new(name: 'user', display_name: 'ユーザー', email: 'user@example.jp') }
  let(:user_repository) { create_mock(find: [user, [42]], find_by_name: [user, ['user']], update: [nil, [42, Hash]]) }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
      uuid: 'ffffffff-ffff-4fff-bfff-ffffffffffff',
      username: 'user',
      display_name: 'ユーザー',
    })
  end

  describe 'no login session' do
    let(:session) { {uuid: 'ffffffff-ffff-4fff-bfff-ffffffffffff', user_id: nil, access_time: Time.now} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 401
      _(response[2]).must_equal [JSON.generate({
        code: 401,
        message: 'ログインしてください。',
      })]
    end
  end

  describe 'no session' do
    let(:session) { {} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 401
      _(response[2]).must_equal [JSON.generate({
        code: 401,
        message: 'ログインしてください。',
      })]
    end
  end

  describe 'no session' do
    let(:session) { {} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 401
      _(response[2]).must_equal [JSON.generate({
        code: 401,
        message: 'ログインしてください。',
      })]
    end
  end
end
