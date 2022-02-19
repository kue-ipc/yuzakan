require_relative '../../../spec_helper'

describe Api::Controllers::Session::Create do
  let(:action) {
    Api::Controllers::Session::Create.new(activity_log_repository: activity_log_repository,
                                          config_repository: config_repository,
                                          user_repository: user_repository,
                                          provider_repository: provider_repository,
                                          auth_log_repository: auth_log_repository)
  }
  let(:params) { {session: {username: 'user', password: 'pass'}, **env} }
  let(:env) { {'REMOTE_ADDR' => remote_ip, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:remote_ip) { '::1' }
  let(:session) { {uuid: 'x', user_id: 42, access_time: Time.now} }
  let(:format)  { 'application/json' }
  let(:activity_log_repository) { create_mock(create: [nil, [Hash]]) }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:config_repository) { create_mock(current: [config]) }
  let(:user) { User.new(name: 'user', display_name: 'ユーザー', email: 'user@example.jp') }
  let(:user_repository) { create_mock(find: [user, [42]], find_by_name: [user, ['user']], update: [nil, [42, Hash]]) }
  let(:providers) { [create_mock_provider(username: 'user', password: 'pass')] }
  let(:provider_repository) { create_mock(operational_all_with_adapter: [providers, [:auth]]) }
  let(:auth_log_repository) { create_mock(create: [nil, [Hash]], recent_by_username: [[], [String, Integer]]) }

  it 'is failed' do
    response = action.call(params)
    _(response[0]).must_equal 409
    _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
      result: 'error',
      message: '既にログインしています。',
    })
  end

  describe 'no login session' do
    let(:session) { {uuid: 'x', user_id: nil, access_time: Time.now} }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
        result: 'success',
        message: 'ログインしました。',
      })
    end

    it 'is failed with bad password' do
      response = action.call(**params, session: {username: 'user', password: 'nopass'})
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
        result: 'failure',
        message: 'ログインに失敗しました。',
        errors: ['ユーザー名またはパスワードが違います。'],
      })
    end

    it 'is failed with bad username' do
      response = action.call(**params, session: {username: 'user1', password: 'pass'})
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
        result: 'failure',
        message: 'ログインに失敗しました。',
        errors: ['ユーザー名またはパスワードが違います。'],
      })
    end

    it 'is error with nil' do
      response = action.call(**params, session: nil)
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
        result: 'error',
        message: '不正なパラメーターです。',
        errors: ['Session must be a hash'],
      })
    end

    it 'is error with bad params' do
      response = action.call(**params, session: {username: 'user' * 64, password: 'pass'})
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
        result: 'error',
        message: '不正なパラメーターです。',
        errors: ['Username size cannot be greater than 255'],
      })
    end

    it 'is error with bad params' do
      response = action.call(**params, session: {username: 'user', password: ''})
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
        result: 'error',
        message: '不正なパラメーターです。',
        errors: ['Password must be filled', 'Password size cannot be greater than 255'],
      })
    end

    it 'is error with bad params' do
      response = action.call(**params, session: {username: 'user'})
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
        result: 'error',
        message: '不正なパラメーターです。',
        errors: [
          'Password is missing',
          'Password size cannot be greater than 255',
        ],
      })
    end
  end

  describe 'no session' do
    let(:session) { {} }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
        result: 'success',
        message: 'ログインしました。',
      })
    end
  end

  describe 'session timeout' do
    let(:session) { {uuid: 'x', user_id: 42, access_time: Time.now - (3600 * 2)} }
    let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(JSON.parse(response[2].first, symbolize_names: true)).must_equal({
        result: 'success',
        message: 'ログインしました。',
      })
    end
  end
end
