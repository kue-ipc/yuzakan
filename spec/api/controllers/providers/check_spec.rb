# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Api::Controllers::Providers::Check do
  let(:action) { Api::Controllers::Providers::Check.new(**action_opts, provider_repository: provider_repository) }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }
  let(:action_params) { {id: 'provider1'} }

  let(:provider_params) {
    {
      name: 'provider1',
      display_name: 'プロバイダー①',
      adapter_name: 'mock',
      order: 16,
    }
  }
  let(:provider_params_attributes) { [{name: 'check', value: Marshal.dump(true)}] }
  let(:provider_with_params) { Provider.new(id: 3, **provider_params, provider_params: provider_params_attributes) }
  let(:provider_repository) {
    ProviderRepository.new.tap { |obj| stub(obj).find_with_params_by_name { provider_with_params } }
  }

  it 'is successful' do
    response = action.call(params)
    expect(response[0]).to eq 200
    expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).to eq({check: true})
  end

  describe 'check failed' do
    let(:provider_params_attributes) { [{name: 'check', value: Marshal.dump(false)}] }

    it 'is successful, but false' do
      response = action.call(params)
      expect(response[0]).to eq 200
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({check: false})
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
