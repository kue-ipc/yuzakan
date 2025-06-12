# frozen_string_literal: true

def create_mock_provider(params: {}, mappings: [], **attributes)
  adapter_params = params.map do |key, value|
    {name: key, value: Marshal.dump(value)}
  end
  Provider.new(**attributes, adapter: "mock", adapter_params: adapter_params,
    mappings: mappings)
end
