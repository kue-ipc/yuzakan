# frozen_string_literal: true

def create_mock_provider(params: {}, attr_mappings: [], **attributes)
  provider_params = params.map do |key, value|
    {name: key, value: Marshal.dump(value)}
  end
  Provider.new(**attributes, adapter: "mock", provider_params: provider_params,
    attr_mappings: attr_mappings)
end
