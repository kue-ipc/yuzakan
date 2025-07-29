# frozen_string_literal: true

RSpec.describe API::Views::Parts::Network do
  init_part_spec

  let(:value) { network }

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({
      ip: "0.0.0.0/0",
      clearance_level: 1,
      trusted: false,
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      ip: "0.0.0.0/0",
      clearanceLevel: 1,
      trusted: false,
    })
  end
end
