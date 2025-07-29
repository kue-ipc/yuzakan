# frozen_string_literal: true

RSpec.describe API::Views::Parts::UserPassword do
  init_part_spec

  let(:value) {
    {
      password: "password123",
      services: ["service1", "service2"],
    }
  }

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({
      password: value[:password],
      services: value[:services],
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      password: value[:password],
      services: value[:services],
    })
  end
end
