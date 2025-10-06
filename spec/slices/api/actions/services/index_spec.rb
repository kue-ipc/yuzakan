# frozen_string_literal: true

RSpec.describe API::Actions::Services::Index do
  init_action_spec
  let(:action_opts) { {service_repository: service_repository} }
  let(:format) { "application/json" }

  let(:services_attributes) {
    [
      {id: 1, name: "local", label: "ローカル", adapter: "local", order: 8},
      {id: 24, name: "service24", label: "プロバイダー24", adapter: "dummy", order: 16},
      {id: 19, name: "service19", label: "プロバイダー19", adapter: "test", order: 24},
      {id: 27, name: "service27", label: "プロバイダー27", adapter: "mock", order: 32},
      {id: 42, name: "service42", adapter: "test", order: 32},
    ]
  }

  let(:services) { services_attributes.map { |attributes| Service.new(attributes) } }
  let(:service_repository) { instance_double(ServiceRepository, ordered_all: services) }

  it "is successful" do
    response = action.call(params)
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json).to eq(services_attributes.map do |service|
      service.except(:id)
    end)
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
