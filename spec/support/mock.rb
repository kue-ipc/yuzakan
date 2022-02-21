def create_mock_provider(name: 'provider', dispaly_name: 'プロバイダー', params: {})
  provider_params = params.map { |key, value| {name: key, value: Marshal.dump(value)} }
  Provider.new(name: name, dispaly_name: dispaly_name, adapter_name: 'mock', provider_params: provider_params)
end

def create_mock(**expects)
  mock = Minitest::Mock.new
  expects.each { |key, value| mock.expect(key, value[0], value[1] || []) }
  mock
end
