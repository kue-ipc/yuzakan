# frozen_string_literal: true

def create_mock_provider(params: {}, attr_mappings: [], **attributes)
  provider_params = params.map { |key, value| {name: key, value: Marshal.dump(value)} }
  Provider.new(**attributes, adapter_name: "mock", provider_params: provider_params, attr_mappings: attr_mappings)
end
