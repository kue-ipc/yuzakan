require_relative '../../../spec_helper'

describe Api::Controllers::Providers::Create do
  let(:action) {
    Api::Controllers::Providers::Create.new(activity_log_repository: activity_log_repository,
                                            config_repository: config_repository,
                                            user_repository: user_repository,
                                            provider_repository: provider_repository)
  }
  let(:params) { {**env, **provider_params, params: provider_params_params} }

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
      adapter_name: 'test', order: 16,
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
      {name: 'int', value: Marshal.dump(42)},
    ]
  }
  let(:provider_params_attributes_params) {
    {
      default: nil,
      str: 'hoge',
      str_default: 'デフォルト',
      str_fixed: '固定',
      str_required: nil,
      str_enc: nil,
      text: nil,
      int: 42,
      list: 'default',
    }
  }
  let(:provider_without_params) { Provider.new(id: 3, **provider_params) }
  let(:provider_with_params) { Provider.new(id: 3, **provider_params, provider_params: provider_params_attributes) }
  let(:provider_repository) {
    ProviderRepository.new.tap do |obj|
      stub(obj).exist_by_name? { false }
      stub(obj).exist_by_label? { false }
      stub(obj).exist_by_order? { false }
      stub(obj).last_order { 16 }
      stub(obj).create { provider_without_params }
      stub(obj).find_with_params { provider_with_params }
      stub(obj).add_param { ProviderParam.new }
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
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(response[1]['Location']).must_equal "/api/providers/#{provider_with_params.id}"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({**provider_params, params: provider_params_attributes_params})
    end

    it 'is successful without order param' do
      response = action.call(params.except(:order))
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(response[1]['Location']).must_equal "/api/providers/#{provider_with_params.id}"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({**provider_params, params: provider_params_attributes_params})
    end

    it 'is failure with bad name pattern' do
      response = action.call({**params, name: '!'})
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'Unprocessable Entity',
        errors: [{name: ['名前付けの規則に違反しています。']}],
      })
    end

    it 'is failure with name over' do
      response = action.call({**params, name: 'a' * 256})
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'Unprocessable Entity',
        errors: [{name: ['サイズが255を超えてはいけません。']}],
      })
    end

    it 'is failure with name over' do
      response = action.call({**params, name: 1})
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'Unprocessable Entity',
        errors: [{name: ['文字列を入力してください。']}],
      })
    end

    it 'is failure with bad provider_params params' do
      response = action.call({
        **params,
        params: 'abc',
      })
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'Unprocessable Entity',
        errors: [{
          params: ['連想配列を入力してください。'],
        }],
      })
    end

    it 'is failure without params' do
      response = action.call(env)
      _(response[0]).must_equal 422
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 422,
        message: 'Unprocessable Entity',
        errors: [{name: ['存在しません。'], label: ['存在しません。'], adapter_name: ['存在しません。']}],
      })
    end

    describe 'existed name' do
      let(:provider_repository) {
        ProviderRepository.new.tap do |obj|
          stub(obj).exist_by_name? { true }
          stub(obj).exist_by_label? { false }
          stub(obj).exist_by_order? { false }
          stub(obj).last_order { 16 }
          stub(obj).create_with_params { provider_with_params }
        end
      }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{name: ['重複しています。']}],
        })
      end

      it 'is failure with bad name pattern' do
        response = action.call({**params, name: '!'})
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{name: ['名前付けの規則に違反しています。']}],
        })
      end
    end

    describe 'existed label' do
      let(:provider_repository) {
        ProviderRepository.new.tap do |obj|
          stub(obj).exist_by_name? { false }
          stub(obj).exist_by_label? { true }
          stub(obj).exist_by_order? { false }
          stub(obj).last_order { 16 }
          stub(obj).create_with_params { provider_with_params }
        end
      }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{label: ['重複しています。']}],
        })
      end

      it 'is failure with bad name pattern' do
        response = action.call({**params, name: '!'})
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{name: ['名前付けの規則に違反しています。'], label: ['重複しています。']}],
        })
      end
    end

    describe 'existed name nad label' do
      let(:provider_repository) {
        ProviderRepository.new.tap do |obj|
          stub(obj).exist_by_name? { true }
          stub(obj).exist_by_label? { true }
          stub(obj).exist_by_order? { false }
          stub(obj).last_order { 16 }
          stub(obj).create_with_params { provider_with_params }
        end
      }

      it 'is failure' do
        response = action.call(params)
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
