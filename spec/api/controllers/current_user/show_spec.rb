require_relative '../../../spec_helper'
require 'yaml'

describe Api::Controllers::CurrentUser::Show do
  let(:action) {
    Api::Controllers::CurrentUser::Show.new(activity_log_repository: activity_log_repository,
                                            config_repository: config_repository,
                                            user_repository: user_repository,
                                            provider_repository: provider_repository)
  }
  let(:params) { env }
  let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:client) { '192.0.2.1' }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:user) { User.new(id: 42, name: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1) }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'application/json' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:activity_log_repository) { ActivityLogRepository.new.tap { |obj| stub(obj).create } }
  let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { config } } }
  let(:user_repository) { UserRepository.new.tap { |obj| stub(obj).find { user } } }

  let(:providers) {
    [create_mock_provider(
      name: 'provider',
      params: {
        username: 'user', display_name: 'ユーザー', email: 'user@example.jp',
        attrs: YAML.dump({'displayName' => '表示ユーザー'}),
      },
      attr_mappings: [{
        name: 'displayName', conversion: nil,
        attr: {name: 'display_name', display_name: '表示名', type: 'string', hidden: false},
      }])]
  }
  let(:provider_repository) {
    ProviderRepository.new.tap { |obj| stub(obj).operational_all_with_adapter { providers } }
  }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({
      name: 'user',
      display_name: 'ユーザー',
      email: 'user@example.jp',
      clearance_level: 1,
      userdatas: [{
        provider: 'provider',
        userdata: {
          name: 'user',
          display_name: 'ユーザー',
          email: 'user@example.jp',
          locked: false,
          disabled: false,
          unmanageable: false,
          mfa: false,
          attrs: {display_name: '表示ユーザー'},
        },
      }],
    })
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 401
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({code: 401, message: 'Unauthorized'})
    end
  end

  describe 'no session' do
    let(:session) { {} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 401
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({code: 401, message: 'Unauthorized'})
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
