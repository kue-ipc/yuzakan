# frozen_string_literal: true

RSpec.describe API::Actions::Services::Check do
  init_action_spec
  let(:action_opts) { {service_repository: service_repository} }
  let(:format) { "application/json" }
  let(:action_params) { {id: "service1"} }

  let(:adapter_params) {
    {
      name: "service1",
      label: "プロバイダー①",
      adapter: "mock",
      order: 16,
    }
  }
  let(:adapter_params_attributes) { [{name: "check", value: Marshal.dump(true)}] }
  let(:service_with_params) { Service.new(id: 3, **adapter_params, adapter_params: adapter_params_attributes) }
  let(:service_repository) {
    instance_double(ServiceRepository, find_with_params_by_name: service_with_params)
  }

  it "is successful" do
    response = action.call(params)
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json).to eq({check: true})
  end

  describe "check failed" do
    let(:adapter_params_attributes) { [{name: "check", value: Marshal.dump(false)}] }

    it "is successful, but false" do
      response = action.call(params)
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({check: false})
    end
  end

  describe "no login session" do
    let(:session) { {uuid: uuid} }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({code: 401, message: "Unauthorized"})
    end
  end
end
