def mock_provider(**params)
  provider_params = params.map { |name, value|  {name: name, value: Marshal.dump(value)} }
  Provider.new(name: 'provider', dispaly_name: 'プロバイダー', adapter_name: 'mock', provider_params: provider_params)
end

def moc
end
