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
  let(:remote_ip) { '192.0.2.1' }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:user) { User.new(id: 42, name: 'user', display_name: 'ユーザー', email: 'user@example.jp') }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'application/json' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:activity_log_repository) { create_mock(create: [nil, [Hash]]) }
  let(:config_repository) { create_mock(current: [config]) }
  let(:user_repository) {
    create_mock(find: [user, [Integer]], find_by_name: [user, [String]], update: [nil, [Integer, Hash]])
  }

  let(:providers) { [create_mock_provider(username: 'user', password: 'pass')] }
  let(:provider_repository) { create_mock(operational_all_with_adapter: [providers, [:auth]]) }
  let(:auth_log_repository) { create_mock(create: [nil, [Hash]], recent_by_username: [[], [String, Integer]]) }

  it 'is see other' do
    response = action.call(params)
    _(response[0]).must_equal 303
    _(response[1]['Location']).must_equal '/api/session'
    # TODO
    _(response[2]).must_equal ['See Other']
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is successful' do
      begin_time = Time.now.floor
      response = action.call(params)
      end_time = Time.now.floor
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json[:username]).must_equal 'user'
      _(json[:display_name]).must_equal 'ユーザー'
      created_at = Time.iso8601(json[:created_at])
      _(created_at).must_be :>=, begin_time
      _(created_at).must_be :<=, end_time
      updated_at = Time.iso8601(json[:updated_at])
      _(updated_at).must_be :>=, begin_time
      _(updated_at).must_be :<=, end_time
    end

    it 'is failed with bad password' do
      response = action.call(**params, session: {username: 'user', password: 'nopass'})
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'ユーザー名またはパスワードが違います。',
      })
    end

    it 'is failed with bad username' do
      response = action.call(**params, session: {username: 'user1', password: 'pass'})
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'ユーザー名またはパスワードが違います。',
      })
    end

    it 'is error with nil' do
      response = action.call(**params, session: nil)
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'パラメーターが不正です。',
        errors: ['Session must be a hash'],
      })
    end

    it 'is error with bad params' do
      response = action.call(**params, session: {username: 'user' * 64, password: 'pass'})
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'パラメーターが不正です。',
        errors: ['Username size cannot be greater than 255'],
      })
    end

    it 'is error with bad params' do
      response = action.call(**params, session: {username: 'user', password: ''})
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'パラメーターが不正です。',
        errors: ['Password must be filled', 'Password size cannot be greater than 255'],
      })
    end

    it 'is error with bad params' do
      response = action.call(**params, session: {username: 'user'})
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'パラメーターが不正です。',
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
      begin_time = Time.now.floor
      response = action.call(params)
      end_time = Time.now.floor
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json[:username]).must_equal 'user'
      _(json[:display_name]).must_equal 'ユーザー'
      created_at = Time.iso8601(json[:created_at])
      _(created_at).must_be :>=, begin_time
      _(created_at).must_be :<=, end_time
      updated_at = Time.iso8601(json[:updated_at])
      _(updated_at).must_be :>=, begin_time
      _(updated_at).must_be :<=, end_time
    end
  end

  describe 'session timeout' do
    let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 7200, updated_at: Time.now - 7200} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'セッションがタイムアウトしました。',
      })
    end
  end
end
