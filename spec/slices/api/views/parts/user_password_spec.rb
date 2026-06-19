# frozen_string_literal: true

RSpec.describe API::Views::Parts::UserPassword do
  init_part_spec

  let(:value) {
    {
      password: "password123",
      services: ["service1", "service2"],
    }
  }
  let(:expected_data) { {password: value[:password]} }
  let(:expected_services) { value[:services] }

  it "to_h" do
    data = subject.to_h
    expect(data.except(:services)).to eq(expected_data)
    expect(data[:services]).to match_array(expected_services)
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data.except(:services)).to eq(expected_data)
    expect(data[:services]).to match_array(expected_services)
  end
end
