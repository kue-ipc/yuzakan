require_relative '../../../spec_helper'

describe Api::Controllers::Session::Create do
  let(:action) {
    Api::Controllers::Session::Create.new(activity_log_repository: activity_log_repository,
                                          config_repository: config_repository,
                                          user_repository: user_repository,
                                          provider_repository: provider_repository,
                                          auth_log_repository: auth_log_repository)
  }
  let(:params) { {**env, username: 'user', password: 'pass'} }
  let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:client) { '192.0.2.1' }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:user) { User.new(id: 42, name: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1) }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'application/json' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:activity_log_repository) { create_mock(create: [nil, [Hash]]) }
  let(:config_repository) { create_mock(current: config) }
  let(:user_repository) {
    create_mock(find: [user, [Integer]], find_by_name: [user, [String]], update: [nil, [Integer, Hash]])
  }

  let(:providers) { [create_mock_provider(params: {username: 'user', password: 'pass'})] }
  let(:provider_repository) { create_mock(operational_all_with_adapter: [providers, [Symbol]]) }
  let(:auth_log_repository) { create_mock(create: [nil, [Hash]], recent_by_username: [[], [String, Integer]]) }

  it 'is see other' do
    Rack::Utils::HTTP_STATUS_CODES[303] = 'Hoge'
    response = action.call(params)
    _(response[0]).must_equal 303
    _(response[1]['Location']).must_equal '/api/session'
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({
      code: 303,
      message: '既にログインしています。',
      location: '/api/session',
    })
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

    it 'is failed with bad username' do
      response = action.call(**params, username: 'baduser')
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'ユーザー名またはパスワードが違います。',
      })
    end

    it 'is failed with bad password' do
      response = action.call(**params, password: 'badpass')
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'ユーザー名またはパスワードが違います。',
      })
    end

    it 'is error with no username' do
      response = action.call(**params.reject { |k, _v| k == :username })
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'パラメーターが不正です。',
        errors: ['Username is missing', 'Username size cannot be greater than 255'],
      })
    end

    it 'is error with no password' do
      response = action.call(**params.reject { |k, _v| k == :password })
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'パラメーターが不正です。',
        errors: ['Password is missing', 'Password size cannot be greater than 255'],
      })
    end

    it 'is error with too large username' do
      response = action.call(**params, username: 'user' * 64)
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'パラメーターが不正です。',
        errors: ['Username size cannot be greater than 255'],
      })
    end

    it 'is error with empty password' do
      response = action.call(**params, password: '')
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'パラメーターが不正です。',
        errors: ['Password must be filled', 'Password size cannot be greater than 255'],
      })
    end

    describe 'too many access' do
      let(:auth_log_repository) {
        create_mock(create: [nil, [Hash]], recent_by_username: [[
                      AuthLog.new(result: 'failure'),
                      AuthLog.new(result: 'failure'),
                      AuthLog.new(result: 'failure'),
                      AuthLog.new(result: 'failure'),
                      AuthLog.new(result: 'failure'),
                    ], [String, Integer],])
      }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 403
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 403,
          message: '時間あたりのログイン試行が規定の回数を超えたため、' \
                   '現在ログインが禁止されています。' \
                   'しばらく待ってから再度ログインを試してください。',
        })
      end
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
