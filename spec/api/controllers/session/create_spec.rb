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

  let(:activity_log_repository) { Minitest::Mock.new.expect(:create, nil, [Hash]) }

  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:config_repository) { Minitest::Mock.new.expect(:current, config) }

  let(:user) { User.new(name: 'user', display_name: 'ユーザー', email: 'user@example.jp') }
  let(:user_repository) {
    Minitest::Mock.new.expect(:find, user, [Integer]).expect(:find_by_name, user, [String])
      .expect(:update, nil, [Integer, Hash])
  }

  let(:providers) {
    [Provider.new(name: 'provider', dispaly_name: 'プロバイダー', adapter_name: 'mock',
                  provider_params: [{name: 'username', value: Marshal.dump('user')},
                                    {name: 'password', value: Marshal.dump('pass')},])]
  }
  let(:provider_repository) { Minitest::Mock.new.expect(:operational_all_with_adapter, providers, [:auth]) }

  let(:auth_log_repository) {
    Minitest::Mock.new.expect(:create, nil, [Hash]).expect(:recent_by_username, [], [String, Integer])
  }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[2]).must_equal [JSON.generate({
      result: 'success',
      message: 'ログインしました。',
    })]
  end

  describe 'no auth' do
    it 'is failed' do
      response = action.call(**params, session: {username: 'user', password: 'nopass'})
      _(response[0]).must_equal 422
      _(response[2]).must_equal [JSON.generate({
        result: 'failure',
        message: 'ログインに失敗しました。',
        errors: ['ユーザー名またはパスワードが違います。'],
      })]
    end
  end

  it 'is error' do
    response = action.call(**params, session: nil)
    _(response[0]).must_equal 400
    _(response[2]).must_equal [JSON.generate({
      result: 'error',
      message: '不正なパラメーターです。',
      errors: ['Session must be a hash'],
    })]
  end

  it 'is error' do
    response = action.call(**params, session: {username: 'user' * 64, password: 'pass'})
    _(response[0]).must_equal 400
    _(response[2]).must_equal [JSON.generate({
      result: 'error',
      message: '不正なパラメーターです。',
      errors: ['Username size cannot be greater than 255'],
    })]
  end

  it 'is error' do
    response = action.call(**params, session: {username: 'user', password: ''})
    _(response[0]).must_equal 400
    _(response[2]).must_equal [JSON.generate({
      result: 'error',
      message: '不正なパラメーターです。',
      errors: ['Password must be filled', 'Password size cannot be greater than 255'],
    })]
  end

  it 'is error' do
    response = action.call(**params, session: {username: 'user'})
    _(response[0]).must_equal 400
    _(response[2]).must_equal [JSON.generate({
      result: 'error',
      message: '不正なパラメーターです。',
      errors: [
        'Password is missing',
        'Password size cannot be greater than 255',
      ],
    })]
  end
end
