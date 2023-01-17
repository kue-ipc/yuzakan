# frozen_string_literal: true

RSpec.describe Api::Controllers::Providers::Create, type: :action do
  init_controller_spec(self)
  let(:action) { Api::Controllers::Providers::Create.new(**action_opts, provider_repository: provider_repository) }
  let(:format) { 'application/json' }
  let(:action_params) { {**provider_params, params: provider_params_params} }

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
  let(:provider_without_params) { Provider.new(id: 3, **provider_params) }
  let(:provider_with_params) { Provider.new(id: 3, **provider_params, provider_params: provider_params_attributes) }
  let(:provider_repository) {
    ProviderRepository.new.tap do |obj|
      stub(obj).exist_by_name? { false }
      stub(obj).last_order { 16 }
      stub(obj).create { provider_without_params }
      stub(obj).find_with_params { provider_with_params }
      stub(obj).add_param { ProviderParam.new }
    end
  }

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
      expect(response[0]).to eq 201
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      expect(response[1]['Location']).to eq "/api/providers/#{provider_with_params.id}"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        **provider_params,
        label: provider_params[:display_name],
        params: provider_params_attributes_params,
      })
    end

    it 'is successful without order param' do
      response = action.call(params.except(:order))
      expect(response[0]).to eq 201
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      expect(response[1]['Location']).to eq "/api/providers/#{provider_with_params.id}"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        **provider_params,
        label: provider_params[:display_name],
        params: provider_params_attributes_params,
      })
    end

    it 'is failure with bad name pattern' do
      response = action.call({**params, name: '!'})
      expect(response[0]).to eq 400
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: 'Bad Request',
        errors: [{name: ['名前付けの規則に違反しています。']}],
      })
    end

    it 'is failure with name over' do
      response = action.call({**params, name: 'a' * 256})
      expect(response[0]).to eq 400
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: 'Bad Request',
        errors: [{name: ['サイズが255を超えてはいけません。']}],
      })
    end

    it 'is failure with name number' do
      response = action.call({**params, name: 1})
      expect(response[0]).to eq 400
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: 'Bad Request',
        errors: [{name: ['文字列を入力してください。']}],
      })
    end

    it 'is failure with bad provider_params params' do
      response = action.call({
        **params,
        params: 'abc',
      })
      expect(response[0]).to eq 400
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: 'Bad Request',
        errors: [{
          params: ['連想配列を入力してください。'],
        }],
      })
    end

    it 'is failure without params' do
      response = action.call(env)
      expect(response[0]).to eq 400
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: 'Bad Request',
        errors: [{name: ['存在しません。'], adapter_name: ['存在しません。']}],
      })
    end

    describe 'existed name' do
      let(:provider_repository) {
        ProviderRepository.new.tap do |obj|
          stub(obj).exist_by_name? { true }
          stub(obj).last_order { 16 }
          stub(obj).create_with_params { provider_with_params }
        end
      }

      it 'is failure' do
        response = action.call(params)
        expect(response[0]).to eq 422
        expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{name: ['重複しています。']}],
        })
      end

      it 'is failure with bad name pattern' do
        response = action.call({**params, name: '!'})
        expect(response[0]).to eq 400
        expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          code: 400,
          message: 'Bad Request',
          errors: [{name: ['名前付けの規則に違反しています。']}],
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
