# frozen_string_literal: true

RSpec.describe API::Views::Parts::Status do
  init_part_spec

  let(:value) { 200 }

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({
      code: 200,
      message: "OK",
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      code: 200,
      message: "OK",
    })
  end
end
