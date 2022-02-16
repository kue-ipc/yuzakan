def create_mock_provider(**params)
  provider_params = params.map { |name, value| {name: name, value: Marshal.dump(value)} }
  Provider.new(name: 'provider', dispaly_name: 'プロバイダー', adapter_name: 'mock', provider_params: provider_params)
end

def create_mock(**expects)
  mock = Minitest::Mock.new
  expects.each { |key, value| mock.expect(key, value[0], value[1] || []) }
  mock
end
