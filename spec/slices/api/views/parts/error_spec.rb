# frozen_string_literal: true

RSpec.describe API::Views::Parts::Error do
  init_part_spec

  let(:value) {
    {
      message: "An error occurred",
      invalid: {name: ["must be filled", "must be a string"]},
      exception: RuntimeError.new("Something went wrong"),
    }
  }
  let(:expected_data) {
    {
      message: value[:message],
      invalid: value[:invalid],
      exception: "#{value[:exception].class.name}: #{value[:exception].message}",
    }
  }

  it "to_h" do
    data = subject.to_h
    expect(data).to eq(expected_data)
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq(expected_data)
  end
end
