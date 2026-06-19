# frozen_string_literal: true

RSpec.describe API::Views::Parts::Auth do
  init_part_spec

  let(:value) { {username: user.name} }
  let(:expected_data) {
    {
      username: value[:username],
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
