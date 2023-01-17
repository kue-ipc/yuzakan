# frozen_string_literal: true

RSpec.describe Api::Controllers::Providers::Update, type: :action do
  init_controller_spec(self)
  let(:action) {
    Api::Controllers::Providers::Update.new(**action_opts, provider_repository: provider_repository,
                                                           provider_param_repository: provider_param_repository)
  }
  let(:format) { 'application/json' }
  let(:action_params) { {id: 'provider1', **provider_params, params: provider_params_params} }

  let(:provider_params) {
    {
      name: 'provider1',
      display_name: 'プロバイダー①',
      adapter_name: 'test',
      order: 16,
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
  let(:provider_with_params) { Provider.new(id: 3, **provider_params, provider_params: provider_params_attributes) }
  let(:provider_without_params) { Provider.new(id: 3, **provider_params) }
  let(:provider_repository) {
    ProviderRepository.new.tap do |obj|
      stub(obj).find_with_params_by_name { provider_with_params }
      stub(obj).find_with_params { provider_with_params }
      stub(obj).exist_by_name? { false }
      stub(obj).last_order { 16 }
      stub(obj).update { provider_without_params }
      stub(obj).delete_param_by_name { 1 }
      stub(obj).add_param { ProviderParam.new }
    end
  }
  let(:provider_param_repository) { ProviderParamRepository.new.tap { |obj| stub(obj).update { ProviderPrama.new } } }

  it 'is failure' do
    response = action.call(params)
    expect(response[0]).to eq 403
    expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).to eq({code: 403, message: 'Forbidden'})
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).to eq 200
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        **provider_params,
        label: provider_params[:display_name],
        params: provider_params_attributes_params,
      })
    end

    it 'is successful with different' do
      response = action.call({**params, name: 'hoge', label: 'ほげ'})
      expect(response[0]).to eq 200
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        **provider_params,
        label: provider_params[:display_name],
        params: provider_params_attributes_params,
      })
    end

    describe 'not existed' do
      let(:provider_repository) {
        ProviderRepository.new.tap do |obj|
          mock(obj).find_with_params_by_name('provider1') { nil }
        end
      }

      it 'is failure' do
        response = action.call(params)
        expect(response[0]).to eq 404
        expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
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
          stub(obj).last_order { 16 }
          stub(obj).update { provider_without_params }
          stub(obj).delete_param_by_name { 1 }
          stub(obj).add_param { ProviderParam.new }
        end
      }

      it 'is successful' do
        response = action.call(params)
        expect(response[0]).to eq 200
        expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          **provider_params,
          label: provider_params[:display_name],
          params: provider_params_attributes_params,
        })
      end

      it 'is successful with diffrent only label' do
        response = action.call({**params, labal: 'ほげ'})
        expect(response[0]).to eq 200
        expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          **provider_params,
          label: provider_params[:display_name],
          params: provider_params_attributes_params,
        })
      end

      it 'is failure with different' do
        response = action.call({**params, name: 'hoge', label: 'ほげ'})
        expect(response[0]).to eq 422
        expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{name: ['重複しています。']}],
        })
      end
    end
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).to eq 401
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({code: 401, message: 'Unauthorized'})
    end
  end
end
