# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Api::Controllers::Providers::Destroy do
  let(:action) { Api::Controllers::Providers::Destroy.new(**action_opts, provider_repository: provider_repository) }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }
  let(:action_params) { {**env, id: 'provider1'} }

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
      stub(obj).delete { provider_without_params }
    end
  }

  it 'is failure' do
    response = action.call(params)
    expect(response[0]).must_equal 403
    expect(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).must_equal({code: 403, message: 'Forbidden'})
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).must_equal 200
      expect(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).must_equal({
        **provider_params,
        label: provider_params[:display_name],
        params: provider_params_attributes_params,
      })
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
        expect(response[0]).must_equal 404
        expect(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).must_equal({
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
      expect(response[0]).must_equal 401
      expect(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).must_equal({code: 401, message: 'Unauthorized'})
    end
  end
end
