require_relative '../../../spec_helper'

describe Api::Controllers::Providers::Update do
  let(:action) {
    Api::Controllers::Providers::Update.new(activity_log_repository: activity_log_repository,
                                            config_repository: config_repository,
                                            user_repository: user_repository,
                                            provider_repository: provider_repository,
                                            provider_param_repository: provider_param_repository)
  }
  let(:params) { {**env, id: 'provider1', **provider_params, params: provider_params_params} }

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
      adapter_name: 'test', oredr: 16,
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
    {
      str: 'hoge',
      str_required: 'fuga',
      str_enc: 'piyo',
      text: 'moe',
      int: 42,
      list: 'other',
    }
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
      stub(obj).find_with_params { provider_with_params }
      stub(obj).exist_by_name? { false }
      stub(obj).exist_by_label? { false }
      stub(obj).exist_by_order? { false }
      stub(obj).last_order? { 16 }
      stub(obj).update { provider_without_params }
      stub(obj).delete_params_by_name { 1 }
      stub(obj).add_param { ProviderParam.new }
    end
  }
  let(:provider_param_repository) { ProviderParamRepository.new.tap { |obj| stub(obj).update { ProviderPrama.new } } }

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
      _(json).must_equal(provider_params)
    end

    it 'is successful with different' do
      response = action.call({**params, name: 'hoge', label: 'ほげ'})
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal(provider_params)
    end

    describe 'not existed' do
      let(:provider_repository) {
        ProviderRepository.new.tap do |obj|
          mock(obj).find_with_params_by_name('provider1') { nil }
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

    describe 'existed name' do
      let(:provider_repository) {
        ProviderRepository.new.tap do |obj|
          stub(obj).find_with_params_by_name { provider_with_params }
          stub(obj).find_with_params { provider_with_params }
          stub(obj).exist_by_name? { true }
          stub(obj).exist_by_label? { false }
          stub(obj).exist_by_order? { false }
          stub(obj).last_order? { 16 }
          stub(obj).update { provider_without_params }
          stub(obj).delete_params_by_name { 1 }
          stub(obj).add_param { ProviderParam.new }
        end
      }

      it 'is successful' do
        response = action.call(params)
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(provider_params)
      end

      it 'is successful with diffrent only label' do
        response = action.call({**params, labal: 'ほげ'})
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(provider_params)
      end

      it 'is failure with different' do
        response = action.call({**params, name: 'hoge', label: 'ほげ'})
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{name: ['重複しています。']}],
        })
      end
    end

    describe 'existed label' do
      let(:provider_repository) {
        ProviderRepository.new.tap do |obj|
          stub(obj).find_with_params_by_name { provider_with_params }
          stub(obj).find_with_params { provider_with_params }
          stub(obj).exist_by_name? { false }
          stub(obj).exist_by_label? { true }
          stub(obj).exist_by_order? { false }
          stub(obj).last_order? { 16 }
          stub(obj).update { provider_without_params }
          stub(obj).delete_params_by_name { 1 }
          stub(obj).add_param { ProviderParam.new }
        end
      }

      it 'is successful' do
        response = action.call(params)
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(provider_params)
      end

      it 'is successful with diffrent only name' do
        response = action.call({**params, name: 'hoge'})
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(provider_params)
      end

      it 'is failure with different' do
        response = action.call({**params, name: 'hoge', label: 'ほげ'})
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{label: ['重複しています。']}],
        })
      end
    end

    describe 'existed label' do
      let(:provider_repository) {
        ProviderRepository.new.tap do |obj|
          stub(obj).find_with_params_by_name { provider_with_params }
          stub(obj).find_with_params { provider_with_params }
          stub(obj).exist_by_name? { true }
          stub(obj).exist_by_label? { true }
          stub(obj).exist_by_order? { false }
          stub(obj).last_order? { 16 }
          stub(obj).update { provider_without_params }
          stub(obj).delete_params_by_name { 1 }
          stub(obj).add_param { ProviderParam.new }
        end
      }

      it 'is successful' do
        response = action.call(params)
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(provider_params)
      end

      it 'is successful with diffrent only hidden' do
        response = action.call({**params, hidden: 'true'})
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(provider_params)
      end

      it 'is failure with different' do
        response = action.call({**params, name: 'hoge', label: 'ほげ'})
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{name: ['重複しています。'], label: ['重複しています。']}],
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
