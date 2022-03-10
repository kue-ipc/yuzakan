require_relative '../../../spec_helper'

describe Api::Controllers::Providers::Destroy do
  let(:action) {
    Api::Controllers::Providers::Destroy.new(activity_log_repository: activity_log_repository,
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
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:activity_log_repository) { ActivityLogRepository.new.tap { |obj| stub(obj).create } }
  let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { config } } }
  let(:user_repository) { UserRepository.new.tap { |obj| stub(obj).find { user } } }

  let(:provider_params) {
    {
      name: 'provider1', label: 'プロバイダー①',
      adatper_name: 'test', oredr: 16,
      readable: true,
      writable: true,
      authenticatable: true,
      password_changeable: true,
      lockable: true,

      individual_password: false,
      self_management: false,
    }
  }
  let(:provider_params_params) {
    [
      {name: 'str', value: 'hoge'},
      {name: 'str_required', value: 'fuga'},
      {name: 'str_enc', value: 'piyo'},
      {name: 'text', valu: 'moe'},
      {name: 'int', valu: 42},
      {name: 'list', valu: 'other'},
    ]
  }
  let(:provider_params_attributes) {
    [
      {name: 'str', value: Marshal.dump('hoge')},
    ]
  }
  let(:provider_with_params) { Provider.new(id: 3, **provider_params, provider_params: provider_params_attributes) }
  let(:provider_without_params) { Provider.new(id: 3, **provider_params) }
  let(:provider_repository) {
    ProviderRepository.new.tap do |obj|
      stub(obj).find_with_params_by_name { provider_with_params }
      stub(obj).delete { provider_without_params }
    end
  }

  it 'is failure' do
    response = action.call(params)
    _(response[0]).must_equal 403
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({code: 403, message: 'Forbidden'})
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({order: 7, **attr_params})
    end

    describe 'not existend' do
      let(:provider_repository) {
        ProviderRepository.new.tap do |obj|
          mock(obj).find_with_params_by_name('provider1') { nil }
          dont_allow(obj).delete
        end
      }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 404
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 404,
          message: 'Not Found',
        })
      end
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
