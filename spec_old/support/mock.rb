# frozen_string_literal: true

def create_mock_provider(params: {}, attr_mappings: [], **attributes)
  adapter_params = params.map do |key, value|
    {name: key, value: Marshal.dump(value)}
  end
  Provider.new(**attributes, adapter: "mock", adapter_params: adapter_params,
    attr_mappings: attr_mappings)
end
