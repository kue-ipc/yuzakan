# frozen_string_literal: true

RSpec.describe API::Views::Parts::Session do
  init_part_spec
  let_session

  let(:value) { session }
  let(:expected_data) {
    {
      uuid: value[:uuid],
      user: value[:user],
      trusted: value[:trusted],
    }
  }
  let(:null_data) {
    {
      uuid: nil,
      user: nil,
      trusted: nil,
      expires_at: nil,
    }
  }

  it "to_h" do
    data = subject.to_h
    expect(data.except(:expires_at)).to eq(expected_data)
    expect(data[:expires_at]).to eq(Time.at(value[:expires_at]))
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data.except(:expires_at)).to eq(expected_data)
    expect(Time.iso8601(data[:expires_at])).to eq(Time.at(value[:expires_at]))
  end

  context "when first session" do
    let(:value) { first_session }

    it "to_h" do
      data = subject.to_h
      expect(data).to eq(null_data)
    end

    it "to_json" do
      json = subject.to_json
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq(null_data)
    end
  end
end
