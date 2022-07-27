require_relative '../../../spec_helper'

describe Api::Controllers::Providers::Check do
  let(:action) { Api::Controllers::Providers::Check.new(**action_opts, provider_repository: provider_repository) }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }
  let(:action_params) { {id: 'provider1'} }

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
