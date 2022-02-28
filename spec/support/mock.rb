def create_mock_provider(params: {}, **attributes)
  provider_params = params.map { |key, value| {name: key, value: Marshal.dump(value)} }
  Provider.new(**attributes, adapter_name: 'mock', provider_params: provider_params)
end

def create_mock(**expects)
  mock = Minitest::Mock.new
  expects.each do |key, value|
    if value.is_a?(Array)
      mock.expect(key, value[0], value[1] || [])
    else
      mock.expect(key, value, [])
    end
  rescue NoMethodError
    mock.expect(key, value, [])
  end
  mock
end
