require_relative '../../../spec_helper'

describe Api::Controllers::Providers::Check do
  let(:action) {
    Api::Controllers::Providers::Check.new(activity_log_repository: activity_log_repository,
                                           config_repository: config_repository,
                                           user_repository: user_repository,
                                           provider_repository: provider_repository)
  }
  let(:params) { {**env, id: 'provider1'} }

  let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:client) { '192.0.2.1' }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:user) { User.new(id: 42, name: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1) }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'application/json' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600) }
  let(:activity_log_repository) { ActivityLogRepository.new.tap { |obj| stub(obj).create } }
  let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { config } } }
  let(:user_repository) { UserRepository.new.tap { |obj| stub(obj).find { user } } }

  let(:provider_params) {
    {
      name: 'provider1', label: 'プロバイダー①',
      adapter_name: 'mock', order: 16,
    }
  }
  let(:provider_params_attributes) { [{name: 'check', value: Marshal.dump(true)}] }
  let(:provider_with_params) { Provider.new(id: 3, **provider_params, provider_params: provider_params_attributes) }
  let(:provider_repository) {
    ProviderRepository.new.tap { |obj| stub(obj).find_with_params_by_name { provider_with_params } }
  }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({check: true})
  end

  describe 'check failed' do
    let(:provider_params_attributes) { [{name: 'check', value: Marshal.dump(false)}] }

    it 'is successful, but false' do
      response = action.call(params)
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({check: false})
    end
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
end
