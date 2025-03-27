# frozen_string_literal: true

RSpec.describe API::Actions::Providers::Index do
  init_controller_spec
  let(:action_opts) { {provider_repository: provider_repository} }
  let(:format) { "application/json" }

  let(:providers_attributes) {
    [
      {id: 1, name: "local", display_name: "ローカル", adapter: "local", order: 8},
      {id: 24, name: "provider24", display_name: "プロバイダー24", adapter: "dummy", order: 16},
      {id: 19, name: "provider19", display_name: "プロバイダー19", adapter: "test", order: 24},
      {id: 27, name: "provider27", display_name: "プロバイダー27", adapter: "mock", order: 32},
      {id: 42, name: "provider42", adapter: "test", order: 32},
    ]
  }

  let(:providers) { providers_attributes.map { |attributes| Provider.new(attributes) } }
  let(:provider_repository) { instance_double(ProviderRepository, ordered_all: providers) }

  it "is successful" do
    response = action.call(params)
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json).to eq(providers_attributes.map do |provider|
      provider.except(:id)
    end)
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
