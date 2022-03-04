def create_mock_provider(params: {}, **attributes)
  provider_params = params.map { |key, value| {name: key, value: Marshal.dump(value)} }
  Provider.new(**attributes, adapter_name: 'mock', provider_params: provider_params)
end
