# frozen_string_literal: true

RSpec.describe API::Actions::Providers::Check do
  init_controller_spec
  let(:action_opts) { {provider_repository: provider_repository} }
  let(:format) { "application/json" }
  let(:action_params) { {id: "provider1"} }

  let(:adapter_params) {
    {
      name: "provider1",
      display_name: "プロバイダー①",
      adapter: "mock",
      order: 16,
    }
  }
  let(:adapter_params_attributes) { [{name: "check", value: Marshal.dump(true)}] }
  let(:provider_with_params) { Provider.new(id: 3, **adapter_params, adapter_params: adapter_params_attributes) }
  let(:provider_repository) {
    instance_double(ProviderRepository, find_with_params_by_name: provider_with_params)
  }

  it "is successful" do
    response = action.call(params)
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json).to eq({check: true})
  end

  describe "check failed" do
    let(:adapter_params_attributes) { [{name: "check", value: Marshal.dump(false)}] }

    it "is successful, but false" do
      response = action.call(params)
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({check: false})
    end
  end

  describe "no login session" do
    let(:session) { {uuid: uuid} }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({code: 401, message: "Unauthorized"})
    end
  end
end
