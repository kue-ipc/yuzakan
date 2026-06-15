# frozen_string_literal: true

RSpec.describe API::Views::Part do
  init_part_spec

  let(:value) { {a: 1, b: 2} }

  it "to_h" do
    data = subject.to_h
    expect(data).to eq(value)
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq(value)
  end
end
