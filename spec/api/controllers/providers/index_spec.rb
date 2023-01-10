# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Api::Controllers::Providers::Index do
  let(:action) { Api::Controllers::Providers::Index.new(**action_opts, provider_repository: provider_repository) }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }

  let(:providers_attributes) {
    [
      {id: 1, name: 'local', display_name: 'ローカル', adapter_name: 'local', order: 8},
      {id: 24, name: 'provider24', display_name: 'プロバイダー24', adapter_name: 'dummy', order: 16},
      {id: 19, name: 'provider19', display_name: 'プロバイダー19', adapter_name: 'test', order: 24},
      {id: 27, name: 'provider27', display_name: 'プロバイダー27', adapter_name: 'mock', order: 32},
      {id: 42, name: 'provider42', adapter_name: 'test', order: 32},
    ]
  }

  let(:providers) { providers_attributes.map { |attributes| Provider.new(attributes) } }
  let(:provider_repository) { ProviderRepository.new.tap { |obj| stub(obj).ordered_all { providers } } }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal(providers_attributes.map do |provider|
      provider.except(:id).merge(label: provider[:display_name] || provider[:name])
    end)
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
