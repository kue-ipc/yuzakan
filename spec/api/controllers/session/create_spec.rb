require_relative '../../../spec_helper'

describe Api::Controllers::Session::Create do
  let(:action) {
    Api::Controllers::Session::Create.new(**action_opts, user_repository: user_repository,
                                                         provider_repository: provider_repository,
                                                         auth_log_repository: auth_log_repository)
  }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }
  let(:action_params) { {username: 'user', password: 'pass'} }

  let(:user_repository) {
    UserRepository.new.tap do |obj|
      stub(obj).find { user }
      stub(obj).find_by_name { user }
      stub(obj).update { user }
    end
  }
  let(:providers) { [create_mock_provider(params: {username: 'user', password: 'pass'})] }
  let(:provider_repository) {
    ProviderRepository.new.tap { |obj| stub(obj).ordered_all_with_adapter_by_operation { providers } }
  }
  let(:auth_log_repository) {
    AuthLogRepository.new.tap do |obj|
      stub(obj).create { AuthLog.new }
      stub(obj).recent_by_username { [] }
    end
  }

  it 'is see other' do
    Rack::Utils::HTTP_STATUS_CODES[303] = 'Hoge'
    response = action.call(params)
    _(response[0]).must_equal 303
    _(response[1]['Location']).must_equal '/api/session'
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({
      code: 303,
      message: 'See Other',
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
      _(json[:uuid]).must_equal uuid
      _(json[:current_user]).must_equal user.to_h.except(:id)
      created_at = Time.iso8601(json[:created_at])
      _(created_at).must_be :>=, begin_time
      _(created_at).must_be :<=, end_time
      updated_at = Time.iso8601(json[:updated_at])
      _(updated_at).must_be :>=, begin_time
      _(updated_at).must_be :<=, end_time
      deleted_at = Time.iso8601(json[:deleted_at])
      _(deleted_at).must_be :>=, begin_time + 3600
      _(deleted_at).must_be :<=, end_time + 3600
    end

    it 'is failed with bad username' do
      response = action.call(**params, username: 'baduser')
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'Unprocessable Entity',
        errors: ['ユーザー名またはパスワードが違います。'],
      })
    end

    it 'is failed with bad password' do
      response = action.call(**params, password: 'badpass')
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'Unprocessable Entity',
        errors: ['ユーザー名またはパスワードが違います。'],
      })
    end

    it 'is error with no username' do
      response = action.call(**params.reject { |k, _v| k == :username })
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'Bad Request',
        errors: [{username: ['存在しません。']}],
      })
    end

    it 'is error with no password' do
      response = action.call(**params.reject { |k, _v| k == :password })
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'Bad Request',
        errors: [{password: ['存在しません。']}],
      })
    end

    it 'is error with too large username' do
      response = action.call(**params, username: 'user' * 64)
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'Bad Request',
        errors: [{username: ['サイズが255を超えてはいけません。']}],
      })
    end

    it 'is error with empty password' do
      response = action.call(**params, password: '')
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'Bad Request',
        errors: [{password: ['入力が必須です。']}],
      })
    end

    describe 'too many access' do
      let(:auth_log_repository) {
        AuthLogRepository.new.tap do |obj|
          stub(obj).create { AuthLog.new }
          stub(obj).recent_by_username do
            [
              AuthLog.new(result: 'failure'),
              AuthLog.new(result: 'failure'),
              AuthLog.new(result: 'failure'),
              AuthLog.new(result: 'failure'),
              AuthLog.new(result: 'failure'),
            ]
          end
        end
      }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 403
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 403,
          message: 'Forbidden',
          errors: ['時間あたりのログイン試行が規定の回数を超えたため、現在ログインが禁止されています。 ' \
                   'しばらく待ってから再度ログインを試してください。'],
        })
      end
    end

    describe 'not allowed network' do
      let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '10.10.10.0/24') }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 403
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 403,
          message: 'Forbidden',
          errors: ['現在のネットワークからのログインは許可されていません。'],
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
      _(json[:uuid]).must_match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      _(json[:current_user]).must_equal user.to_h.except(:id)
      created_at = Time.iso8601(json[:created_at])
      _(created_at).must_be :>=, begin_time
      _(created_at).must_be :<=, end_time
      updated_at = Time.iso8601(json[:updated_at])
      _(updated_at).must_be :>=, begin_time
      _(updated_at).must_be :<=, end_time
      deleted_at = Time.iso8601(json[:deleted_at])
      _(deleted_at).must_be :>=, begin_time + 3600
      _(deleted_at).must_be :<=, end_time + 3600
    end
  end

  describe 'session timeout' do
    let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 7200, updated_at: Time.now - 7200} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 401
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 401,
        message: 'Unauthorized',
        errors: ['セッションがタイムアウトしました。'],
      })
    end
  end
end
